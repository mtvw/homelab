# Decisions

## Cluster

- Cluster name: `homelab`.
- Existing Proxmox VE nodes: `pepper` and `salt`.
- The initial Proxmox cluster creation/join is treated as day-0 bootstrap state,
  not as an OpenTofu-managed action.
- API endpoint is IP-based for now: `https://10.0.1.12:8006/`.

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

## Workloads

- Future LXC/VM workload IPs start at `10.0.1.20`.
- Future Proxmox VMID/CTID allocation starts at `120`.
- IP allocations should be tracked centrally in the repo to avoid accidental
  renumbering.
