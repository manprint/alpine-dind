.PHONY: help build pull push
.PHONY: down stop up up_sysbox start
.PHONY: connect ssh
.PHONY: test_prereq test_postreq test_exec_1 test

export TITLE_MAKEFILE=Makefile Alpine Dind SSH Cron
export RED := $(shell tput setaf 1)
export RESET := $(shell tput sgr0)

export SHELL=bash

export IMAGE=ghcr.io/manprint/alpine-dind:latest
export CONTAINER=alpine-dind
export CONTAINER_HOSTNAME=alpine-dind
export CR_PATH := ${CR_PATH}

export CURRENT_DIR = $(shell pwd)

.DEFAULT := help

help:
	@printf "\n$(RED)$(TITLE_MAKEFILE)$(RESET)\n"
	@awk 'BEGIN {FS = ":.*##"; printf "\n\033[1mUsage:\n  make \033[36m<target>\033[0m\n"} \
	/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-40s\033[0m %s\n", $$1, $$2 } /^##@/ \
	{ printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo

##@ Building image

build: ## Build docker image
	@docker build --force-rm --rm --tag $(IMAGE) .

pull: ## Pull image
	@docker pull $(IMAGE)

push: ## Push image
	@echo "$(RED)Please export CR_PATH (Github Token) variable in local shell...$(RESET)"
	docker login ghcr.io -u manprint -p $(CR_PATH)
	@docker push $(IMAGE)

##@ Container

down: ## Stop and remove dind container (Lost of ephimeral data)
	-@docker stop $(CONTAINER)
	-@docker rm $(CONTAINER)

stop: ## Stop dind container (Preserve ephimeral data)
	@docker stop $(CONTAINER)

up: ## Create and launch privileged container
	@docker run -d \
		--name=$(CONTAINER) \
		--hostname=$(CONTAINER_HOSTNAME) \
		--privileged=true \
		--publish=2375:2375/tcp \
		--publish=2255:22/tcp \
		$(IMAGE)

up_sysbox: ## Create and launch unprivileged container (require sysbox installed)
	@docker run -d \
		--name=$(CONTAINER) \
		--hostname=$(CONTAINER_HOSTNAME) \
		--runtime=sysbox-runc \
		--publish=2375:2375/tcp \
		--publish=2255:22/tcp \
		$(IMAGE)

start: ## Start container (if exist)
	@docker start $(CONTAINER)

##@ Container connection

connect: ## Connect to container (default user: alpine (1000:1000))
	@echo "Wait for docker container $(CONTAINER) ..."
	@sleep 10 # wait for container
	@docker exec -it $(CONTAINER) bash -l

retrive_ssh_pem: ## Retrive ssh pem key in current directory
	@docker cp $(CONTAINER):/home/alpine/.ssh/alpine-dind.pem $(CURRENT_DIR)

ssh: ## Connect via ssh (password: alpine)
	@echo "Wait for ssh service in $(CONTAINER) ..."
	@sleep 10 # wait for ssh
	@sshpass -p alpine ssh -o 'StrictHostKeyChecking no' -p 2255 alpine@localhost

##@ Test suite

test_prereq: down up_sysbox

test_postreq: down

test_exec_1:
	-@sleep 15 # wait for docker
	-@docker cp ./tests/base_suite.sh $(CONTAINER):/home/alpine
	-@docker exec -it $(CONTAINER) ls -alFh /home/alpine
	-@docker exec -it $(CONTAINER) bash -c "/home/alpine/base_suite.sh"
	-@docker stop $(CONTAINER)
	-@docker start $(CONTAINER)
	-@sleep 15 # wait for docker
	-@docker ps -a
	-@docker system df -v
	-@docker exec -it $(CONTAINER) bash -c "docker rm -f alpine"
	-@docker exec -it $(CONTAINER) bash -c "/home/alpine/base_suite.sh"
	-@echo

test: test_prereq test_exec_1 test_postreq ## Run test suite