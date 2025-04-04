################################################################################
# global vars
################################################################################

variable "server_ip" {
  description = "interal ip address of servers hosts cluster"
  type = string
}

variable "mounts" {
  description = "mounts used by primary services"
  type = object({
    k3s_root = string
    media_cache = string
  })
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
}

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

variable "ssh_config" {
  description = "ssh connection paramters used to run null_resources"
  type = object({
    user = string
    private_key_path = string
  })
  sensitive = true
}

variable "pgsql_config" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    prod = object({
      user = string
      password = string
      database = string
      mount = string
      performance = object({
        shared_buffers = number
        work_mem = number
        maintenance_work_mem = number
        max_connections = number
        effective_cache_size = number
      })
      security = object({
        UID = number
        GID = number 
      })
    })
    stg = object({
      user = string
      password = string
      database = string
      mount = string
      performance = object({
        shared_buffers = number
        work_mem = number
        maintenance_work_mem = number
        max_connections = number
        effective_cache_size = number
      })
      security = object({
        UID = number
        GID = number 
      })
    })
    dev = object({
      user = string
      password = string
      database = string
      mount = string
      performance = object({
        shared_buffers = number
        work_mem = number
        maintenance_work_mem = number
        max_connections = number
        effective_cache_size = number
      })
      security = object({
        UID = number
        GID = number 
      })
    })
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
# pgsql vars
################################################################################

variable "pgadmin4_config" {
  description = "config vars for the pgadmin4 web app"
  type = object({
    email = string
    password = string
    UID = number
    GID = number
    fs_group = number
    mount = string
    port = number
    server_mode = bool
    listen_address = string
    listen_port = number
  })
  sensitive = true
}

################################################################################
# plex vars
################################################################################

variable "media_sensitive" {
  type = object({
    plex_claim = string
  })
  sensitive = true
}

################################################################################
# end of variables.tf
################################################################################