################################################################################
# global vars
################################################################################

variable "server_ip" {
  description = "internal ip address of servers hosts cluster"
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

variable "github_secrets" {
  description = "github credentials"
  type = object({
    username = string
    token_packages_read = string
  })
  sensitive = true
}

variable "github_secrets_ng" {
  description = "ng github credentials"
  type = object({
    username = string
    token_packages_read = string
  })
  sensitive = true
}

variable "pgsql_default_config" {
  description = "global pgsql env vars used for mutliple operations"
  type = object({
    database = string
    schema   = string
    prod = object({
      host = string
      port = string
    })
    stg = object({
      host = string
      port = string
    })
    dev = object({
      host = string
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

variable "wireguard_secrets" {
  description = "wireguard vpn credentials"
  type = object({
    inteface = object({
      private_key = string
      addreses    = string
      dns         = string
    })
    peer = object({
      public_key  = string
      allowed_ips = string
      endpoint    = string
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
    version = string
    resource_quota = object({
      system_reserved_cpu = string
      system_reserved_memory = string
      kube_reserved_cpu = string
      kube_reserved_memory = string
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
# argo cd vars
################################################################################

variable "argocd_config" {
  type = object({
    namespace = string
    version   = string
    k8s_manifests_repo = string
    ingress = object({
      enabled = bool
      host    = string
    })
    resource_quota = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
    container_defaults = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
    container_overrides = optional(map(object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })), {})
    refresh_config = optional(object({
      reconciliation_timeout  = string
      app_resync_seconds      = number
      repo_cache_expiration   = string
      image_updater_interval  = string
    }), {
      reconciliation_timeout  = "180s"
      app_resync_seconds      = 120
      repo_cache_expiration   = "24h"
      image_updater_interval  = "2m"
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

variable "argocd_secrets" {
  type = object({
    admin_pw = string
    ssh_private_key_path = string
  })
  sensitive = true
}

variable "enable_image_updater" {
  description = "Enable ArgoCD Image Updater"
  type        = bool
  default     = true
}

variable "image_updater_log_level" {
  description = "Log level for ArgoCD Image Updater"
  type        = string
  default     = "info"
  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.image_updater_log_level)
    error_message = "Log level must be one of: debug, info, warn, error"
  }
}

variable "enable_monitoring" {
  description = "Enable ServiceMonitor for Prometheus scraping"
  type        = bool
  default     = false
}

variable "reloader_config" {
  description = "Stakater Reloader configuration for automatic pod restarts on ConfigMap/Secret changes"
  type = object({
    enabled                = bool
    image                  = string
    tag                    = string
    log_level              = string
    auto_reload_all        = bool
    ignore_secrets         = bool
    ignore_configmaps      = bool
    watch_namespace        = optional(string, "")
    metrics_enabled        = bool
    metrics_port           = number
    replicas               = number
    enable_service_monitor = bool
  })
}

################################################################################
# pgsql vars
################################################################################

variable "pgsql_namespace_config" {
  description = "Resource configuration for pgsql namespace"
  type = object({
    resource_quota = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
    container_defaults = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
  })
}

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

variable "minio_config" {
  description = "credentials for minio service"
  type = object({
    uid = string    
    gid = string
    region = string
    path = object({
      root = string
      directories = object({
        data = string
      })
    })
    prod = object({
      port = object({
        external = object({
          console = string
          api     = string
        })
        internal = object({
          api = string
        })
      })
      endpoint = object({
        internal = string
      })
    })
    stg = object({
      port = object({
        external = object({
          console = string
          api     = string
        })
        internal = object({
          api = string
        })
      })
      endpoint = object({
        internal = string
      })
    })
    dev = object({
      port = object({
        external = object({
          console = string
          api     = string
        })
        internal = object({
          api = string
        })
      })
      endpoint = object({
        internal = string
      })
    })
  })
}

variable "minio_secrets" {
  description = "credentials for minio service"
  type = object({
    prod = object({
      access_key = string
      secret_key = string
    })
    stg = object({
      access_key = string
      secret_key = string
    })
    dev = object({
      access_key = string
      secret_key = string
    })
  })
  sensitive = true
}

################################################################################
# media vars
################################################################################

# media namespace resource configuration
variable "media_config" {
  description = "Resource configuration for media namespaces"
  type = object({
    prod = object({
      resource_quota = object({
        cpu_request    = string
        cpu_limit      = string
        memory_request = string
        memory_limit   = string
      })
      container_defaults = object({
        cpu_request    = string
        cpu_limit      = string
        memory_request = string
        memory_limit   = string
      })
    })
    stg = object({
      resource_quota = object({
        cpu_request    = string
        cpu_limit      = string
        memory_request = string
        memory_limit   = string
      })
      container_defaults = object({
        cpu_request    = string
        cpu_limit      = string
        memory_request = string
        memory_limit   = string
      })
    })
    dev = object({
      resource_quota = object({
        cpu_request    = string
        cpu_limit      = string
        memory_request = string
        memory_limit   = string
      })
      container_defaults = object({
        cpu_request    = string
        cpu_limit      = string
        memory_request = string
        memory_limit   = string
      })
    })
  })
}

# media vars
variable "environment" {
  description = "Map of environment names"
  type = object({
    dev  = string
    stg  = string
    prod = string
  })
}

# dagster vars
variable "dagster_vars" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    timezone = string
    path = object({
      prod = object({
        home      = string
        workspace = string
      })
      stg = object({
        home      = string
        workspace = string
      })
      dev = object({
        home      = string
        workspace = string
      })
    })
  })
}

variable "dagster_secrets" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
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
  sensitive = true
}

# plex vars
variable "plex_secrets" {
  type = object({
    claim = string
  })
  sensitive = true
}

# rear diff vars
variable "rear_diff_vars"  {
  description = "rear diff config env vars"
  type = object({
    prefix = string
    prod = object({
      port_external = string
    })
    stg = object({
      port_external = string
    })
    dev = object({
      port_external = string
    })
  })
}

variable "rear_diff_secrets" {
  description = "parameters to connect rear differential API to DB"
  type = object({
    prod = object({
      pgsql = object({
          username = string
          password = string
      })
    })
    stg = object({
      pgsql = object({
        username = string
        password = string
      })
    })
    dev = object({
      pgsql = object({
        username = string
        password = string
      })
    })
  })
  sensitive = true
}

# center-console env vars
variable "center_console_config" {
  description = "env var for center-console UI tool"
  type = object({
    prod = object({
      port_external = string
      api_timeout = string
    })
    stg = object({
      port_external = string
      api_timeout = string
    })
    dev = object({
      port_external = string
      api_timeout = string
    })
  })
}

# transmission env-vars
variable "transmission_vars" {
  description = "Transmission configuration settings per environment"
  type = object({
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

variable "transmission_secrets" {
  description = "Transmission authentication credentials per environment"
  type = object({
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
  sensitive = true
}

# automatic transmission vars
variable "at_vars" {
  description = "Automatic transmission application variables and environment-specific configuration"
  type = object({
    movie_search_api_base_url  = string
    movie_details_api_base_url = string
    movie_ratings_api_base_url = string
    tv_search_api_base_utl     = string
    tv_details_api_base_url    = string
    tv_ratings_api_base_url    = string
    rss_sources                = string
    rss_urls                   = string
    uid                        = string
    gid                        = string
    prod = object({
      batch_size                     = string
      log_level                      = string
      stale_metadata_threshold       = string
      reel_driver_threshold          = string
      target_active_items            = string
      transferred_item_cleanup_delay = string
      hung_item_cleanup_delay        = string
      download_dir                   = string
      movie_dir                      = string
      tv_show_dir                    = string
    })
    stg = object({
      batch_size                     = string
      log_level                      = string
      stale_metadata_threshold       = string
      reel_driver_threshold          = string
      target_active_items            = string
      transferred_item_cleanup_delay = string
      hung_item_cleanup_delay        = string
      uid                            = string
      gid                            = string
      download_dir                   = string
      movie_dir                      = string
      tv_show_dir                    = string
    })
    dev = object({
      batch_size                     = string
      log_level                      = string
      stale_metadata_threshold       = string
      reel_driver_threshold          = string
      target_active_items            = string
      transferred_item_cleanup_delay = string
      hung_item_cleanup_delay        = string
      uid                            = string
      gid                            = string
      download_dir                   = string
      movie_dir                      = string
      tv_show_dir                    = string
    })
  })
}

variable "at_secret_vars" {
  description = "API keys and sensitive configuration for automatic transmission"
  type = object({
    movie_search_api_key  = string
    movie_details_api_key = string
    movie_ratings_api_key = string
    tv_search_api_key     = string
    tv_details_api_key    = string
    tv_ratings_api_key    = string
  })
  sensitive = true
}

# wst vars
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

# ai-ml namespace resource configuration
variable "ai_ml_config" {
  description = "Resource configuration for ai-ml namespace"
  type = object({
    resource_quota = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
    container_defaults = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
  })
}

# gpu configuration for workload scheduling
variable "gpu_config" {
  description = "GPU device configuration for workload scheduling"
  type = object({
    gtx960 = object({
      uuid   = string
      memory = string
    })
    rtx3060 = object({
      uuid   = string
      memory = string
    })
    quota = number
  })
}

# mlflow vars
variable "mlflow_vars" {
  description = "env vars for mflow deployment"
  type = object({
    uid = string
    gid = string
    path = object({
      root = string
      directories = object({
        logs = string
        packages = string
      })
    })
    minio = object({
      default_artifact_root = string
    })
    pgsql = object ({
      database = string
    })
    prod = object ({
      port_external = string
    })
    stg = object ({
      port_external = string
    })
    dev = object ({
      port_external = string
    })
  })
}

# new mlflow config var; mlflow_vars needs to rolled into this
variable "mflow_conifg" {
  description = "hold mlflow env vars"
  type = object({
    prod = object({
      host = object({
        internal = string
      })
      port = object({
        internal = string
      })
    })
    stg = object({
      host = object({
        internal = string
      })
      port = object({
        internal = string
      })
    })
    dev = object({
      host = object({
        internal = string
      })
      port = object({
        internal = string
      })
    })
  })
}

variable "mlflow_secrets" {
  description = "credentials for mlflow instances"
  type = object({
    prod = object({
      username = string
      password = string
      pgsql = object({
        username = string
        password = string
      })
    })
    stg = object({
      username = string
      password = string
      pgsql = object({
        username = string
        password = string
      })
    })
    dev = object({
      username = string
      password = string
      pgsql = object({
        username = string
        password = string
      })
    })
  })
  sensitive = true
}

# reel-driver vars
variable "reel_driver_config" {
  description = "env vars used by the reel-driver API and training containers"
  type = object({
    mlflow = object({
      experiment = string
      model      = string
    })
  })
}

variable "reel_driver_api_config" {
  description = "env vars use by the reel-driver API"
  type = object({
    log_level = string
    prefix = string
    prod = object({
      host = object({
        external = string
        internal = string
      })
      port = object({
        external = string
        internal = string
      })
    })
    stg = object({
      host = object({
        external = string
        internal = string
      })
      port = object({
        external = string
        internal = string
      })
    })
    dev = object({
      host = object({
        external = string
        internal = string
      })
      port = object({
        external = string
        internal = string
      })
    })
  })
}

variable "reel_driver_training_config" {
  description = "env vars used by the reel-driver training containers"
  type = object({
    prod = object({
      hyper_param_search_start = string
    })
    stg = object({
      hyper_param_search_start = string
    })
    dev = object({
      hyper_param_search_start = string
    })
  })
}

################################################################################
# experiments vars
################################################################################

# experiments namespace resource configuration
variable "experiments_config" {
  description = "Resource configuration for experiments namespace"
  type = object({
    resource_quota = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
    container_defaults = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
  })
}

################################################################################
# observability vars
################################################################################

# observability namespace resource configuration
variable "observability_config" {
  description = "Resource configuration for observability namespace"
  type = object({
    resource_quota = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
    container_defaults = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
  })
}

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