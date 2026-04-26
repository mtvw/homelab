locals {
  proxmox_nodes = {
    pepper = {
      name    = "pepper"
      address = "10.0.1.12"
      role    = "pve"
    }
    salt = {
      name    = "salt"
      address = "10.0.1.13"
      role    = "pve"
    }
  }

  quorum_device = {
    name    = "tumuric"
    address = "10.0.1.14"
    role    = "qdevice"
  }

  pbs = {
    name    = var.pbs_vm.name
    address = var.pbs.endpoint
    role    = "pbs"
  }

  docker = {
    name    = var.docker_vm.name
    address = split("/", var.docker_vm.ipv4_address)[0]
    role    = "docker"
  }

  nas = {
    address = "10.0.1.11"
    role    = "nfs"
  }

  workload_network = {
    cidr       = "10.0.1.0/24"
    gateway    = "10.0.1.1"
    first_host = "10.0.1.21"
  }
}
