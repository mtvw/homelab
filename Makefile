.PHONY: env-check fmt init validate plan apply ansible-pbs

TF_ROOT ?= environments/homelab
ENV_FILE ?= .env

ifneq (,$(wildcard $(ENV_FILE)))
include $(ENV_FILE)
export
endif

env-check:
	@test -f "$(ENV_FILE)" || (echo "Missing $(ENV_FILE). Copy .env.example to .env and fill in your token."; exit 1)
	@test -n "$$PROXMOX_VE_ENDPOINT" || (echo "Missing PROXMOX_VE_ENDPOINT in $(ENV_FILE)."; exit 1)
	@test -n "$$PROXMOX_VE_API_TOKEN" || (echo "Missing PROXMOX_VE_API_TOKEN in $(ENV_FILE)."; exit 1)
	@test -n "$$PROXMOX_VE_INSECURE" || (echo "Missing PROXMOX_VE_INSECURE in $(ENV_FILE)."; exit 1)
	@echo "Environment looks usable for OpenTofu."

fmt:
	tofu -chdir=$(TF_ROOT) fmt -recursive

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
