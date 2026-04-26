# Decisions

## Cluster

- Cluster name: `homelab`.
- Existing Proxmox VE nodes: `pepper` and `salt`.
- The initial Proxmox cluster creation/join is treated as day-0 bootstrap state,
  not as an OpenTofu-managed action.
- API endpoint is IP-based for now: `https://10.0.1.12:8006/`.

## Automation

- This is an automation-first IaC repo. Persistent configuration should live in
  OpenTofu, cloud-init, Ansible or idempotent scripts, not in manual runbooks.
- Standard workflow: OpenTofu creates infrastructure, cloud-init performs first
  boot bootstrap, Ansible configures operating systems and services.
- Terraform/OpenTofu provisioners are avoided for normal OS configuration.
- Manual steps are limited to the day-0 boundary documented in
  `docs/bootstrap.md`.

## Authentication

- OpenTofu uses a dedicated Proxmox API token for `terraform@pve`.
- Credentials live in the local repo-root `.env`, which is ignored by git.
- SSH is disabled by default and will only be enabled when a resource needs it.

## Repositories

- The lab has no Proxmox enterprise subscription.
- Proxmox nodes use the `no-subscription` repository.
- Existing enterprise repository entries are imported into state and disabled
  declaratively.

## Storage

- Current NAS IP: `10.0.1.11`.
- Current known NFS export: `/volume1/media`.
- Planned Proxmox storage ID for that export: `nas_media`.
- PBS should use a separate NAS export, proposed as `/volume1/pbs`, rather than
  sharing the media export.
- `tumuric` is ARM and remains a q-device only. PBS runs as the x86_64 VM
  `pbs01` at `10.0.1.20`.

## Workloads

- Allocated workload VM: `docker01` at `10.0.1.21`, VMID `121`.
- Next free LXC/VM workload IP starts at `10.0.1.22`.
- Next free Proxmox VMID/CTID allocation starts at `122`.
- IP allocations should be tracked centrally in the repo to avoid accidental
  renumbering.
