.PHONY: help env-check fmt fmt-check init validate plan apply ansible-syntax ansible-known-hosts ansible-pbs ansible-docker check

TF_ROOT ?= environments/homelab
ENV_FILE ?= .env

ifneq (,$(wildcard $(ENV_FILE)))
include $(ENV_FILE)
export
endif

help:
	@echo "Homelab IaC workflow"
	@echo ""
	@echo "Day-0:"
	@echo "  Read docs/bootstrap.md and complete only the listed bootstrap anchors."
	@echo ""
	@echo "OpenTofu:"
	@echo "  make env-check  Check local credentials"
	@echo "  make init       Initialize OpenTofu"
	@echo "  make validate   Validate OpenTofu config"
	@echo "  make plan       Show planned infra changes"
	@echo "  make apply      Apply infra changes"
	@echo ""
	@echo "Ansible:"
	@echo "  make ansible-known-hosts  Add inventory host SSH keys to known_hosts"
	@echo "  make ansible-pbs  Run PBS configuration playbook"
	@echo "  make ansible-docker  Install Docker on docker hosts"
	@echo ""
	@echo "Quality:"
	@echo "  make fmt        Format OpenTofu files"
	@echo "  make fmt-check  Check OpenTofu formatting"
	@echo "  make check      Run local checks that do not need provider execution"

env-check:
	@test -f "$(ENV_FILE)" || (echo "Missing $(ENV_FILE). Copy .env.example to .env and fill in your token."; exit 1)
	@test -n "$$PROXMOX_VE_ENDPOINT" || (echo "Missing PROXMOX_VE_ENDPOINT in $(ENV_FILE)."; exit 1)
	@test -n "$$PROXMOX_VE_API_TOKEN" || (echo "Missing PROXMOX_VE_API_TOKEN in $(ENV_FILE)."; exit 1)
	@test -n "$$PROXMOX_VE_INSECURE" || (echo "Missing PROXMOX_VE_INSECURE in $(ENV_FILE)."; exit 1)
	@echo "Environment looks usable for OpenTofu."

fmt:
	tofu -chdir=$(TF_ROOT) fmt -recursive

fmt-check:
	tofu -chdir=$(TF_ROOT) fmt -check -recursive

init: env-check
	tofu -chdir=$(TF_ROOT) init

validate: env-check
	tofu -chdir=$(TF_ROOT) validate

plan: env-check
	tofu -chdir=$(TF_ROOT) plan

apply: env-check
	tofu -chdir=$(TF_ROOT) apply

ansible-pbs:
	ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/pbs.yml

ansible-known-hosts:
	ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/known_hosts.yml

ansible-docker:
	ansible-playbook -i ansible/inventory.example.yml ansible/playbooks/docker.yml

ansible-syntax:
	ansible-playbook --syntax-check ansible/playbooks/known_hosts.yml
	ansible-playbook --syntax-check ansible/playbooks/pbs.yml
	ansible-playbook --syntax-check ansible/playbooks/docker.yml

check: fmt-check ansible-syntax
