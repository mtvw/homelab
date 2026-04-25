# Planned NFS storage:
#
# - storage ID: nas_media
# - server: 10.0.1.11
# - export: /volume1/media
# - nodes: pepper, salt
#
# This is intentionally not active yet. Before OpenTofu manages this resource,
# confirm the NAS export path as Proxmox sees it with:
#
# pvesm nfsscan 10.0.1.11
#
# I also want to verify the exact current provider schema for v0.103.0 on this
# machine; the local provider handshake currently fails during `tofu validate`.
