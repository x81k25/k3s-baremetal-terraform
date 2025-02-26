# global vars
variable "server_ip" {
  type        = string
  description = "Server IP address"
}

# rancher vars
variable "rancher" {
  description = "rancher config"
  type = object({
    version = string
    hostname = string
  })
}

# cert manager vars
variable "cert_manager" {
  type = object({
    version = string
  })
}


