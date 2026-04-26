variable "proxmox_endpoint" {
  description = "Proxmox API endpoint. Prefer a stable cluster DNS name or VIP when available."
  type        = string
  default     = "https://10.0.1.12:8006/"
}

variable "proxmox_insecure" {
  description = "Allow the self-signed Proxmox API certificate during bootstrap."
  type        = bool
  default     = true
}

variable "proxmox_ssh_enabled" {
  description = "Enable provider SSH support for resources that need SSH, such as snippets or some file uploads."
  type        = bool
  default     = false
}

variable "proxmox_ssh_agent" {
  description = "Use the local SSH agent for provider operations that need SSH."
  type        = bool
  default     = true
}

variable "proxmox_ssh_username" {
  description = "SSH username for provider operations that need SSH. Leave null for API-only usage."
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Documented desired Proxmox cluster name."
  type        = string
  default     = "homelab"
}

variable "manage_apt_repositories" {
  description = "Manage Proxmox no-subscription APT repositories on all PVE nodes."
  type        = bool
  default     = true
}

variable "nfs_storages" {
  description = "NAS exports that should become Proxmox NFS storages once confirmed."
  type = map(object({
    export        = string
    content_types = list(string)
    nodes         = optional(list(string))
  }))
  default = {
    nas_media = {
      export        = "/volume1/media"
      content_types = ["images", "iso", "vztmpl", "backup", "snippets"]
      nodes         = ["pepper", "salt"]
    }
  }
}

variable "workload_ip_start" {
  description = "Next available static IP for future LXC and VM workloads."
  type        = string
  default     = "10.0.1.23"
}

variable "workload_id_start" {
  description = "Next available Proxmox VMID/CTID for future managed workloads."
  type        = number
  default     = 123
}

variable "pbs" {
  description = "PBS endpoint metadata. PBS storage resources will be enabled after credentials/datastore are confirmed."
  type = object({
    endpoint  = string
    datastore = string
  })
  default = {
    endpoint  = "10.0.1.20"
    datastore = "pbs-main"
  }
}

variable "pbs_vm" {
  description = "OpenTofu-managed VM configuration for the Proxmox Backup Server host."
  type = object({
    enabled                 = optional(bool, true)
    name                    = optional(string, "pbs01")
    vm_id                   = optional(number, 120)
    node_name               = optional(string, "pepper")
    ipv4_address            = optional(string, "10.0.1.20/24")
    ipv4_gateway            = optional(string, "10.0.1.1")
    dns_servers             = optional(list(string), ["10.0.1.1"])
    bridge                  = optional(string, "vmbr0")
    image_url               = optional(string, "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2")
    image_file_name         = optional(string, "debian-13-genericcloud-amd64.qcow2")
    image_datastore_id      = optional(string, "local")
    image_download_timeout  = optional(number, 1800)
    disk_datastore_id       = optional(string, "local-lvm")
    cloud_init_datastore_id = optional(string, "local-lvm")
    disk_size               = optional(number, 32)
    cores                   = optional(number, 2)
    memory_mb               = optional(number, 4096)
    cpu_type                = optional(string, "x86-64-v2-AES")
    ssh_username            = optional(string, "debian")
    ssh_public_key_path     = optional(string, "~/.ssh/id_ed25519.pub")
    tags                    = optional(list(string), ["terraform", "core", "pbs"])
  })
  default = {}
}

variable "docker_vm" {
  description = "OpenTofu-managed Debian VM configuration for running Docker containers."
  type = object({
    enabled                 = optional(bool, true)
    name                    = optional(string, "docker01")
    vm_id                   = optional(number, 121)
    node_name               = optional(string, "pepper")
    ipv4_address            = optional(string, "10.0.1.21/24")
    ipv4_gateway            = optional(string, "10.0.1.1")
    dns_servers             = optional(list(string), ["10.0.1.1"])
    bridge                  = optional(string, "vmbr0")
    image_url               = optional(string, "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2")
    image_file_name         = optional(string, "docker01-debian-13-genericcloud-amd64.qcow2")
    image_datastore_id      = optional(string, "local")
    image_download_timeout  = optional(number, 1800)
    disk_datastore_id       = optional(string, "local-lvm")
    cloud_init_datastore_id = optional(string, "local-lvm")
    disk_size               = optional(number, 64)
    cores                   = optional(number, 4)
    memory_mb               = optional(number, 8192)
    cpu_type                = optional(string, "x86-64-v2-AES")
    ssh_username            = optional(string, "debian")
    ssh_public_key_path     = optional(string, "~/.ssh/id_ed25519.pub")
    tags                    = optional(list(string), ["terraform", "workload", "docker"])
  })
  default = {}
}

variable "jellyfin_lxc" {
  description = "OpenTofu-managed Debian LXC configuration for Jellyfin."
  type = object({
    enabled                   = optional(bool, true)
    name                      = optional(string, "jellyfin01")
    vm_id                     = optional(number, 122)
    node_name                 = optional(string, "pepper")
    ipv4_address              = optional(string, "10.0.1.22/24")
    ipv4_gateway              = optional(string, "10.0.1.1")
    dns_servers               = optional(list(string), ["10.0.1.1"])
    bridge                    = optional(string, "vmbr0")
    template_url              = optional(string, "http://download.proxmox.com/images/system/debian-13-standard_13.1-2_amd64.tar.zst")
    template_file_name        = optional(string, "debian-13-standard_13.1-2_amd64.tar.zst")
    template_datastore_id     = optional(string, "local")
    template_download_timeout = optional(number, 1800)
    disk_datastore_id         = optional(string, "local-lvm")
    disk_size                 = optional(number, 32)
    cores                     = optional(number, 2)
    memory_mb                 = optional(number, 4096)
    swap_mb                   = optional(number, 512)
    ssh_public_key_path       = optional(string, "~/.ssh/id_ed25519.pub")
    tags                      = optional(list(string), ["terraform", "workload", "jellyfin"])
  })
  default = {}
}
