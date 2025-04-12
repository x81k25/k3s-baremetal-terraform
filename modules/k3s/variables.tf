variable "server_ip" {
  type = string
}

variable "mounts" {
  type = object({
    k3s_root = string
    media_cache = string
  })
}

variable "kubeconfig_path" {
  type = string
}

variable "k3s_config" {
  description = "K3s Kubernetes configuration settings"
  type = object({
    version       = string
    resource_limits = object({
      cpu_threads = number
      memory_gb   = number
      storage_gb  = number
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