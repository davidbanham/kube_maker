stage = dummy
pull_policy = Always
uniq:=$(shell uuidgen)
tag = $(shell whoami)-dev-$(uniq)

.PHONY: k8s_deploy
k8s_deploy: create_namespace env_secret docker_image_build registry_push build_manifest kube_deploy get_exposed_ip

.PHONY: docker_image_build
docker_image_build:
	docker build --tag $(name) .
	docker tag $(name):latest gcr.io/$(project)/$(prefix)$(name):$(tag)

.PHONY: build_manifest
build_manifest:
	cat ./manifest_template.yaml | sed s/__PULL_POLICY__/$(pull_policy)/g | sed s/__NAMESPACE__/$(prefix)$(stage)/g | sed s/__STAGE__/$(stage)/g | sed s/__IMAGE__/$(prefix)$(name)/g | sed s/__NAME__/$(name)/g | sed s/__PROJECT__/$(project)/g | sed s/__HASH_TAG__/$(tag)/ > ./manifest.yaml

local_dev/gcloud_docker_auth_configured: ${GOOGLE_APPLICATION_CREDENTIALS}
	gcloud auth configure-docker
	touch local_dev/gcloud_docker_auth_configured

.PHONY: registry_push
registry_push: local_dev/gcloud_docker_auth_configured
	docker push gcr.io/$(project)/$(prefix)$(name):$(tag)

.PHONY: kube_deploy
kube_deploy:
	kubectl apply -f ./manifest.yaml

.PHONY: get_exposed_ip
get_exposed_ip:
	@echo "Deployment available at:"
	@kubectl get service $(name) -o json --namespace $(prefix)$(stage)| jq ".status.loadBalancer.ingress[].ip" | sed s/\"//g

.PHONY: teardown_staging
teardown_staging: areyousure
	kubectl delete namespace $(prefix)staging

.PHONY: teardown_development
teardown_development: areyousure
	kubectl delete namespace $(prefix)development

.PHONY: demand_clean
demand_clean:
	@# Check there are no forbidden extensions not tracked by git
	git ls-files --others --exclude-standard | grep -E $(forbidden_untracked_extensions) | xargs -n 1 test -z
	@# Check that there are no local modifications
	git diff-index --quiet HEAD -- && test -z "$(git ls-files --exclude-standard --others)"
	@# Check that we are up to date with remotes
	./kube_maker/makefiles/gitup.sh
	$(eval pull_policy=IfNotPresent)
	$(eval tag=$(shell git rev-parse HEAD))

.PHONY: env_secret
secret_contents ?= $(shell keybase decrypt < $(stage).env.encrypted)
env_secret:
	-echo "$(secret_contents)" | xargs printf -- '--from-literal=%s ' | xargs kubectl create secret generic env --dry-run -o yaml | kubectl apply --namespace $(prefix)$(stage) -f -

.PHONY: create_namespace
create_namespace:
	-kubectl create namespace $(prefix)$(stage)
