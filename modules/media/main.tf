################################################################################
# media k8s namespaces
################################################################################

locals {
  environments = ["dev", "stg", "prod"]
}

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
# namespace resource quotas
################################################################################

resource "kubernetes_resource_quota" "media_prod_quota" {
  metadata {
    name      = "media-prod-resource-quota"
    namespace = kubernetes_namespace.media-prod.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.media_config.prod.resource_quota.cpu_request
      "limits.cpu"      = var.media_config.prod.resource_quota.cpu_limit
      "requests.memory" = var.media_config.prod.resource_quota.memory_request
      "limits.memory"   = var.media_config.prod.resource_quota.memory_limit
    }
  }
}

resource "kubernetes_resource_quota" "media_stg_quota" {
  metadata {
    name      = "media-stg-resource-quota"
    namespace = kubernetes_namespace.media-stg.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.media_config.stg.resource_quota.cpu_request
      "limits.cpu"      = var.media_config.stg.resource_quota.cpu_limit
      "requests.memory" = var.media_config.stg.resource_quota.memory_request
      "limits.memory"   = var.media_config.stg.resource_quota.memory_limit
    }
  }
}

resource "kubernetes_resource_quota" "media_dev_quota" {
  metadata {
    name      = "media-dev-resource-quota"
    namespace = kubernetes_namespace.media-dev.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.media_config.dev.resource_quota.cpu_request
      "limits.cpu"      = var.media_config.dev.resource_quota.cpu_limit
      "requests.memory" = var.media_config.dev.resource_quota.memory_request
      "limits.memory"   = var.media_config.dev.resource_quota.memory_limit
    }
  }
}

################################################################################
# namespace limit ranges - default container limits
################################################################################

resource "kubernetes_limit_range" "media_prod_limits" {
  metadata {
    name      = "media-prod-limit-range"
    namespace = kubernetes_namespace.media-prod.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.media_config.prod.container_defaults.cpu_limit
        memory = var.media_config.prod.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.media_config.prod.container_defaults.cpu_request
        memory = var.media_config.prod.container_defaults.memory_request
      }
    }
  }
}

resource "kubernetes_limit_range" "media_stg_limits" {
  metadata {
    name      = "media-stg-limit-range"
    namespace = kubernetes_namespace.media-stg.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.media_config.stg.container_defaults.cpu_limit
        memory = var.media_config.stg.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.media_config.stg.container_defaults.cpu_request
        memory = var.media_config.stg.container_defaults.memory_request
      }
    }
  }
}

resource "kubernetes_limit_range" "media_dev_limits" {
  metadata {
    name      = "media-dev-limit-range"
    namespace = kubernetes_namespace.media-dev.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.media_config.dev.container_defaults.cpu_limit
        memory = var.media_config.dev.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.media_config.dev.container_defaults.cpu_request
        memory = var.media_config.dev.container_defaults.memory_request
      }
    }
  }
}

################################################################################
# environment declaration
# - sets ENVRIONMENT environment variables to be used for various configs
# - no other env vars are set here
################################################################################

# Create ConfigMap to hold the environment value
resource "kubernetes_config_map" "environment" {
  for_each = var.environment

  metadata {
    name      = "environment"
    namespace = "media-${each.key}"
  }

  data = {
    ENVIRONMENT = each.value
  }
}

################################################################################
# media config
# - sets env vars and secrets used for various services in the media namespaces
################################################################################

resource "kubernetes_secret" "ghcr_pull_image_secret" {
  for_each = toset(["media-dev", "media-stg", "media-prod"])

  metadata {
    name      = "ghcr-pull-image-secret"
    namespace = each.key
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          username = var.media_secrets.github.username
          password = var.media_secrets.github.token_packages_read
        }
      }
    })
  }
}

################################################################################
# Dagster configuration 
################################################################################

