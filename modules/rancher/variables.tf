variable "rancher_hostname" {
  type        = string
  description = "Hostname for Rancher"
}

variable "rancher_password" {
  type        = string
  description = "Admin password for Rancher"
  sensitive   = true
}

variable "server_ip" {
  type        = string
  description = "Server IP address"
}

variable "rancher_version" {
  type        = string
  description = "Version of Rancher to install"
}

variable "cert_manager_version" {
  type        = string
  description = "Version of cert-manager to install"
}