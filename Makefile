.PHONY production staging deveopment

include ./kube_maker/makefiles/*.mk

# Config
name = boilerplate
prefix = catchall-
project = somproject-000000

stage = dummy
pull_policy = Always
uniq:=$(shell uuid)
tag = `whoami`-dev-$(uniq)

production: test build demand_clean areyousure stage_production k8s_deploy
staging: test build demand_clean stage_staging k8s_deploy
development: test build stage_development k8s_deploy
