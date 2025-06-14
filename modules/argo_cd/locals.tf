locals {
  # Common labels to be applied to all resources
  common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
    "app.kubernetes.io/part-of"    = "argocd"
  }

  # Server URL construction
  server_url = var.argo_cd_config.ingress.enabled ? (
    "https://${var.argo_cd_config.ingress.host}"
  ) : null

  # Resource limits with defaults merged
  resource_limits = {
    server = merge({
      cpu    = "500m"
      memory = "512Mi"
    }, try(var.argo_cd_config.resource_limits.server, {}))

    repo_server = merge({
      cpu    = "500m"
      memory = "512Mi"
    }, try(var.argo_cd_config.resource_limits.repo_server, {}))

    application_controller = merge({
      cpu    = "500m"
      memory = "512Mi"
    }, try(var.argo_cd_config.resource_limits.application_controller, {}))
  }

  # Git repository configuration formatting
  formatted_repositories = {
    for name, repo in var.argo_cd_config.git_repositories : name => {
      url      = repo.url
      username = try(repo.username, null)
      password = try(repo.password, null)
      sshKey   = try(repo.ssh_key, null)
    } if repo != null
  }
}