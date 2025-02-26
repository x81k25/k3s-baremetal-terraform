# Keep these implementation-specific variables:
variable "namespace" {
  description = "Kubernetes namespace for ArgoCD installation"
  type        = string
  default     = "argocd"
}

variable "argocd_version" {
  description = "Version of ArgoCD Helm chart to install"
  type        = string
  default     = "5.51.4"
}

variable "ingress_enabled" {
  description = "Enable ingress for ArgoCD server"
  type        = bool
  default     = false
}

variable "ingress_host" {
  description = "Hostname for ArgoCD ingress"
  type        = string
  default     = ""
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]+[a-zA-Z0-9]$", var.ingress_host)) || var.ingress_host == ""
    error_message = "The ingress_host must be a valid DNS name."
  }
}

variable "resource_limits" {
  description = "Resource limits for ArgoCD components"
  type = object({
    server = optional(object({
      cpu    = optional(string, "500m")
      memory = optional(string, "512Mi")
    }), {})
    repo_server = optional(object({
      cpu    = optional(string, "500m")
      memory = optional(string, "512Mi")
    }), {})
    application_controller = optional(object({
      cpu    = optional(string, "500m")
      memory = optional(string, "512Mi")
    }), {})
  })
  default = {}
}

variable "git_repositories" {
  description = "Map of Git repositories to configure in ArgoCD"
  type = map(object({
    url            = string
    username       = optional(string)
    password       = optional(string)
    ssh_key        = optional(string)
    default_branch = optional(string, "main")
  }))
  default = {}
}

variable "ghcr_username" {
  description = "GitHub Container Registry username"
  type        = string
  sensitive   = true
}

variable "ghcr_pull_image_token" {
  description = "GitHub Container Registry token"
  type        = string
  sensitive   = true
}

variable "enable_ha" {
  description = "Enable high availability mode for ArgoCD"
  type        = bool
  default     = false
}

variable "enable_dex" {
  description = "Enable Dex for SSO integration"
  type        = bool
  default     = false
}

variable "extra_configs" {
  description = "Additional configurations to pass to ArgoCD helm chart"
  type        = map(any)
  default     = {}
}

variable "argocd_admin_password" {
  description = "Admin password for ArgoCD"
  type        = string
  sensitive   = true
}