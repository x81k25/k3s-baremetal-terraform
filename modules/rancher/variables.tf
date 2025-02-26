# global vars
variable "server_ip" {
  type        = string
  description = "Server IP address"
}

# rancher vars
variable "rancher_config" {
  description = "rancher config"
  type = object({
    version = string
    hostname = string
    
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


