# PVC for pgAdmin data
resource "kubernetes_persistent_volume_claim" "pgadmin_data" {
  metadata {
    name      = "pgadmin-data"
    namespace = "pgsql"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

# Create ArgoCD Application as a Kubernetes manifest
resource "kubernetes_manifest" "pgadmin_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "pgadmin"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://helm.dpage.org/charts"
        chart          = "pgadmin4"
        targetRevision = "1.x.x"
        helm = {
          values = <<-EOT
          env:
            PGADMIN_DEFAULT_EMAIL: "${var.pgadmin4_config.email}"
            PGADMIN_DEFAULT_PASSWORD: "${var.pgadmin4_config.password}"
            PGADMIN_LISTEN_PORT: ${var.pgadmin4_config.listen_port}
            PGADMIN_LISTEN_ADDRESS: "${var.pgadmin4_config.listen_address}"
            PGADMIN_SERVER_MODE: ${var.pgadmin4_config.server_mode}
          
          securityContext:
            runAsUser: ${var.pgadmin4_config.UID}
            runAsGroup: ${var.pgadmin4_config.GID}
            fsGroup: ${var.pgadmin4_config.fs_group}
          
          persistentVolume:
            existingClaim: "pgadmin-data"
            mountPath: "${var.pgadmin4_config.mount}"
          
          service:
            port: ${var.pgadmin4_config.port}
          EOT
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "pgsql"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
  depends_on = [kubernetes_persistent_volume_claim.pgadmin_data]
}