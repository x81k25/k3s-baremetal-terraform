################################################################################
# observability module variables
################################################################################

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