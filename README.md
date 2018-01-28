Kube Maker
==========

This is a makefile for deploying things to Kubernetes. With one Makefile you can create and deploy to a production or staging environment with a single command.

The makefile also allows you to have a separate development environment for each of your developers on the project. It's really handy for devs to be able to get what's on their laptop onto the cloud quickly and easily so that they can share what they're working on with the rest of the team.

It's got all kinds of cool features like tagging your containers by the SHA of the git commit that describes the code they're running. Want to know what version of the code is running in prod/staging/dev right now? It's right there in the tag.

By default it's set up for Go projects, but it's really simple to adapt it to your language of choice.

It's also set up for Google Kubernetes Engine. It's only a couple of URLs that are specific to that, though, so if you want to use a Kubernetes cluster on different hosting or your own, that should be pretty simple.

## Installation

I recommend you add this to your project as a git submodule. That way it's really easy to get any updates. If you're frightened of git submodules, don't be. They're easy.

```
git submodule add https://github.com/davidbanham/kube_maker
```

Now copy the example head Makefile, environment files and manifest files into your project. These are the bits you'll customise the most, so you want them to be part of your git repo.

```
cp Makefile k8s/manifest_template.yaml *.env ..
```

If you haven't already, add the env files to your gitignore:

```
echo "*.env" >> .gitignore
```

If you don't have kubectl set up, just do [these things](https://cloud.google.com/kubernetes-engine/docs/quickstart). You can bail once you get to the "Deploying an application to the cluster" bit since you have Kube Maker for that.

Now edit the configuration section at the top of that makefile to add your details. You get "project" from GKE and the name an prefix you just make up.

Just `make development` and your thing will be on the internet.

Simples!

## Secrets

The secrets makefile gives you a way to store all your sensitive information in your git repository, but have them protected by public key encryption. The process is made simple with Keybase. If you want to use this feature, [install keybase](https://keybase.io/)

Then you can encrypt your env files with:

```
make production.env.encrypted
```

And bam! Anyone in the keybase team can decrypt the file, but anybody that just compromises the repo can't access them. Pretty neat!

If you're not working on the project with a team, just put your username in `keybase_team` and it'll work like a champ.

## Extension

Remember that anything you define in your head Makefile overrides anything in an included makefile. So if your project is something other than go, or you want a different test or build step, just write your own `check` and `build` tasks in the head Makefile and the tasks in `go.mk` will get ignored.

Kube Maker is really simple. It's just a makefile. Please, please customise it to your individual needs. That's the beauty of installing it as a submodule. You can do your own weird and wonderful things to it and you still have a good way of merging in upstream changes. Just hit that little fork button up there.

Even if you don't want to customise it, please read all of it. The whole thing is like 180 lines. It'll take you 10 minutes and then you'll get it. Do it now.

If you come up with super cool things, please submit a PR! I'd love to check them out.
