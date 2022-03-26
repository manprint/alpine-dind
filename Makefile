.PHONY: help build

export TITLE_MAKEFILE=Makefile Alpine Dind SSH Cron
export RED := $(shell tput setaf 1)
export RESET := $(shell tput sgr0)

export SHELL=bash

export IMAGE=fabiop85/alpine-ssh-docker:latest
export CONTAINER=alpine-ssh-docker
export CONTAINER_HOSTNAME=alpine

.DEFAULT := help

help:
	@printf "\n$(RED)$(TITLE_MAKEFILE)$(RESET)\n"
	@awk 'BEGIN {FS = ":.*##"; printf "\n\033[1mUsage:\n  make \033[36m<target>\033[0m\n"} \
	/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-40s\033[0m %s\n", $$1, $$2 } /^##@/ \
	{ printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo

##@ Building image

build: ## Build docker image
	@docker build --force-rm --rm --tag fabiop85/alpine-ssh-docker:latest .


##@ Container

down: ## Stop and remove dind container (Lost of ephimeral data)
	@docker stop $(CONTAINER)
	@docker rm $(CONTAINER)

stop: ## Stop dind container (Preserve ephimeral data)
	@docker stop $(CONTAINER)

up: ## Create and launch container
	@docker run -d \
		--name=$(CONTAINER) \
		--hostname=$(CONTAINER_HOSTNAME) \
		--privileged=true \
		--publish=2375:2375/tcp \
		--publish=2255:22/tcp \
		$(IMAGE)

start: ## Start container (if exist)
	@docker start $(CONTAINER)

##@ Container connection

connect: ## Connect to container (default user: alpine (1000:1000))
	@docker exec -it $(CONTAINER) bash -l

ssh: ## Connect via ssh (password: alpine)
	@ssh -p 2255 alpine@localhost