.PHONY: k8s_deploy docker_image_build build_manifest registry_push kube_deploy get_exposed_ip teardown_staging teardown_development demand_clean env_secret

stage = dummy
pull_policy = Always
uniq:=$(shell uuid)
tag = $(shell whoami)-dev-$(uniq)

k8s_deploy: create_namespace env_secret docker_image_build registry_push build_manifest kube_deploy get_exposed_ip

docker_image_build:
	docker build --tag $(name) .
	docker tag $(name):latest gcr.io/$(project)/$(prefix)$(name):$(tag)

build_manifest:
	cat ./manifest_template.yaml | sed s/__PULL_POLICY__/$(pull_policy)/g | sed s/__NAMESPACE__/$(prefix)$(stage)/g | sed s/__STAGE__/$(stage)/g | sed s/__IMAGE__/$(prefix)$(name)/g | sed s/__NAME__/$(name)/g | sed s/__PROJECT__/$(project)/g | sed s/__HASH_TAG__/$(tag)/ > ./manifest.yaml

registry_push:
	gcloud docker -- push gcr.io/$(project)/$(prefix)$(name):$(tag)

kube_deploy:
	kubectl apply -f ./manifest.yaml

get_exposed_ip:
	@echo "Deployment available at:"
	@kubectl get service $(name) -o json --namespace $(prefix)$(stage)| jq ".status.loadBalancer.ingress[].ip" | sed s/\"//g

teardown_staging: areyousure
	kubectl delete namespace $(prefix)staging

teardown_development: areyousure
	kubectl delete namespace $(prefix)development

demand_clean:
	@# Check there are no forbidden extensions not tracked by git
	git ls-files --others --exclude-standard | grep -E $(forbidden_untracked_extensions) | xargs -n 1 test -z
	@# Check that there are no local modifications
	git diff-index --quiet HEAD -- && test -z "$(git ls-files --exclude-standard --others)"
	@# Check that we are up to date with remotes
	./kube_maker/makefiles/gitup.sh
	$(eval pull_policy=IfNotPresent)
	$(eval tag=`git rev-parse HEAD`)

env_secret:
	-cat development.env | xargs printf -- '--from-literal=%s ' | xargs kubectl create secret generic env --dry-run -o yaml | kubectl apply --namespace $(prefix)development -f -
	-cat production.env | xargs printf -- '--from-literal=%s ' | xargs kubectl create secret generic env --dry-run -o yaml | kubectl apply --namespace $(prefix)production -f -
	-cat staging.env | xargs printf -- '--from-literal=%s ' | xargs kubectl create secret generic env --dry-run -o yaml | kubectl apply --namespace $(prefix)staging -f -

create_namespace:
	-kubectl create namespace $(prefix)$(stage)
