################################################################################
# global vars
################################################################################

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
}

variable "github_config" {
  description = "GitHub and GitHub Container Registry configuration"
  type = object({
    username                         = string
    email                            = string
    k8s_manifests_repo               = string
    argo_cd_pull_k8s_manifests_token = string
    argo_cd_pull_image_token         = string
  })
  sensitive = true
}

################################################################################
# argocd vars
################################################################################

variable "argo_cd_config" {
  type = object({
    namespace = string
    version   = string
    ingress = object({
      enabled = bool
      host    = string
    })
    resource_limits = object({
      server = object({
        cpu    = string
        memory = string
      })
      repo_server = object({
        cpu    = string
        memory = string
      })
      application_controller = object({
        cpu    = string
        memory = string
      })
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

variable "argo_cd_sensitive" {
  type = object({
    admin_pw = string
  })
}

################################################################################
# end of variables.tf
################################################################################