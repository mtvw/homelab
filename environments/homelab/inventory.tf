output "inventory" {
  description = "Current known homelab inventory."
  value = {
    cluster_name  = var.cluster_name
    proxmox_nodes = local.proxmox_nodes
    quorum_device = local.quorum_device
    nas           = local.nas
    pbs = merge(local.pbs, {
      endpoint  = var.pbs.endpoint
      datastore = var.pbs.datastore
      vm_id     = var.pbs_vm.vm_id
      node_name = var.pbs_vm.node_name
    })
    docker = merge(local.docker, {
      vm_id     = var.docker_vm.vm_id
      node_name = var.docker_vm.node_name
    })
    workload_network = {
      cidr       = local.workload_network.cidr
      gateway    = local.workload_network.gateway
      first_host = var.workload_ip_start
      first_id   = var.workload_id_start
    }
  }
}
