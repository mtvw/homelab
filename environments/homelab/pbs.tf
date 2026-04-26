# PBS VM
#
# `pbs01` is a core infrastructure VM. It must be created by OpenTofu before
# the Ansible PBS playbook can configure it.
#
# Intended lifecycle:
# 1. OpenTofu creates the Debian/x86_64 VM with cloud-init.
# 2. cloud-init configures hostname, static IP and SSH access.
# 3. Ansible configures Proxmox Backup Server inside the VM.
# 4. OpenTofu can add PBS as Proxmox storage after token/fingerprint exist.
#
# The actual VM resource is intentionally not added yet because we still need to
# settle the local Proxmox provider validation issue and confirm the base Debian
# cloud image/template strategy.
