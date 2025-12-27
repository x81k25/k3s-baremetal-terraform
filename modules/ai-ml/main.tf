################################################################################
# namespace 
################################################################################

locals {
  environments = ["dev", "stg", "prod"]
}

resource "kubernetes_namespace" "ai_ml" {
  metadata {
    name = "ai-ml"
    labels = {
      managed-by = "terraform"
    }
  }
}

################################################################################
# namespace resource quotas
################################################################################

resource "kubernetes_resource_quota" "ai_ml_quota" {
  metadata {
    name      = "ai-ml-resource-quota"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.ai_ml_config.resource_quota.cpu_request
      "limits.cpu"      = var.ai_ml_config.resource_quota.cpu_limit
      "requests.memory" = var.ai_ml_config.resource_quota.memory_request
      "limits.memory"   = var.ai_ml_config.resource_quota.memory_limit
    }
  }
}

################################################################################
# namespace limit ranges - default container limits
################################################################################

resource "kubernetes_limit_range" "ai_ml_limits" {
  metadata {
    name      = "ai-ml-limit-range"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.ai_ml_config.container_defaults.cpu_limit
        memory = var.ai_ml_config.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.ai_ml_config.container_defaults.cpu_request
        memory = var.ai_ml_config.container_defaults.memory_request
      }
    }
  }
}

################################################################################
# env vars & secrets
################################################################################

