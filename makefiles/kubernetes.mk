.PHONY: k8s_deploy docker_image_build build_manifest registry_push kube_deploy get_exposed_ip teardown_staging teardown_development demand_clean env_secret

k8s_deploy: ca-certificates.crt env_secret docker_image_build registry_push build_manifest create_namespace kube_deploy get_exposed_ip

docker_image_build:
	docker build --tag $(name) .
	docker tag $(name):latest gcr.io/$(project)/$(prefix)$(name):$(tag)

build_manifest:
	cat ./manifest_template.yaml | sed s/__PULL_POLICY__/$(pull_policy)/g | sed s/__STAGE__/$(prefix)$(stage)/g | sed s/__IMAGE__/$(prefix)$(name)/g | sed s/__NAME__/$(name)/g | sed s/__PROJECT__/$(project)/g | sed s/__HASH_TAG__/$(tag)/ > ./manifest.yaml

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
	git diff-index --quiet HEAD -- && test -z "$(git ls-files --exclude-standard --others)"
	$(eval pull_policy=IfNotPresent)
	$(eval tag=`git rev-parse HEAD`)

env_secret:
	cat development.env | xargs printf -- '--from-literal=%s ' | xargs kubectl create secret generic env --namespace $(prefix)development || true
	cat production.env | xargs printf -- '--from-literal=%s ' | xargs kubectl create secret generic env --namespace $(prefix)production || true
	cat staging.env | xargs printf -- '--from-literal=%s ' | xargs kubectl create secret generic env --namespace $(prefix)staging || true

create_namespace:
	kubectl create namespace $(prefix)$(stage)

ca-certificates.crt:
	cp /etc/ssl/certs/ca-certificates.crt .