resource "kubernetes_config_map" "dagster_config" {
  for_each = var.dagster_config.path

  metadata {
    name      = "dagster-config"
    namespace = "media-${each.key}"
  }

  data = {
    HOME_PATH         = each.value.home
    WORKSPACE_PATH    = each.value.workspace
    DAGSTER_TIMEZONE  = each.value.timezone
    DAGSTER_PG_HOST   = var.dagster_config.pgsql[each.key].host
    DAGSTER_PG_PORT   = var.dagster_config.pgsql[each.key].port
    DAGSTER_PG_DB     = var.dagster_config.pgsql[each.key].database
    DAGSTER_MINIO_ENDPOINT = var.reel_driver_config[each.key].minio.endpoint
    DAGSTER_MINIO_PORT     = var.reel_driver_config[each.key].minio.port
  }
}

# Dagster database secrets - dev
resource "kubernetes_secret" "dagster_secrets" {
  for_each = toset(local.environments)

  metadata {
    name      = "dagster-secrets"
    namespace = "media-${each.key}"
  }

  type = "Opaque"

  data = {
    DAGSTER_PG_USERNAME    = var.dagster_secrets[each.key].username
    DAGSTER_PG_PASSWORD    = var.dagster_secrets[each.key].password
    DAGSTER_MINIO_ACCESS_KEY = var.reel_driver_secrets[each.key].minio.access_key
    DAGSTER_MINIO_SECRET_KEY = var.reel_driver_secrets[each.key].minio.secrest_key
  }
}

# Also create GHCR token secret for environment variable use
resource "kubernetes_secret" "ghcr_token" {
  for_each = toset(["media-dev", "media-stg", "media-prod"])

  metadata {
    name      = "ghcr-token"
    namespace = each.key
  }

  data = {
    GHCR_PULL_IMAGE_TOKEN = var.media_secrets.github.token_packages_read
  }

  type = "Opaque"
}

################################################################################
# AT Pipeline configuration
# - sets env vars and secrets for the automatic-transmission servcies
#   which are handled by dagster
################################################################################

# Create ConfigMap for AT config - all environments
resource "kubernetes_config_map" "at_config" {
  for_each = toset(local.environments)

  metadata {
    name      = "at-config"
    namespace = "media-${each.key}"
  }

  data = {
    AT_BATCH_SIZE                     = var.at_config[each.key].batch_size
    AT_LOG_LEVEL                      = var.at_config[each.key].log_level
    AT_STALE_METADATA_THRESHOLD       = var.at_config[each.key].stale_metadata_threshold
    AT_REEL_DRIVER_THRESHOLD          = var.at_config[each.key].reel_driver_threshold
    AT_TARGET_ACTIVE_ITEMS            = var.at_config[each.key].target_active_items
    AT_TRANSFERRED_ITEM_CLEANUP_DELAY = var.at_config[each.key].transferred_item_cleanup_delay
    AT_HUNG_ITEM_CLEANUP_DELAY        = var.at_config[each.key].hung_item_cleanup_delay
    
    AT_PGSQL_ENDPOINT = var.at_config[each.key].pgsql.host
    AT_PGSQL_PORT     = var.at_config[each.key].pgsql.port
    AT_PGSQL_DATABASE = var.at_config[each.key].pgsql.database
    AT_PGSQL_SCHEMA   = var.at_config[each.key].pgsql.schema
    
    AT_MOVIE_SEARCH_API_BASE_URL = var.at_config[each.key].movie_search_api_base_url
    AT_MOVIE_DETAILS_API_BASE_URL = var.at_config[each.key].movie_details_api_base_url
    AT_MOVIE_RATINGS_API_BASE_URL = var.at_config[each.key].movie_ratings_api_base_url
    
    AT_TV_SEARCH_API_BASE_URL = var.at_config[each.key].tv_search_api_base_utl
    AT_TV_DETAILS_API_BASE_URL = var.at_config[each.key].tv_details_api_base_url
    AT_TV_RATINGS_API_BASE_URL = var.at_config[each.key].tv_ratings_api_base_url
    
    AT_RSS_SOURCES = var.at_config[each.key].rss_sources
    AT_RSS_URLS    = var.at_config[each.key].rss_urls
    
    AT_UID          = var.at_config[each.key].uid
    AT_GID          = var.at_config[each.key].gid
    AT_DOWNLOAD_DIR = var.at_config[each.key].download_dir
    AT_MOVIE_DIR    = var.at_config[each.key].movie_dir
    AT_TV_SHOW_DIR  = var.at_config[each.key].tv_show_dir
    
    REEL_DRIVER_HOST   = var.at_config[each.key].reel_driver.host
    REEL_DRIVER_PORT   = var.at_config[each.key].reel_driver.port
    REEL_DRIVER_PREFIX = var.at_config[each.key].reel_driver.prefix
  }
}

