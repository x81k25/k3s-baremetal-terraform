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

# Create GitLab Container Registry secret
resource "kubernetes_secret" "gitlab_registry" {
  metadata {
    name      = "gitlab-registry"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "192.168.50.2:5050" = {
          username = var.ai_ml_secrets.gitlab.username
          password = var.ai_ml_secrets.gitlab.token
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
    OPTUNA_N_TRIALS              = each.value.optuna_n_trials
    XGBOOST_N_ESTIMATORS_MAX     = each.value.xgboost_n_estimators_max
    REEL_DRIVER_TRNG_PGSQL_HOST     = each.value.pgsql.host
    REEL_DRIVER_TRNG_PGSQL_PORT     = each.value.pgsql.port
    REEL_DRIVER_TRNG_PGSQL_DATABASE = each.value.pgsql.database
    REEL_DRIVER_TRNG_PGSQL_SCHEMA   = each.value.pgsql.schema
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
# cici voice assistant config maps
################################################################################

# Local LLM (Ollama) configuration
resource "kubernetes_config_map" "local_llm_config" {
  metadata {
    name      = "local-llm-config"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    OLLAMA_MODEL         = var.local_llm_config.model
    OLLAMA_HOST_INTERNAL = var.local_llm_config.host.internal
    OLLAMA_HOST_EXTERNAL = var.local_llm_config.host.external
    OLLAMA_PORT_INTERNAL = tostring(var.local_llm_config.port.internal)
    OLLAMA_PORT_EXTERNAL = tostring(var.local_llm_config.port.external)
  }
}

# Cici shared configuration per environment
resource "kubernetes_config_map" "cici_config" {
  for_each = var.cici_config

  metadata {
    name      = "cici-config-${each.key}"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    # inter-service shared config
    CICI_SAMPLE_RATE  = tostring(each.value.sample_rate)
    CICI_LOG_LEVEL    = each.value.log_level
    CICI_DEFAULT_CWD  = each.value.default_cwd
    CICI_CLAUDE_MODEL = each.value.claude_model

    # local LLM reference
    CICI_OLLAMA_HOST  = each.value.local_llm.host
    CICI_OLLAMA_PORT  = tostring(each.value.local_llm.port)
    CICI_OLLAMA_MODEL = each.value.local_llm.model

    # face service
    CICI_FACE_HOST_INTERNAL = each.value.face.host.internal
    CICI_FACE_HOST_EXTERNAL = each.value.face.host.external
    CICI_FACE_PORT_INTERNAL = tostring(each.value.face.port.internal)
    CICI_FACE_PORT_EXTERNAL = tostring(each.value.face.port.external)

    # mind service
    CICI_MIND_HOST_INTERNAL = each.value.mind.host.internal
    CICI_MIND_PORT_INTERNAL = tostring(each.value.mind.port.internal)

    # ears service
    CICI_EARS_HOST_INTERNAL = each.value.ears.host.internal
    CICI_EARS_PORT_INTERNAL = tostring(each.value.ears.port.internal)
    CICI_EARS_SILENCE_MS    = tostring(each.value.ears.silence_ms)
    CICI_EARS_DEBUG         = tostring(each.value.ears.debug)

    # mouth service
    CICI_MOUTH_HOST_INTERNAL     = each.value.mouth.host.internal
    CICI_MOUTH_PORT_INTERNAL     = tostring(each.value.mouth.port.internal)
    CICI_MOUTH_PIPER_VOICE       = each.value.mouth.piper_voice
    CICI_MOUTH_PIPER_SAMPLE_RATE = tostring(each.value.mouth.piper_sample_rate)
  }
}

################################################################################
# dagster k8s_job_op inherited configs
# These ConfigMaps/Secrets mirror those in media-* namespaces so that
# k8s_job_op pods launched in ai-ml namespace can find them
################################################################################

# Environment ConfigMap (uses dev values as dummy for k8s_job_op pods)
resource "kubernetes_config_map" "environment" {
  metadata {
    name      = "environment"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    ENVIRONMENT = var.environment["dev"]
  }
}

# Dagster ConfigMap (uses dev values as dummy for k8s_job_op pods)
resource "kubernetes_config_map" "dagster_config" {
  metadata {
    name      = "dagster-config"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    HOME_PATH              = var.dagster_config.path["dev"].home
    WORKSPACE_PATH         = var.dagster_config.path["dev"].workspace
    DAGSTER_TIMEZONE       = var.dagster_config.path["dev"].timezone
    DAGSTER_PG_HOST        = var.dagster_config.pgsql["dev"].host
    DAGSTER_PG_PORT        = var.dagster_config.pgsql["dev"].port
    DAGSTER_PG_DB          = var.dagster_config.pgsql["dev"].database
    DAGSTER_MINIO_ENDPOINT = var.reel_driver_config["dev"].minio.endpoint
    DAGSTER_MINIO_PORT     = var.reel_driver_config["dev"].minio.port
  }
}

# Dagster Secrets (uses dev values as dummy for k8s_job_op pods)
resource "kubernetes_secret" "dagster_secrets" {
  metadata {
    name      = "dagster-secrets"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  type = "Opaque"

  data = {
    DAGSTER_PG_USERNAME      = var.dagster_secrets["dev"].username
    DAGSTER_PG_PASSWORD      = var.dagster_secrets["dev"].password
    DAGSTER_MINIO_ACCESS_KEY = var.reel_driver_secrets["dev"].minio.access_key
    DAGSTER_MINIO_SECRET_KEY = var.reel_driver_secrets["dev"].minio.secrest_key
  }
}

# Dagster timeout ConfigMap (per environment)
resource "kubernetes_config_map" "dagster_timeout_config" {
  for_each = toset(local.environments)

  metadata {
    name      = "dagster-timeout-config-${each.key}"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    DAGSTER_RUN_MONITORING_MAX_RUNTIME_SECONDS = "3600"
    DAGSTER_RUN_MONITORING_POLL_INTERVAL       = "30"
  }
}

# AT Config (uses dev values as dummy for k8s_job_op pods)
resource "kubernetes_config_map" "at_config" {
  metadata {
    name      = "at-config"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    AT_BATCH_SIZE                     = var.at_config["dev"].batch_size
    AT_LOG_LEVEL                      = var.at_config["dev"].log_level
    AT_STALE_METADATA_THRESHOLD       = var.at_config["dev"].stale_metadata_threshold
    AT_REEL_DRIVER_THRESHOLD          = var.at_config["dev"].reel_driver_threshold
    AT_TARGET_ACTIVE_ITEMS            = var.at_config["dev"].target_active_items
    AT_TRANSFERRED_ITEM_CLEANUP_DELAY = var.at_config["dev"].transferred_item_cleanup_delay
    AT_HUNG_ITEM_CLEANUP_DELAY        = var.at_config["dev"].hung_item_cleanup_delay
    AT_PGSQL_ENDPOINT                 = var.at_config["dev"].pgsql.host
    AT_PGSQL_PORT                     = var.at_config["dev"].pgsql.port
    AT_PGSQL_DATABASE                 = var.at_config["dev"].pgsql.database
    AT_PGSQL_SCHEMA                   = var.at_config["dev"].pgsql.schema
    AT_MOVIE_SEARCH_API_BASE_URL      = var.at_config["dev"].movie_search_api_base_url
    AT_MOVIE_DETAILS_API_BASE_URL     = var.at_config["dev"].movie_details_api_base_url
    AT_MOVIE_RATINGS_API_BASE_URL     = var.at_config["dev"].movie_ratings_api_base_url
  }
}

# AT Secrets (uses dev values as dummy for k8s_job_op pods)
resource "kubernetes_secret" "at_secrets" {
  metadata {
    name      = "at-secrets"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  type = "Opaque"

  data = {
    AT_PGSQL_USERNAME = var.at_secrets["dev"].pgsql.username
    AT_PGSQL_PASSWORD = var.at_secrets["dev"].pgsql.password
  }
}

# WST Config (uses dev values as dummy for k8s_job_op pods)
resource "kubernetes_config_map" "wst_config" {
  metadata {
    name      = "wst-config"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    WST_PGSQL_HOST     = var.wst_config.pgsql["dev"].host
    WST_PGSQL_PORT     = var.wst_config.pgsql["dev"].port
    WST_PGSQL_DATABASE = var.wst_config.pgsql["dev"].database
  }
}

# WST Secrets (uses dev values as dummy for k8s_job_op pods)
resource "kubernetes_secret" "wst_secrets" {
  metadata {
    name      = "wst-secrets"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  type = "Opaque"

  data = {
    WST_PGSQL_USERNAME = var.wst_secrets.pgsql["dev"].username
    WST_PGSQL_PASSWORD = var.wst_secrets.pgsql["dev"].password
  }
}

# Transmission Config (uses dev values as dummy for k8s_job_op pods)
resource "kubernetes_config_map" "transmission_config" {
  metadata {
    name      = "transmission-config"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    TRANSMISSION_HOST = var.transmission_config["dev"].host
    TRANSMISSION_PORT = var.transmission_config["dev"].port
  }
}

# Transmission Secrets (uses dev values as dummy for k8s_job_op pods)
resource "kubernetes_secret" "transmission_secrets" {
  metadata {
    name      = "transmission-secrets"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  type = "Opaque"

  data = {
    TRANSMISSION_USERNAME = var.transmission_secrets["dev"].username
    TRANSMISSION_PASSWORD = var.transmission_secrets["dev"].password
  }
}

# Rear Diff Config (uses dev values as dummy for k8s_job_op pods)
resource "kubernetes_config_map" "rear_diff_config" {
  metadata {
    name      = "rear-diff-config"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    REAR_DIFF_HOST                       = var.rear_diff_config["dev"].host
    REAR_DIFF_PORT_EXTERNAL              = var.rear_diff_config["dev"].port_external
    REAR_DIFF_PREFIX                     = var.rear_diff_config["dev"].prefix
    REAR_DIFF_PGSQL_HOST                 = var.rear_diff_config["dev"].pgsql.host
    REAR_DIFF_PGSQL_PORT                 = var.rear_diff_config["dev"].pgsql.port
    REAR_DIFF_PGSQL_DATABASE             = var.rear_diff_config["dev"].pgsql.database
    REAR_DIFF_TRANSMISSION_HOST          = var.rear_diff_config["dev"].transmission.host
    REAR_DIFF_TRANSMISSION_PORT          = var.rear_diff_config["dev"].transmission.port
    REAR_DIFF_FILE_DELETION_ENABLED      = tostring(var.rear_diff_config["dev"].file_deletion_enabled)
    REAR_DIFF_MEDIA_CACHE_PATH           = var.rear_diff_config["dev"].paths.media_cache_path
    REAR_DIFF_MEDIA_LIBRARY_PATH_MOVIES  = var.rear_diff_config["dev"].paths.media_library_path_movies
    REAR_DIFF_MEDIA_LIBRARY_PATH_TV      = var.rear_diff_config["dev"].paths.media_library_path_tv
    REAR_DIFF_MOVIE_SEARCH_API_BASE_URL  = var.rear_diff_config["dev"].api_urls.movie_search
    REAR_DIFF_MOVIE_DETAILS_API_BASE_URL = var.rear_diff_config["dev"].api_urls.movie_details
    REAR_DIFF_MOVIE_RATINGS_API_BASE_URL = var.rear_diff_config["dev"].api_urls.movie_ratings
    REAR_DIFF_TV_SEARCH_API_BASE_URL     = var.rear_diff_config["dev"].api_urls.tv_search
    REAR_DIFF_TV_DETAILS_API_BASE_URL    = var.rear_diff_config["dev"].api_urls.tv_details
    REAR_DIFF_TV_RATINGS_API_BASE_URL    = var.rear_diff_config["dev"].api_urls.tv_ratings
  }
}

# Rear Diff Secrets (uses dev values as dummy for k8s_job_op pods)
resource "kubernetes_secret" "rear_diff_secrets" {
  metadata {
    name      = "rear-diff-secrets"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  type = "Opaque"

  data = {
    REAR_DIFF_PGSQL_USERNAME        = var.rear_diff_secrets["dev"].pgsql.username
    REAR_DIFF_PGSQL_PASSWORD        = var.rear_diff_secrets["dev"].pgsql.password
    REAR_DIFF_TRANSMISSION_USERNAME = var.rear_diff_secrets["dev"].transmission.username
    REAR_DIFF_TRANSMISSION_PASSWORD = var.rear_diff_secrets["dev"].transmission.password
    REAR_DIFF_MOVIE_SEARCH_API_KEY  = var.rear_diff_secrets["dev"].movie_search_api_key
    REAR_DIFF_MOVIE_DETAILS_API_KEY = var.rear_diff_secrets["dev"].movie_details_api_key
    REAR_DIFF_MOVIE_RATINGS_API_KEY = var.rear_diff_secrets["dev"].movie_ratings_api_key
    REAR_DIFF_TV_SEARCH_API_KEY     = var.rear_diff_secrets["dev"].tv_search_api_key
    REAR_DIFF_TV_DETAILS_API_KEY    = var.rear_diff_secrets["dev"].tv_details_api_key
    REAR_DIFF_TV_RATINGS_API_KEY    = var.rear_diff_secrets["dev"].tv_ratings_api_key
  }
}

# Reel Driver Config (uses dev values as dummy for k8s_job_op pods)
# Note: reel-driver-config-{env} ConfigMaps already exist above for actual reel-driver workloads
resource "kubernetes_config_map" "reel_driver_config_shared" {
  metadata {
    name      = "reel-driver-config"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    REEL_DRIVER_MLFLOW_HOST       = var.reel_driver_config["dev"].mflow.host
    REEL_DRIVER_MLFLOW_PORT       = var.reel_driver_config["dev"].mflow.port
    REEL_DRIVER_MLFLOW_EXPERIMENT = var.reel_driver_config["dev"].mflow.experiment
    REEL_DRIVER_MLFLOW_MODEL      = var.reel_driver_config["dev"].mflow.model
    REEL_DRIVER_MINIO_ENDPOINT    = var.reel_driver_config["dev"].minio.endpoint
    REEL_DRIVER_MINIO_PORT        = var.reel_driver_config["dev"].minio.port
  }
}

# Reel Driver Secrets (uses dev values as dummy for k8s_job_op pods)
# Note: reel-driver-secrets-{env} Secrets already exist above for actual reel-driver workloads
resource "kubernetes_secret" "reel_driver_secrets_shared" {
  metadata {
    name      = "reel-driver-secrets"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  type = "Opaque"

  data = {
    REEL_DRIVER_MINIO_ACCESS_KEY = var.reel_driver_secrets["dev"].minio.access_key
    REEL_DRIVER_MINIO_SECRET_KEY = var.reel_driver_secrets["dev"].minio.secrest_key
  }
}

################################################################################
# end of main.tf
################################################################################