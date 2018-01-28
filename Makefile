.PHONY: production staging deveopment

include ./kube_maker/makefiles/*.mk

# Config
name = boilerplate
prefix = catchall-
project = somproject-000000
keybase_team = davidbanham

stage = dummy
pull_policy = Always
uniq:=$(shell uuid)
tag = `whoami`-dev-$(uniq)

production: $(eval stage=production) check build demand_clean areyousure k8s_deploy
staging: $(eval stage=staging) check build demand_clean k8s_deploy
development: $(eval stage=development) check build k8s_deploy

submodules:
	git submodule update --init --recursive