# Create ConfigMap for transmission config - all environments
resource "kubernetes_config_map" "transmission_config" {
  for_each = toset(local.environments)

  metadata {
    name      = "transmission-config"
    namespace = "media-${each.key}"
  }

  data = {
    TRANSMISSION_HOST = var.transmission_config[each.key].host
    TRANSMISSION_PORT = var.transmission_config[each.key].port
  }
}

# Create ConfigMap for transmission settings - all environments
resource "kubernetes_config_map" "transmission_settings" {
  for_each = toset(local.environments)

  metadata {
    name      = "transmission-settings"
    namespace = "media-${each.key}"
  }

  data = {
    TRANSMISSION_SPEED_LIMIT_DOWN         = tostring(var.transmission_config[each.key].env_vars.speed_limit_down)
    TRANSMISSION_SPEED_LIMIT_DOWN_ENABLED = tostring(var.transmission_config[each.key].env_vars.speed_limit_down_enabled)
    TRANSMISSION_SPEED_LIMIT_UP           = tostring(var.transmission_config[each.key].env_vars.speed_limit_up)
    TRANSMISSION_SPEED_LIMIT_UP_ENABLED   = tostring(var.transmission_config[each.key].env_vars.speed_limit_up_enabled)
    TRANSMISSION_DOWNLOAD_QUEUE_ENABLED   = tostring(var.transmission_config[each.key].env_vars.download_queue_enabled)
    TRANSMISSION_DOWNLOAD_QUEUE_SIZE      = tostring(var.transmission_config[each.key].env_vars.download_queue_size)
    TRANSMISSION_SEED_QUEUE_ENABLED       = tostring(var.transmission_config[each.key].env_vars.seed_queue_enabled)
    TRANSMISSION_SEED_QUEUE_SIZE          = tostring(var.transmission_config[each.key].env_vars.seed_queue_size)
    TRANSMISSION_QUEUE_STALLED_ENABLED    = tostring(var.transmission_config[each.key].env_vars.queue_stalled_enabled)
    TRANSMISSION_QUEUE_STALLED_MINUTES    = tostring(var.transmission_config[each.key].env_vars.queue_stalled_minutes)
    TRANSMISSION_PEER_LIMIT_GLOBAL        = tostring(var.transmission_config[each.key].env_vars.peer_limit_global)
    TRANSMISSION_PEER_LIMIT_PER_TORRENT   = tostring(var.transmission_config[each.key].env_vars.peer_limit_per_torrent)
    TRANSMISSION_CACHE_SIZE_MB            = tostring(var.transmission_config[each.key].env_vars.cache_size_mb)
    TRANSMISSION_PREALLOCATION            = tostring(var.transmission_config[each.key].env_vars.preallocation)
  }
}


# Create Secret for AT sensitive config - all environments
resource "kubernetes_secret" "at_secrets" {
  for_each = toset(local.environments)

  metadata {
    name      = "at-secrets"
    namespace = "media-${each.key}"
  }

  data = {
    AT_PGSQL_USERNAME = var.at_secrets[each.key].pgsql.username
    AT_PGSQL_PASSWORD = var.at_secrets[each.key].pgsql.password
    
    AT_MOVIE_SEARCH_API_KEY  = var.at_secrets[each.key].movie_search_api_key
    AT_MOVIE_DETAILS_API_KEY = var.at_secrets[each.key].movie_details_api_key
    AT_MOVIE_RATINGS_API_KEY = var.at_secrets[each.key].movie_ratings_api_key
    
    AT_TV_SEARCH_API_KEY  = var.at_secrets[each.key].tv_search_api_key
    AT_TV_DETAILS_API_KEY = var.at_secrets[each.key].tv_details_api_key
    AT_TV_RATINGS_API_KEY = var.at_secrets[each.key].tv_ratings_api_key
  }

  type = "Opaque"
}

