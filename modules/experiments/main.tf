resource "kubernetes_namespace" "experiments" {
  metadata {
    name = "experiments"
    labels = {
      "managed-by" = "terraform"
    }
  }
}

# Create GitHub Container Registry secret
resource "kubernetes_secret" "ng_github_registry" {
  metadata {
    name      = "ng-github-registry"
    namespace = kubernetes_namespace.experiments.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          username = var.ng_github_secrets.username
          password = var.ng_github_secrets.token_packages_read
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}