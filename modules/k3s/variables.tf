variable "k3s" {
  description = "K3s Kubernetes configuration settings"
  type = object({
    version        = string
    server_ip      = string
    resource_limits = object({
      cpu_threads = number
      memory_gb   = number
      storage_gb  = number
    })
    mount_points = object({
      k3s_root    = string
      postgres    = string
      media_cache = string
    })
    network_config = object({
      network_subnet = string
      cni_plugin     = string
      host_ip        = string
      cluster_dns    = string
      interface_name = string
      service_subnet = string
    })
    backup_config = object({
      enabled         = bool
      retention_days  = number
      backup_location = string
    })
  })
}