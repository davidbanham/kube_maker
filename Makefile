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

production: check build demand_clean areyousure stage_production k8s_deploy
staging: check build demand_clean stage_staging k8s_deploy
development: check build stage_development k8s_deploy