# Create GitHub Container Registry secret
resource "kubernetes_secret" "ghcr_pull_image_secret" {
  metadata {
    name      = "ghcr-pull-image-secret"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          username = var.ai_ml_secrets.github.username
          password = var.ai_ml_secrets.github.token_packages_read
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

# Create ConfigMaps for non-sensitive mlflow env vars
resource "kubernetes_config_map" "mlflow_config" {
  for_each = var.mlflow_config

  metadata {
    name      = "mlflow-config-${each.key}"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    MLFLOW_UID                         = each.value.uid
    MLFLOW_GID                         = each.value.gid
    MLFLOW_PORT_EXTERNAL               = each.value.port_external
    MLFLOW_PATH_LOGS                   = each.value.path.logs
    MLFLOW_PATH_PACKAGES               = each.value.path.packages
    MLFLOW_PGSQL_HOST                  = each.value.pgsql.host
    MLFLOW_PGSQL_PORT                  = each.value.pgsql.port
    MLFLOW_PGSQL_DATABASE              = each.value.pgsql.database
    MLFLOW_MINIO_DEFAULT_ARTIFACT_ROOT = each.value.minio.default_artifact_root
    MLFLOW_MINIO_ENDPOINT_EXTERNAL     = each.value.minio.endpoint.external
    MLFLOW_MINIO_ENDPOINT_INTERNAL     = each.value.minio.endpoint.internal
    MLFLOW_MINIO_PORT_EXTERNAL         = each.value.minio.port.external
    MLFLOW_MINIO_PORT_INTERNAL         = each.value.minio.port.internal
  }
}

# Create Secrets for sensitive mlflow env vars
resource "kubernetes_secret" "mlflow_secrets" {
  for_each = toset(local.environments)

  metadata {
    name      = "mlflow-secrets-${each.key}"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    MLFLOW_USERNAME               = var.mlflow_secrets[each.key].username
    MLFLOW_PASSWORD               = var.mlflow_secrets[each.key].password
    MLFLOW_PGSQL_USERNAME         = var.mlflow_secrets[each.key].pgsql.username
    MLFLOW_PGSQL_PASSWORD         = var.mlflow_secrets[each.key].pgsql.password
    MLFLOW_MINIO_AWS_ACCESS_KEY_ID     = var.mlflow_secrets[each.key].minio.aws_access_key_id
    MLFLOW_MINIO_AWS_SECRET_ACCESS_KEY = var.mlflow_secrets[each.key].minio.aws_secret_access_key
  }

  type = "Opaque"
}

################################################################################
# reel-driver config maps and secrets
################################################################################

# Create ConfigMaps for non-sensitive reel-driver env vars
resource "kubernetes_config_map" "reel_driver_config" {
  for_each = var.reel_driver_config

  metadata {
    name      = "reel-driver-config-${each.key}"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    REEL_DRIVER_MLFLOW_HOST       = each.value.mflow.host
    REEL_DRIVER_MLFLOW_PORT       = each.value.mflow.port
    REEL_DRIVER_MLFLOW_EXPERIMENT = each.value.mflow.experiment
    REEL_DRIVER_MLFLOW_MODEL      = each.value.mflow.model
    REEL_DRIVER_MINIO_ENDPOINT    = each.value.minio.endpoint
    REEL_DRIVER_MINIO_PORT        = each.value.minio.port
  }
}

# Create ConfigMaps for reel-driver API configuration
resource "kubernetes_config_map" "reel_driver_api_config" {
  for_each = var.reel_driver_api_config

  metadata {
    name      = "reel-driver-api-config-${each.key}"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    REEL_DRIVER_API_HOST          = each.value.host
    REEL_DRIVER_API_PORT_EXTERNAL = each.value.port.external
    REEL_DRIVER_API_PORT_INTERNAL = each.value.port.internal
    REEL_DRIVER_API_PREFIX        = each.value.prefix
    REEL_DRIVER_API_LOG_LEVEL     = each.value.log_level
  }
}

# Create ConfigMaps for reel-driver training configuration
resource "kubernetes_config_map" "reel_driver_training_config" {
  for_each = var.reel_driver_training_config

  metadata {
    name      = "reel-driver-training-config-${each.key}"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    REEL_DRIVER_TRNG_HYPER_PARAM_SEARCH_STRAT = each.value.hyper_param_search_start
    REEL_DRIVER_TRNG_PGSQL_HOST               = each.value.pgsql.host
    REEL_DRIVER_TRNG_PGSQL_PORT               = each.value.pgsql.port
    REEL_DRIVER_TRNG_PGSQL_DATABASE           = each.value.pgsql.database
    REEL_DRIVER_TRNG_PGSQL_SCHEMA             = each.value.pgsql.schema
  }
}

# Create Secrets for sensitive reel-driver env vars
resource "kubernetes_secret" "reel_driver_secrets" {
  for_each = toset(local.environments)

  metadata {
    name      = "reel-driver-secrets-${each.key}"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    REEL_DRIVER_MINIO_ACCESS_KEY = var.reel_driver_secrets[each.key].minio.access_key
    REEL_DRIVER_MINIO_SECRET_KEY = var.reel_driver_secrets[each.key].minio.secrest_key
  }

  type = "Opaque"
}

# Create Secrets for reel-driver training credentials
resource "kubernetes_secret" "reel_driver_training_secrets" {
  for_each = toset(local.environments)

  metadata {
    name      = "reel-driver-training-secrets-${each.key}"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    REEL_DRIVER_TRNG_PGSQL_USERNAME = var.reel_driver_training_secrets[each.key].pgsql.username
    REEL_DRIVER_TRNG_PGSQL_PASSWORD = var.reel_driver_training_secrets[each.key].pgsql.password
  }

  type = "Opaque"
}

################################################################################
# configure GPU for ai-ml use
################################################################################

# Create a RuntimeClass for NVIDIA
data "kubernetes_resource" "nvidia_runtime_class" {
  api_version = "node.k8s.io/v1"
  kind        = "RuntimeClass"
  metadata {
    name = "nvidia"
  }
}

# Mount the NVIDIA drivers in the DaemonSet with GPU Feature Discovery
resource "helm_release" "nvidia_device_plugin" {
  name       = "nvidia-device-plugin"
  repository = "https://nvidia.github.io/k8s-device-plugin"
  chart      = "nvidia-device-plugin"
  namespace  = kubernetes_namespace.ai_ml.metadata[0].name
  version    = "0.17.1"

  # Enable GPU Feature Discovery for node labeling
  set {
    name  = "gfd.enabled"
    value = "true"
  }

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

  # Add volume mounts for NVIDIA libraries and GFD configuration
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
    gfd:
      securityContext:
        privileged: true
    EOT
  ]
}

resource "kubernetes_resource_quota" "ai_ml_gpu" {
  metadata {
    name      = "gpu-quota"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  spec {
    hard = {
      "nvidia.com/gpu" = var.gpu_config.quota
    }
  }
}

# GPU devices ConfigMap for workload GPU selection
resource "kubernetes_config_map" "gpu_devices" {
  metadata {
    name      = "gpu-devices"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    GTX960_UUID    = var.gpu_config.gtx960.uuid
    GTX960_MEMORY  = var.gpu_config.gtx960.memory
    RTX3060_UUID   = var.gpu_config.rtx3060.uuid
    RTX3060_MEMORY = var.gpu_config.rtx3060.memory
  }
}

################################################################################
# end of main.tf
################################################################################