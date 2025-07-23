################################################################################
# argocd vars
################################################################################

variable "argocd_config" {
  type = object({
    namespace = string
    version   = string
    k8s_manifests_repo = string
    kubeconfig_path = string
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
    refresh_config = object({
      reconciliation_timeout  = string
      app_resync_seconds      = number
      repo_cache_expiration   = string
      image_updater_interval  = string
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
    github = object({
      username = string
      token_packages_read = string
    })
  })
  sensitive = true
}

################################################################################
# argocd image updater vars
################################################################################

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
# end of variables.tf
################################################################################