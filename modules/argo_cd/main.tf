# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argo_cd_config.namespace
    labels = {
      managed-by = "terraform"
    }
  }
}

# create namespace for testing ArgoCD apps
resource "kubernetes_namespace" "argocd_test" {
  metadata {
    name = "argocd-test"
    labels = {
      managed-by = "terraform"
    }
  }
}

# Create secret for ArgoCD admin password
resource "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    # Add this line to set the admin password
    "password" = bcrypt(var.argo_cd_sensitive.admin_pw)
  }

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_secret" "argocd_repo_k8s_manifests" {
  metadata {
    name      = "repo-k8s-manifests"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = var.github_config.k8s_manifests_repo
    username = var.github_config.username
    password = var.github_config.argo_cd_pull_k8s_manifests_token
  }

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_secret" "ghcr_credentials" {
  metadata {
    name      = "ghcr-pull-image-token"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
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

  depends_on = [kubernetes_namespace.argocd]
}

# pass image pull secret to ArgoCD test namespace
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

  depends_on = [kubernetes_namespace.argocd_test]
}

# Install Kustomize CRD
resource "kubernetes_manifest" "kustomize_crd" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind       = "CustomResourceDefinition"
    metadata = {
      name = "kustomizations.kustomize.config.k8s.io"
      annotations = {
        "api-approved.kubernetes.io" = "https://github.com/kubernetes-sigs/kustomize"
      }
    }
    spec = {
      group = "kustomize.config.k8s.io"
      names = {
        kind     = "Kustomization"
        listKind = "KustomizationList"
        plural   = "kustomizations"
        singular = "kustomization"
      }
      scope = "Namespaced"
      versions = [
        {
          name    = "v1"
          served  = true
          storage = true
          schema = {
            openAPIV3Schema = {
              type = "object"
              properties = {
                spec = {
                  type = "object"
                }
                status = {
                  type = "object"
                }
              }
            }
          }
        }
      ]
    }
  }
}

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argo_cd_config.version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Basic configuration
  values = [
    yamlencode({
      server = {
        service = {
          type = var.argo_cd_config.ingress.enabled ? "ClusterIP" : "LoadBalancer"
        }
        ingress = {
          enabled          = var.argo_cd_config.ingress.enabled
          hosts            = var.argo_cd_config.ingress.enabled ? [var.argo_cd_config.ingress.host] : []
          ingressClassName = "traefik"
        }
        extraArgs = [
          "--insecure" # Remove in strict production environments
        ]
        resources = var.argo_cd_config.resource_limits.server
        secretKey = var.argo_cd_sensitive.admin_pw
      }

      repoServer = {
        resources = var.argo_cd_config.resource_limits.repo_server
      }

      controller = {
        resources = var.argo_cd_config.resource_limits.application_controller
        args = {
          "controller.image-pull-secret-propagation.enabled" = "true"
        }
      }

      dex = {
        enabled = var.argo_cd_config.enable_dex
      }

      ha = {
        enabled = var.argo_cd_config.enable_ha
      }

      configs = {
        secret = {
          argocdServerAdminPassword = bcrypt(var.argo_cd_sensitive.admin_pw)
        }
        repositories = {}
        params = {
          "dockercredentials.enableAutoCredentialsPlugin" = "true"
          "dockercredentials.pullSecrets"                 = "[ghcr-pull-image-token]"
        }
      }
    })
  ]

  # Add any extra configurations
  dynamic "set" {
    for_each = var.argo_cd_config.extra_configs
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_secret.argocd_admin_password,
    kubernetes_manifest.kustomize_crd,
    kubernetes_secret.argocd_repo_k8s_manifests
  ]
}

# Wait for ArgoCD to be ready
resource "null_resource" "wait_for_argo" {
  provisioner "local-exec" {
    command = <<EOF
      kubectl wait --for=condition=available \
        --timeout=300s \
        --kubeconfig=${var.kubeconfig_path} \
        -n ${kubernetes_namespace.argocd.metadata[0].name} \
        deployment/argocd-server
    EOF
  }

  depends_on = [helm_release.argocd]
}