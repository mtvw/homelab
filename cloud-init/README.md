# cloud-init

Deze map bevat cloud-init templates en snippets voor machines die door
OpenTofu in Proxmox worden aangemaakt.

Gebruik cloud-init alleen voor eerste-boot bootstrap:

- hostname
- netwerk
- SSH keys
- basispackages die nodig zijn voor Ansible
- een bootstrap user indien nodig

Serviceconfiguratie hoort in Ansible. Voorbeelden: PBS installeren, NFS mounts,
datastores, users, tokens, ACL's en scheduled jobs.
