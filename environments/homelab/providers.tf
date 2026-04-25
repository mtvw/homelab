provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure

  dynamic "ssh" {
    for_each = var.proxmox_ssh_enabled ? [true] : []

    content {
      agent    = var.proxmox_ssh_agent
      username = var.proxmox_ssh_username

      dynamic "node" {
        for_each = local.proxmox_nodes

        content {
          name    = node.value.name
          address = node.value.address
        }
      }
    }
  }
}
