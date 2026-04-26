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
  description = "First static IP for future LXC and VM workloads."
  type        = string
  default     = "10.0.1.21"
}

variable "workload_id_start" {
  description = "First Proxmox VMID/CTID for future managed workloads."
  type        = number
  default     = 120
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
