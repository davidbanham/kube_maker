.PHONY: production staging development

include ./kube_maker/makefiles/*.mk

# Config
name = boilerplate
prefix = catchall-
project = someproject-000000
keybase_team = notbad.example
forbidden_untracked_extensions = '\.go|\.js'

stage = dummy
pull_policy = Always
uniq:=$(shell uuid)
tag = `whoami`-dev-$(uniq)

production: stage_production check build demand_clean areyousure k8s_deploy
staging: stage_staging check build demand_clean k8s_deploy
development: stage_development check build k8s_deploy

submodules:
	git submodule update --init --recursive
