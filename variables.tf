################################################################################
# global vars
################################################################################

variable "server_ip" {
  type = string
}

variable "mounts" {
  type = object({
    k3s_root = string
    postgres = string
    media_cache = string
  })
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
}

################################################################################
# secure vars
################################################################################

variable "github_config" {
  description = "GitHub and GitHub Container Registry configuration"
  type = object({
    username         = string
    email            = string
    k8s_manifests_repo = string
    argo_cd_pull_k8s_manifests_token = string
    argo_cd_pull_image_token = string
  })
  sensitive = true
}

################################################################################
# k3s vars
################################################################################

variable "k3s_config" {
  description = "K3s Kubernetes configuration settings"
  type = object({
    version        = string
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

################################################################################
# rancher vars
################################################################################

# rancher vars
variable "rancher_config" {
  description = "rancher config"
  type = object({
    version = string
    hostname = string
    ingress_config = object({
      http_enabled     = bool
      https_enabled    = bool
      additional_ports = list(number)
    })
  })
}

variable "rancher_sensitive" {
  type = object({
    admin_pw = string
  })
  sensitive = true
}

# cert manager vars
variable "cert_manager_config" {
  type = object({
    version = string
  })
}

################################################################################
# argo cd vars
################################################################################

variable "argo_cd_config" {
  type = object({
    namespace = string
    version = string
    ingress = object({
      enabled = bool
      host = string
    })
    resource_limits = object({
      server =  object({
        cpu = string
        memory = string
      })
      repo_server =  object({
        cpu = string
        memory = string
      })
      application_controller =  object({
        cpu = string
        memory = string
      })
    })
    git_repositories = map(object({
      url = string
      name = string
      username = optional(string)
      password_secret_key = optional(string)
    }))
    enable_ha = bool
    enable_dex = bool
    extra_configs = map(any)
  })
}

variable "argo_cd_sensitive" {
  type = object({
    admin_pw = string
  })
}

################################################################################
# end of variables.tf
################################################################################