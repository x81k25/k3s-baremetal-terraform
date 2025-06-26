################################################################################
# global vars
################################################################################

variable "server_ip" {
  description = "interal ip address of servers hosts cluster"
  type        = string
}

variable "mounts" {
  description = "mounts used by primary services"
  type = object({
    k3s_root    = string
    media_cache = string
  })
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
}

variable "github_config" {
  description = "GitHub and GitHub Container Registry configuration"
  type = object({
    username                         = string
    email                            = string
    k8s_manifests_repo               = string
    argo_cd_pull_k8s_manifests_token = string
    argo_cd_pull_image_token         = string
  })
  sensitive = true
}

variable "pgsql_default_config" {
  description = "global pgsql env vars used for mutliple operations"
  type = object({
    database = string
    prod = object({
      port = string
    })
    stg = object({
      port = string
    })
    dev = object({
      port = string
    })
  })
}

variable "ssh_config" {
  description = "ssh connection paramters used to run null_resources"
  type = object({
    user             = string
    private_key_path = string
  })
  sensitive = true
}

variable "vpn_config" {
  description = "vpn credendtials"
  type = object({
    username = string
    password = string
    config   = string
  })
}

################################################################################
# k3s vars
################################################################################

variable "k3s_config" {
  description = "K3s Kubernetes configuration settings"
  type = object({
    version = string
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
    version  = string
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
    version   = string
    ingress = object({
      enabled = bool
      host    = string
    })
    resource_limits = object({
      server = object({
        cpu    = string
        memory = string
      })
      repo_server = object({
        cpu    = string
        memory = string
      })
      application_controller = object({
        cpu    = string
        memory = string
      })
    })
    git_repositories = map(object({
      url                 = string
      name                = string
      username            = optional(string)
      password_secret_key = optional(string)
    }))
    enable_ha     = bool
    enable_dex    = bool
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
    email    = string
    password = string
  })
  sensitive = true
}

variable "pgsql_config" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    prod = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
    stg = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
    dev = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
  })
  sensitive = true
}

################################################################################
# orchestration vars
################################################################################

variable "dagster_config" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    prod = object({
      home_path      = string
      workspace_path = string
    })
    stg = object({
      home_path      = string
      workspace_path = string
    })
    dev = object({
      home_path      = string
      workspace_path = string
    })
  })
}

variable "dagster_pgsql_config" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    prod = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
    stg = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
    dev = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
  })
  sensitive = true
}

################################################################################
# media vars
################################################################################

variable "environment" {
  description = "Map of environment names"
  type = object({
    dev  = string
    stg  = string
    prod = string
  })
}

variable "media_sensitive" {
  type = object({
    plex_claim = string
  })
  sensitive = true
}

variable "rear_diff_pgsql_config" {
  description = "parameters to connect rear differential API to DB"
  type = object({
    prod = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
    stg = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
    dev = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
  })
  sensitive = true
}

variable "at_config" {
  description = "Configuration variables for at-pipeline"
  type = object({
    prod = map(string)
    stg  = map(string)
    dev  = map(string)
  })
}

variable "at_sensitive" {
  description = "Sensitive configuration variables for at-pipeline"
  type = object({
    prod = map(string)
    stg  = map(string)
    dev  = map(string)
  })
  sensitive = true
}

variable "wst_secrets" {
  description = "contains secrest for wst services running in dagster"
  type = object({
    pgsql = object({
      prod = object({
        username = string
        password = string
      })
      stg = object({
        username = string
        password = string
      })
      dev = object({
        username = string
        password = string
      })
    })
  })
  sensitive = true
}


################################################################################
# ai-ml vars
################################################################################

variable "ai_ml_sensitive" {
  description = "credentials needed for the ai-ml namespace"
  type = object({
    mlflow = object({
      user     = string
      password = string
      db = object({
        prod = object({
          user     = string
          password = string
          name     = string
          port     = string
          database = string
        })
        stg = object({
          user     = string
          password = string
          name     = string
          port     = string
          database = string
        })
        dev = object({
          user     = string
          password = string
          name     = string
          port     = string
          database = string
        })

      })
      artifact_store = object({
        bucket_name = string
      })
    })
    minio = object({
      access_key = string
      secret_key = string
    })
  })
  sensitive = true
}

################################################################################
# observability vars
################################################################################

variable "loki_sensitive" {
  description = "Loki authentication credentials"
  type = object({
    user     = string
    password = string
  })
  sensitive = true
}

variable "grafana_sensitive" {
  description = "Grafana authentication credentials"
  type = object({
    user     = string
    password = string
  })
  sensitive = true
}

################################################################################
# end of variables.tf
################################################################################