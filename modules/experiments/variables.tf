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

variable "experiments_secrets" {
  description = "namespace-level secrets for experiments services"
  type = object({
    github = object({
      username = string
      token_packages_read = string
    })
    github_secrets_ng = object({
      username = string
      token_packages_read = string
    })
  })
  sensitive = true
}