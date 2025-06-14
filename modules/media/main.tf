################################################################################
# media namespaces
################################################################################

resource "kubernetes_namespace" "media-prod" {
  metadata {
    name = "media-prod"
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_namespace" "media-stg" {
  metadata {
    name = "media-stg"
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_namespace" "media-dev" {
  metadata {
    name = "media-dev"
    labels = {
      managed-by = "terraform"
    }
  }
}

################################################################################
# media secretes
################################################################################

resource "kubernetes_secret" "ghcr_credentials" {
  for_each = toset(["media-dev", "media-stg", "media-prod"])

  metadata {
    name      = "ghcr-pull-image-token"
    namespace = each.key
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

resource "kubernetes_secret" "vpn_config" {
  for_each = toset(["media-dev", "media-stg", "media-prod"])

  metadata {
    name      = "vpn-config"
    namespace = each.key
  }

  data = {
    VPN_USERNAME = var.vpn_config.username
    VPN_PASSWORD = var.vpn_config.password
    VPN_CONFIG   = var.vpn_config.config
  }

  type = "Opaque"
}

resource "kubernetes_secret" "plex_secret" {
  metadata {
    name      = "plex-config"
    namespace = "media-prod"
  }

  data = {
    PLEX_CLAIM = var.media_sensitive.plex_claim
  }
}

# handle database secrets
resource "kubernetes_secret" "rear_diff_pgsql_config_prod" {
  metadata {
    name      = "rear-diff-pgsql-config"
    namespace = "media-prod"
  }

  data = {
    PGSQL_USER     = var.rear_diff_pgsql_config.prod.user
    PGSQL_PASSWORD = var.rear_diff_pgsql_config.prod.password
    PGSQL_HOST     = var.rear_diff_pgsql_config.prod.host
    PGSQL_PORT     = tostring(var.rear_diff_pgsql_config.prod.port)
    PGSQL_DATABASE = var.rear_diff_pgsql_config.prod.database
  }

  type = "Opaque"
}

resource "kubernetes_secret" "rear_diff_pgsql_config_stg" {
  metadata {
    name      = "rear-diff-pgsql-config"
    namespace = "media-stg"
  }

  data = {
    PGSQL_USER     = var.rear_diff_pgsql_config.stg.user
    PGSQL_PASSWORD = var.rear_diff_pgsql_config.stg.password
    PGSQL_HOST     = var.rear_diff_pgsql_config.stg.host
    PGSQL_PORT     = tostring(var.rear_diff_pgsql_config.stg.port)
    PGSQL_DATABASE = var.rear_diff_pgsql_config.stg.database
  }

  type = "Opaque"
}

resource "kubernetes_secret" "rear_diff_pgsql_config_dev" {
  metadata {
    name      = "rear-diff-pgsql-config"
    namespace = "media-dev"
  }

  data = {
    PGSQL_USER     = var.rear_diff_pgsql_config.dev.user
    PGSQL_PASSWORD = var.rear_diff_pgsql_config.dev.password
    PGSQL_HOST     = var.rear_diff_pgsql_config.dev.host
    PGSQL_PORT     = tostring(var.rear_diff_pgsql_config.dev.port)
    PGSQL_DATABASE = var.rear_diff_pgsql_config.dev.database
  }

  type = "Opaque"
}

################################################################################
# Dagster configuration (moved from orchestration module)
################################################################################

# Create ConfigMap for Dagster host paths - prod
resource "kubernetes_config_map" "dagster_paths_prod" {
  metadata {
    name      = "dagster-paths"
    namespace = "media-prod"
  }

  data = {
    DAGSTER_HOME_PATH      = var.dagster_config.prod.home_path
    DAGSTER_WORKSPACE_PATH = var.dagster_config.prod.workspace_path
  }
}

# Create ConfigMap for Dagster host paths - stg
resource "kubernetes_config_map" "dagster_paths_stg" {
  metadata {
    name      = "dagster-paths"
    namespace = "media-stg"
  }

  data = {
    DAGSTER_HOME_PATH      = var.dagster_config.stg.home_path
    DAGSTER_WORKSPACE_PATH = var.dagster_config.stg.workspace_path
  }
}

# Create ConfigMap for Dagster host paths - dev
resource "kubernetes_config_map" "dagster_paths_dev" {
  metadata {
    name      = "dagster-paths"
    namespace = "media-dev"
  }

  data = {
    DAGSTER_HOME_PATH      = var.dagster_config.dev.home_path
    DAGSTER_WORKSPACE_PATH = var.dagster_config.dev.workspace_path
  }
}

# Dagster database secrets - prod
resource "kubernetes_secret" "dagster_pgsql_config_prod" {
  metadata {
    name      = "dagster-pgsql-config"
    namespace = "media-prod"
  }

  data = {
    PGSQL_USER     = var.dagster_pgsql_config.prod.user
    PGSQL_PASSWORD = var.dagster_pgsql_config.prod.password
    PGSQL_HOST     = var.dagster_pgsql_config.prod.host
    PGSQL_PORT     = tostring(var.dagster_pgsql_config.prod.port)
    PGSQL_DATABASE = var.dagster_pgsql_config.prod.database
  }

  type = "Opaque"
}

# Dagster database secrets - stg
resource "kubernetes_secret" "dagster_pgsql_config_stg" {
  metadata {
    name      = "dagster-pgsql-config"
    namespace = "media-stg"
  }

  data = {
    PGSQL_USER     = var.dagster_pgsql_config.stg.user
    PGSQL_PASSWORD = var.dagster_pgsql_config.stg.password
    PGSQL_HOST     = var.dagster_pgsql_config.stg.host
    PGSQL_PORT     = tostring(var.dagster_pgsql_config.stg.port)
    PGSQL_DATABASE = var.dagster_pgsql_config.stg.database
  }

  type = "Opaque"
}

# Dagster database secrets - dev
resource "kubernetes_secret" "dagster_pgsql_config_dev" {
  metadata {
    name      = "dagster-pgsql-config"
    namespace = "media-dev"
  }

  data = {
    PGSQL_USER     = var.dagster_pgsql_config.dev.user
    PGSQL_PASSWORD = var.dagster_pgsql_config.dev.password
    PGSQL_HOST     = var.dagster_pgsql_config.dev.host
    PGSQL_PORT     = tostring(var.dagster_pgsql_config.dev.port)
    PGSQL_DATABASE = var.dagster_pgsql_config.dev.database
  }

  type = "Opaque"
}

# Also create GHCR token secret for environment variable use
resource "kubernetes_secret" "ghcr_token" {
  for_each = toset(["media-dev", "media-stg", "media-prod"])

  metadata {
    name      = "ghcr-token"
    namespace = each.key
  }

  data = {
    GHCR_PULL_IMAGE_TOKEN = var.github_config.argo_cd_pull_image_token
  }

  type = "Opaque"
}

################################################################################
# configure GPU for media use
################################################################################

# Create a RuntimeClass for NVIDIA
data "kubernetes_resource" "nvidia_runtime_class" {
  api_version = "node.k8s.io/v1"
  kind        = "RuntimeClass"
  metadata {
    name = "nvidia"
  }
}

# Mount the NVIDIA drivers in the DaemonSet
resource "helm_release" "nvidia_device_plugin" {
  name       = "nvidia-device-plugin"
  repository = "https://nvidia.github.io/k8s-device-plugin"
  chart      = "nvidia-device-plugin"
  namespace  = kubernetes_namespace.media-prod.metadata[0].name
  version    = "0.14.0"

  set {
    name  = "migStrategy"
    value = "none"
  }

  set {
    name  = "compatWithCPUManager"
    value = "true"
  }

  # Set the runtime class to use the NVIDIA runtime
  set {
    name  = "runtimeClassName"
    value = "nvidia"
  }

  # Add volume mounts for NVIDIA libraries
  values = [
    <<-EOT
    volumeMounts:
      - name: nvidia-driver-libs
        mountPath: /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1
        subPath: libnvidia-ml.so.1
    volumes:
      - name: nvidia-driver-libs
        hostPath:
          path: /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1
          type: File
    EOT
  ]
}

resource "kubernetes_resource_quota" "media_prod_gpu" {
  metadata {
    name      = "gpu-quota"
    namespace = "media-prod"
  }

  spec {
    hard = {
      "nvidia.com/gpu" = 1
    }
  }
}

################################################################################
# end of main.tf
################################################################################
