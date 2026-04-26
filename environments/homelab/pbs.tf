resource "proxmox_download_file" "pbs_debian_cloud_image" {
  count = var.pbs_vm.enabled ? 1 : 0

  content_type   = "import"
  datastore_id   = var.pbs_vm.image_datastore_id
  node_name      = var.pbs_vm.node_name
  url            = var.pbs_vm.image_url
  file_name      = var.pbs_vm.image_file_name
  upload_timeout = var.pbs_vm.image_download_timeout
}

resource "proxmox_virtual_environment_vm" "pbs01" {
  count = var.pbs_vm.enabled ? 1 : 0

  name        = var.pbs_vm.name
  description = "Proxmox Backup Server host managed by OpenTofu"
  tags        = var.pbs_vm.tags

  node_name = var.pbs_vm.node_name
  vm_id     = var.pbs_vm.vm_id

  on_boot         = true
  started         = true
  stop_on_destroy = true
  scsi_hardware   = "virtio-scsi-single"

  agent {
    enabled = false
  }

  startup {
    order      = "20"
    up_delay   = "30"
    down_delay = "30"
  }

  cpu {
    cores = var.pbs_vm.cores
    type  = var.pbs_vm.cpu_type
  }

  memory {
    dedicated = var.pbs_vm.memory_mb
  }

  disk {
    datastore_id = var.pbs_vm.disk_datastore_id
    discard      = "on"
    import_from  = proxmox_download_file.pbs_debian_cloud_image[0].id
    interface    = "scsi0"
    iothread     = true
    size         = var.pbs_vm.disk_size
  }

  initialization {
    datastore_id = var.pbs_vm.cloud_init_datastore_id
    interface    = "ide2"

    dns {
      servers = var.pbs_vm.dns_servers
    }

    ip_config {
      ipv4 {
        address = var.pbs_vm.ipv4_address
        gateway = var.pbs_vm.ipv4_gateway
      }
    }

    user_account {
      keys     = [trimspace(file(pathexpand(var.pbs_vm.ssh_public_key_path)))]
      username = var.pbs_vm.ssh_username
    }
  }

  network_device {
    bridge = var.pbs_vm.bridge
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}
