################################################################################
# global vars
################################################################################

variable "server_ip" {
  type        = string
  description = "Server IP address"
}

variable "kubeconfig_path" {
  type = string
}

################################################################################
# rancher vars
################################################################################

variable "cattle_system_config" {
  description = "Resource configuration for cattle-system namespace"
  type = object({
    resource_quota = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
  })
}

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

variable "cert_manager_config" {
  type = object({
    version = string
    resource_quota = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
  })
}

################################################################################
# end of variables.tf
################################################################################

