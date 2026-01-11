################################################################################
# gitlab module variables
################################################################################

variable "gitlab_config" {
  description = "Configuration for GitLab namespace and runner"
  type = object({
    gitlab_url   = string
    registry_url = string
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

variable "gitlab_sensitive" {
  description = "GitLab runner secrets"
  type = object({
    runner_token = string  # glrt-xxxx format, from GitLab UI
  })
  sensitive = true
}

################################################################################
# end of variables.tf
################################################################################
