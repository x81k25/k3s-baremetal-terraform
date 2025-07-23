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
# namespace limit ranges - default container limits
################################################################################

resource "kubernetes_limit_range" "argocd_limits" {
  metadata {
    name      = "argocd-limit-range"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.argocd_config.container_defaults.cpu_limit
        memory = var.argocd_config.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.argocd_config.container_defaults.cpu_request
        memory = var.argocd_config.container_defaults.memory_request
      }
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

resource "kubernetes_secret" "ghcr_pull_image_secret" {
  metadata {
    name      = "ghcr-pull-image-secret"
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
          username = var.argocd_secrets.github.username
          password = var.argocd_secrets.github.token_packages_read
        }
      }
    })
  }

  depends_on = [kubernetes_namespace.argocd]
}

# Create a generic secret for ArgoCD Image Updater with token format
resource "kubernetes_secret" "ghcr_image_updater_token" {
  metadata {
    name      = "ghcr-image-updater-token"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  type = "Opaque"

  data = {
    token = "${var.argocd_secrets.github.username}:${var.argocd_secrets.github.token_packages_read}"
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
      server = merge({
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
        secretKey = var.argocd_secrets.admin_pw
        resources = {
          limits = {
            cpu    = var.argocd_config.container_defaults.cpu_limit
            memory = var.argocd_config.container_defaults.memory_limit
          }
          requests = {
            cpu    = var.argocd_config.container_defaults.cpu_request
            memory = var.argocd_config.container_defaults.memory_request
          }
        }
      })

      repoServer = merge({
        resources = {
          limits = {
            cpu    = lookup(var.argocd_config.container_overrides, "repo_server", var.argocd_config.container_defaults).cpu_limit
            memory = lookup(var.argocd_config.container_overrides, "repo_server", var.argocd_config.container_defaults).memory_limit
          }
          requests = {
            cpu    = lookup(var.argocd_config.container_overrides, "repo_server", var.argocd_config.container_defaults).cpu_request
            memory = lookup(var.argocd_config.container_overrides, "repo_server", var.argocd_config.container_defaults).memory_request
          }
        }
      })

      controller = merge({
        args = {
          "controller.image-pull-secret-propagation.enabled" = "true"
          "controller.app.resync"                            = tostring(var.argocd_config.refresh_config.app_resync_seconds)
          "controller.repo.cache.expiration"                 = var.argocd_config.refresh_config.repo_cache_expiration
        }
        resources = {
          limits = {
            cpu    = var.argocd_config.container_defaults.cpu_limit
            memory = var.argocd_config.container_defaults.memory_limit
          }
          requests = {
            cpu    = var.argocd_config.container_defaults.cpu_request
            memory = var.argocd_config.container_defaults.memory_request
          }
        }
      })

      applicationSet = merge({
        resources = {
          limits = {
            cpu    = lookup(var.argocd_config.container_overrides, "applicationset_controller", var.argocd_config.container_defaults).cpu_limit
            memory = lookup(var.argocd_config.container_overrides, "applicationset_controller", var.argocd_config.container_defaults).memory_limit
          }
          requests = {
            cpu    = lookup(var.argocd_config.container_overrides, "applicationset_controller", var.argocd_config.container_defaults).cpu_request
            memory = lookup(var.argocd_config.container_overrides, "applicationset_controller", var.argocd_config.container_defaults).memory_request
          }
        }
      })

      notifications = merge({
        resources = {
          limits = {
            cpu    = var.argocd_config.container_defaults.cpu_limit
            memory = var.argocd_config.container_defaults.memory_limit
          }
          requests = {
            cpu    = var.argocd_config.container_defaults.cpu_request
            memory = var.argocd_config.container_defaults.memory_request
          }
        }
      })

      redis = merge({
        resources = {
          limits = {
            cpu    = var.argocd_config.container_defaults.cpu_limit
            memory = var.argocd_config.container_defaults.memory_limit
          }
          requests = {
            cpu    = var.argocd_config.container_defaults.cpu_request
            memory = var.argocd_config.container_defaults.memory_request
          }
        }
      })

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
        cm = {
          "timeout.reconciliation" = var.argocd_config.refresh_config.reconciliation_timeout
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
            credentials = "secret:argocd/ghcr-image-updater-token#token"
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

      extraArgs = [
        "--interval",
        var.argocd_config.refresh_config.image_updater_interval
      ]

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
    kubernetes_secret.ghcr_pull_image_secret,
    kubernetes_secret.ghcr_image_updater_token
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
