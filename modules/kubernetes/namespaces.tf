resource "kubernetes_namespace" "argocd_test" {
  metadata {
    name = "argocd-test"
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_secret" "ghcr_argocd_test" {
  metadata {
    name      = "ghcr-pull-image-token"
    namespace = "argocd-test"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          username = var.github_config.username
          password = var.github_config.argo_cd_pull_image_token
        }
      }
    })
  }
}

resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_namespace" "automatic_transmission" {
  metadata {
    name = "automatic-transmission"
    labels = {
      managed-by = "terraform"
    }
  }
}