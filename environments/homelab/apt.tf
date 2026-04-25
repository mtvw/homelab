resource "proxmox_apt_standard_repository" "no_subscription" {
  for_each = var.manage_apt_repositories ? local.proxmox_nodes : {}

  node   = each.value.name
  handle = "no-subscription"
}

# The enterprise repository is created by default on fresh Proxmox installs.
# It must be imported before OpenTofu can disable it declaratively:
# tofu import 'proxmox_apt_repository.enterprise["pepper"]' 'pepper:/etc/apt/sources.list.d/pve-enterprise.sources:0'
# tofu import 'proxmox_apt_repository.enterprise["salt"]' 'salt:/etc/apt/sources.list.d/pve-enterprise.sources:0'
resource "proxmox_apt_repository" "enterprise" {
  for_each = var.manage_apt_repositories ? local.proxmox_nodes : {}

  node      = each.value.name
  file_path = "/etc/apt/sources.list.d/pve-enterprise.sources"
  index     = 0
  enabled   = false
}
