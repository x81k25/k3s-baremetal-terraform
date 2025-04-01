################################################################################
# namespaces.tf
#
# creates all namespaces not explictly created by othere modules
# handles dependancies and variables for namespaces without their own exlicit
# modules
#
################################################################################

################################################################################
# ArgoCD namesapces
################################################################################

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

################################################################################
# postgres namespace
################################################################################

resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "pgsql"
    labels = {
      managed-by = "terraform"
    }
  }
}

################################################################################
# end of namespaces.tf
################################################################################
