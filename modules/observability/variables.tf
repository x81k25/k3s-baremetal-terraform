################################################################################
# observability module variables
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