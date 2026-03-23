variable "infra_config" {
  description = "Resource configuration for infra namespace"
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

variable "server_ip" {
  description = "Server IP address for DNS binding"
  type        = string
}

variable "adguard_config" {
  description = "Configuration for AdGuard Home DNS server"
  type = object({
    image_tag      = string
    web_node_port  = number
    dns_node_port  = number
    upstream_dns   = list(string)
    tailscale_ip   = string
    dns_rewrites   = map(string)
    resources = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
  })
}

variable "adguard_secrets" {
  description = "AdGuard Home admin credentials"
  type = object({
    username        = string
    password_bcrypt = string
  })
  sensitive = true
}