# Create Secret for transmission credentials - all environments
resource "kubernetes_secret" "transmission_secrets" {
  for_each = toset(local.environments)

  metadata {
    name      = "transmission-secrets"
    namespace = "media-${each.key}"
  }

  data = {
    TRANSMISSION_USERNAME = var.transmission_secrets[each.key].username
    TRANSMISSION_PASSWORD = var.transmission_secrets[each.key].password
  }

  type = "Opaque"
}

################################################################################
# wst config
# - sets env vars and secrets for the wiring-schma-tics services which are 
#   triggerd by Dagster
################################################################################

# Create ConfigMaps for non-sensitive env vars
resource "kubernetes_config_map" "wst_config" {
  for_each = var.wst_config.pgsql

  metadata {
    name      = "wst-config"
    namespace = "media-${each.key}"
  }

  data = {
    WST_PGSQL_HOST     = each.value.host
    WST_PGSQL_PORT     = each.value.port
    WST_PGSQL_DATABASE = each.value.database
  }
}

# Create Secrets for sensitive env vars - use toset() to iterate over environments
resource "kubernetes_secret" "wst_secrets" {
  for_each = toset(local.environments)

  metadata {
    name      = "wst-secrets"
    namespace = "media-${each.key}"
  }

  data = {
    WST_PGSQL_USERNAME = var.wst_secrets.pgsql[each.key].username
    WST_PGSQL_PASSWORD = var.wst_secrets.pgsql[each.key].password
  }

  type = "Opaque"
}

################################################################################
# atd config
################################################################################

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

resource "kubernetes_secret" "wireguard_secrets" {
  for_each = toset(local.environments)

  metadata {
    name      = "wireguard-secrets"
    namespace = "media-${each.key}"
  }

  data = {
    WIREGUARD_PRIVATE_KEY = var.wireguard_secrets[each.key].inteface.private_key
    WIREGUARD_ADDRESS     = var.wireguard_secrets[each.key].inteface.addreses
    WIREGUARD_DNS         = var.wireguard_secrets[each.key].inteface.dns
    WIREGUARD_MTU         = var.wireguard_secrets[each.key].inteface.mtu
    WIREGUARD_PUBLIC_KEY  = var.wireguard_secrets[each.key].peer.public_key
    WIREGUARD_ALLOWED_IPS = var.wireguard_secrets[each.key].peer.allowed_ips
    WIREGUARD_ENDPOINT    = var.wireguard_secrets[each.key].peer.endpoint
  }

  type = "Opaque"
}

################################################################################
# plex config
################################################################################

resource "kubernetes_secret" "plex_secret" {
  metadata {
    name      = "plex-config"
    namespace = "media-prod"
  }

  data = {
    PLEX_CLAIM = var.plex_secrets.claim
  }
}

################################################################################
# rear differential config
################################################################################

# Create ConfigMaps for non-sensitive env vars
resource "kubernetes_config_map" "rear_diff_config" {
  for_each = var.rear_diff_config

  metadata {
    name      = "rear-diff-config"
    namespace = "media-${each.key}"
  }

  data = {
    REAR_DIFF_HOST               = each.value.host
    REAR_DIFF_PORT_EXTERNAL      = each.value.port_external
    REAR_DIFF_PREFIX             = each.value.prefix
    REAR_DIFF_PGSQL_HOST         = each.value.pgsql.host
    REAR_DIFF_PGSQL_PORT         = each.value.pgsql.port
    REAR_DIFF_PGSQL_DATABASE     = each.value.pgsql.database
    REAR_DIFF_TRANSMISSION_HOST  = each.value.transmission.host
    REAR_DIFF_TRANSMISSION_PORT  = each.value.transmission.port
    REAR_DIFF_MEDIA_CACHE_PATH          = each.value.paths.media_cache_path
    REAR_DIFF_MEDIA_LIBRARY_PATH_MOVIES = each.value.paths.media_library_path_movies
    REAR_DIFF_MEDIA_LIBRARY_PATH_TV     = each.value.paths.media_library_path_tv
  }
}

