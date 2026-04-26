# Future LXC and VM resources belong here or in dedicated modules.
#
# Core infrastructure VMs can also get a dedicated file in this directory, such
# as `pbs.tf` for `pbs01`.
#
# IP policy:
# - next free static workload IP starts at 10.0.1.22
# - allocations are recorded centrally in the repo
# - no automatic compaction after deletion unless we intentionally renumber
#
# This avoids accidental IP shifts when an item is removed from the middle of a
# list. "No gaps" and "stable IPs forever" conflict after deletions, so we will
# treat renumbering as an explicit maintenance action.

resource "proxmox_download_file" "docker_debian_cloud_image" {
  count = var.docker_vm.enabled ? 1 : 0

  content_type   = "import"
  datastore_id   = var.docker_vm.image_datastore_id
  node_name      = var.docker_vm.node_name
  url            = var.docker_vm.image_url
  file_name      = var.docker_vm.image_file_name
  upload_timeout = var.docker_vm.image_download_timeout
}

resource "proxmox_virtual_environment_vm" "docker01" {
  count = var.docker_vm.enabled ? 1 : 0

  name        = var.docker_vm.name
  description = "Debian Docker host managed by OpenTofu"
  tags        = var.docker_vm.tags

  node_name = var.docker_vm.node_name
  vm_id     = var.docker_vm.vm_id

  on_boot         = true
  started         = true
  stop_on_destroy = true
  scsi_hardware   = "virtio-scsi-single"

  agent {
    enabled = false
  }

  startup {
    order      = "30"
    up_delay   = "30"
    down_delay = "30"
  }

  cpu {
    cores = var.docker_vm.cores
    type  = var.docker_vm.cpu_type
  }

  memory {
    dedicated = var.docker_vm.memory_mb
  }

  disk {
    datastore_id = var.docker_vm.disk_datastore_id
    discard      = "on"
    import_from  = proxmox_download_file.docker_debian_cloud_image[0].id
    interface    = "scsi0"
    iothread     = true
    size         = var.docker_vm.disk_size
  }

  initialization {
    datastore_id = var.docker_vm.cloud_init_datastore_id
    interface    = "ide2"

    dns {
      servers = var.docker_vm.dns_servers
    }

    ip_config {
      ipv4 {
        address = var.docker_vm.ipv4_address
        gateway = var.docker_vm.ipv4_gateway
      }
    }

    user_account {
      keys     = [trimspace(file(pathexpand(var.docker_vm.ssh_public_key_path)))]
      username = var.docker_vm.ssh_username
    }
  }

  network_device {
    bridge = var.docker_vm.bridge
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}
