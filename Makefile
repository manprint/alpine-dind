.PHONY: help build build_no_cache pull publish clean_docker_build
.PHONY: volume_prune down stop up up_sysbox start
.PHONY: connect retrive_ssh_pem ssh
.PHONY: context_create context_enable context_disable context_remove
.PHONY: test_prereq test_postreq test_exec_1 test

export TITLE_MAKEFILE=Makefile Alpine Dind SSH Cron Terraform
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

build_no_cache: ## Build docker image
	@docker build --no-cache --force-rm --rm --tag $(IMAGE) .

clean_docker_build: ## Clear docker build structure
	@echo "y" | docker image prune
	@echo "y" | docker builder prune

pull: ## Pull image
	@docker pull $(IMAGE)

publish: ## Push image
	@echo "$(RED)Create in repo folder the "github.token" file for publish image...$(RESET)"
	$(MAKE) build_no_cache
	cat github.token | docker login ghcr.io -u manprint --password-stdin
	@docker push $(IMAGE)
	$(MAKE) clean_docker_build

##@ Container

volume_prune: ## Remove dangling volume
	-@echo "y" | docker volume prune 

down: ## Stop and remove dind container (Lost of ephimeral data)
	-@docker stop $(CONTAINER)
	-@docker rm $(CONTAINER)
	$(MAKE) volume_prune

stop: ## Stop dind container (Preserve ephimeral data)
	@docker stop $(CONTAINER)

up: ## Create and launch privileged container
	@docker run -d \
		--name=$(CONTAINER) \
		--hostname=$(CONTAINER_HOSTNAME) \
		--privileged=true \
		--publish=2375:2375/tcp \
		--publish=2255:22/tcp \
		--publish=8888:8888/tcp \
		$(IMAGE)

up_sysbox: ## Create and launch unprivileged container (require sysbox installed)
	@docker run -d \
		--name=$(CONTAINER) \
		--hostname=$(CONTAINER_HOSTNAME) \
		--runtime=sysbox-runc \
		--publish=2375:2375/tcp \
		--publish=2255:22/tcp \
		--publish=8888:8888/tcp \
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

chrome_webssh: ## Open chrome webssh
	@google-chrome "http://localhost:8888/?hostname=localhost&username=alpine&password=YWxwaW5l&title=$(CONTAINER)" > /dev/null 2>&1 &

firefox_webssh: ## Open firefox webssh
	@firefox "http://localhost:8888/?hostname=localhost&username=alpine&password=YWxwaW5l&title=$(CONTAINER)" > /dev/null 2>61 &

##@ Docker context

context_create: ## Create docker context for dind container
	@docker context create $(CONTAINER) \
		--description "Docker Dind Alpine" \
		--docker "host=tcp://localhost:2375"

context_enable: ## Enable context for dind container
	@docker context use $(CONTAINER)

context_disable: ## Disable context for dind (switch to default)
	@docker context use default

context_remove: context_disable ## Disable dind context, switch to default and remove
	@docker context rm $(CONTAINER)

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
