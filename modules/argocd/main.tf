################################################################################
# k8s namespaces
################################################################################

# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_config.namespace
    labels = {
      managed-by = "terraform"
    }
  }
}

################################################################################
# namespace resource quotas
################################################################################

resource "kubernetes_resource_quota" "argocd_quota" {
  metadata {
    name      = "argocd-resource-quota"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.argocd_config.resource_quota.cpu_request
      "limits.cpu"      = var.argocd_config.resource_quota.cpu_limit
      "requests.memory" = var.argocd_config.resource_quota.memory_request
      "limits.memory"   = var.argocd_config.resource_quota.memory_limit
    }
  }
}


################################################################################
# ArgoCD base env vars & secrets
################################################################################

# secrets
resource "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    "password" = bcrypt(var.argocd_secrets.admin_pw)
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
    type          = "git"
    url           = var.argocd_config.k8s_manifests_repo
    sshPrivateKey = file(var.argocd_secrets.ssh_private_key_path)
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
          username = "token"
          password = var.argocd_secrets.github.token_packages_read
        }
      }
    })
  }

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_secret" "ghcr_image_updater_pull" {
  metadata {
    name      = "ghcr-image-updater-pull"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          auth = base64encode("${var.argocd_secrets.github.username}:${var.argocd_secrets.github.token_packages_read}")
        }
      }
    })
  }

  depends_on = [kubernetes_namespace.argocd]
}

# SSH key for Git repository access
resource "kubernetes_secret" "argocd_ssh_key" {
  metadata {
    name      = "argocd-ssh-key"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  
  data = {
    sshPrivateKey = file(var.argocd_secrets.ssh_private_key_path)
  }

  depends_on = [kubernetes_namespace.argocd]
}


################################################################################
# ArgoCD install
################################################################################

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_config.version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Basic configuration
  values = [
    yamlencode({
      server = {
        service = {
          type = var.argocd_config.ingress.enabled ? "ClusterIP" : "LoadBalancer"
        }
        ingress = {
          enabled          = var.argocd_config.ingress.enabled
          hosts            = var.argocd_config.ingress.enabled ? [var.argocd_config.ingress.host] : []
          ingressClassName = "traefik"
        }
        extraArgs = [
          "--insecure" # Remove in strict production environments
        ]
        resources = var.argocd_config.resource_limits.server
        secretKey = var.argocd_secrets.admin_pw
      }

      repoServer = {
        resources = var.argocd_config.resource_limits.repo_server
      }

      controller = {
        resources = var.argocd_config.resource_limits.application_controller
        args = {
          "controller.image-pull-secret-propagation.enabled" = "true"
        }
      }

      dex = {
        enabled = var.argocd_config.enable_dex
      }

      ha = {
        enabled = var.argocd_config.enable_ha
      }

      configs = {
        secret = {
          argocdServerAdminPassword = bcrypt(var.argocd_secrets.admin_pw)
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
    for_each = var.argocd_config.extra_configs
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_secret.argocd_admin_password,
    kubernetes_manifest.kustomize_crd,
    kubernetes_secret.argocd_repo_k8s_manifests,
    kubernetes_secret.argocd_ssh_key
  ]
}

################################################################################
# Kustomize installation
################################################################################

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

################################################################################
# ArgoCD image updater install
################################################################################

# ArgoCD Image Updater Helm Release
resource "helm_release" "argocd_image_updater" {
  count = var.enable_image_updater ? 1 : 0

  name       = "argocd-image-updater"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"
  version    = "0.9.1"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    yamlencode({
      config = {
        registries = [
          {
            name        = "GitHub Container Registry"
            api_url     = "https://ghcr.io"
            prefix      = "ghcr.io"
            ping        = true
            credentials = "pullsecret:argocd/${kubernetes_secret.ghcr_image_updater_pull.metadata[0].name}"
            insecure    = false
          }
        ]
        argocd = {
          grpcWeb       = true
          serverAddress = "argocd-server.${kubernetes_namespace.argocd.metadata[0].name}.svc.cluster.local"
          insecure      = true
          plaintext     = false
        }
      }

      logLevel = var.image_updater_log_level

      rbac = {
        enabled = true
      }

      serviceAccount = {
        create = true
        name   = "argocd-image-updater"
      }

      metrics = {
        enabled = true
        serviceMonitor = {
          enabled = var.enable_monitoring
        }
      }
    })
  ]

  depends_on = [
    helm_release.argocd,
    kubernetes_secret.ghcr_image_updater_pull
  ]
}

# Wait for ArgoCD to be ready
resource "null_resource" "wait_for_argo" {
  provisioner "local-exec" {
    command = <<EOF
      kubectl wait --for=condition=available \
        --timeout=300s \
        --kubeconfig=${var.argocd_config.kubeconfig_path} \
        -n ${kubernetes_namespace.argocd.metadata[0].name} \
        deployment/argocd-server
    EOF
  }

  depends_on = [helm_release.argocd]
}

################################################################################
# end of ./modules/argocd/main.tf
################################################################################