# Create Secrets for sensitive env vars - use toset() to iterate over environments
resource "kubernetes_secret" "rear_diff_secrets" {
  for_each = toset(local.environments)

  metadata {
    name      = "rear-diff-secrets"
    namespace = "media-${each.key}"
  }

  data = {
    REAR_DIFF_PGSQL_USERNAME        = var.rear_diff_secrets[each.key].pgsql.username
    REAR_DIFF_PGSQL_PASSWORD        = var.rear_diff_secrets[each.key].pgsql.password
    REAR_DIFF_TRANSMISSION_USERNAME = var.rear_diff_secrets[each.key].transmission.username
    REAR_DIFF_TRANSMISSION_PASSWORD = var.rear_diff_secrets[each.key].transmission.password
  }

  type = "Opaque"
}

################################################################################
# center-conseole config
################################################################################

# Create ConfigMaps for non-sensitive env vars
resource "kubernetes_config_map" "center_console_config" {
  for_each = var.center_console_config

  metadata {
    name      = "center-console-config"
    namespace = "media-${each.key}"
  }

  data = {
    CENTER_CONSOLE_API_TIMEOUT   = each.value.api_timeout
    CENTER_CONSOLE_PORT_EXTERNAL = each.value.port_external
  }
}

################################################################################
# reel-driver config maps and secrets  
################################################################################

# Create ConfigMaps for non-sensitive reel-driver env vars
resource "kubernetes_config_map" "reel_driver_config" {
  for_each = toset(local.environments)

  metadata {
    name      = "reel-driver-config"
    namespace = "media-${each.key}"
  }

  data = {
    REEL_DRIVER_MLFLOW_HOST       = var.reel_driver_config[each.key].mflow.host
    REEL_DRIVER_MLFLOW_PORT       = var.reel_driver_config[each.key].mflow.port
    REEL_DRIVER_MLFLOW_EXPERIMENT = var.reel_driver_config[each.key].mflow.experiment
    REEL_DRIVER_MLFLOW_MODEL      = var.reel_driver_config[each.key].mflow.model
    REEL_DRIVER_MINIO_ENDPOINT    = var.reel_driver_config[each.key].minio.endpoint
    REEL_DRIVER_MINIO_PORT        = var.reel_driver_config[each.key].minio.port
  }
}

# Create ConfigMaps for reel-driver training configuration
resource "kubernetes_config_map" "reel_driver_training_config" {
  for_each = toset(local.environments)

  metadata {
    name      = "reel-driver-training-config"
    namespace = "media-${each.key}"
  }

  data = {
    REEL_DRIVER_TRNG_HYPER_PARAM_SEARCH_START = var.reel_driver_training_config[each.key].hyper_param_search_start
    REEL_DRIVER_TRNG_PGSQL_HOST               = var.reel_driver_training_config[each.key].pgsql.host
    REEL_DRIVER_TRNG_PGSQL_PORT               = var.reel_driver_training_config[each.key].pgsql.port
    REEL_DRIVER_TRNG_PGSQL_DATABASE           = var.reel_driver_training_config[each.key].pgsql.database
    REEL_DRIVER_TRNG_PGSQL_SCHEMA             = var.reel_driver_training_config[each.key].pgsql.schema
  }
}

# Create Secrets for sensitive reel-driver env vars
resource "kubernetes_secret" "reel_driver_secrets" {
  for_each = toset(local.environments)

  metadata {
    name      = "reel-driver-secrets"
    namespace = "media-${each.key}"
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
    name      = "reel-driver-training-secrets"
    namespace = "media-${each.key}"
  }

  data = {
    REEL_DRIVER_TRNG_PGSQL_USERNAME = var.reel_driver_training_secrets[each.key].pgsql.username
    REEL_DRIVER_TRNG_PGSQL_PASSWORD = var.reel_driver_training_secrets[each.key].pgsql.password
  }

  type = "Opaque"
}

################################################################################
# end of main.tf
################################################################################
