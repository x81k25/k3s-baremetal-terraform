locals {
  # Common labels to be applied to all resources
  common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
    "app.kubernetes.io/part-of"    = "argocd"
  }

  # Server URL construction
  server_url = var.argocd_config.ingress.enabled ? (
    "https://${var.argocd_config.ingress.host}"
  ) : null


  # Git repository configuration formatting
  formatted_repositories = {
    for name, repo in var.argocd_config.git_repositories : name => {
      url      = repo.url
      username = try(repo.username, null)
      password = try(repo.password, null)
      sshKey   = try(repo.ssh_key, null)
    } if repo != null
  }
}