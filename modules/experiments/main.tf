resource "kubernetes_namespace" "experiments" {
  metadata {
    name = "experiments"
    labels = {
      "managed-by" = "terraform"
    }
  }
}

################################################################################
# namespace resource quotas
################################################################################

resource "kubernetes_resource_quota" "experiments_quota" {
  metadata {
    name      = "experiments-resource-quota"
    namespace = kubernetes_namespace.experiments.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.experiments_config.resource_quota.cpu_request
      "limits.cpu"      = var.experiments_config.resource_quota.cpu_limit
      "requests.memory" = var.experiments_config.resource_quota.memory_request
      "limits.memory"   = var.experiments_config.resource_quota.memory_limit
    }
  }
}

################################################################################
# namespace limit ranges - default container limits
################################################################################

resource "kubernetes_limit_range" "experiments_limits" {
  metadata {
    name      = "experiments-limit-range"
    namespace = kubernetes_namespace.experiments.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.experiments_config.container_defaults.cpu_limit
        memory = var.experiments_config.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.experiments_config.container_defaults.cpu_request
        memory = var.experiments_config.container_defaults.memory_request
      }
    }
  }
}

# Create GitHub Container Registry secret
resource "kubernetes_secret" "ng_github_registry" {
  metadata {
    name      = "ng-github-registry"
    namespace = kubernetes_namespace.experiments.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          username = var.ng_github_secrets.username
          password = var.ng_github_secrets.token_packages_read
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

################################################################################
# OSRM service configuration and secrets
################################################################################

# Create ConfigMap for OSRM non-sensitive configuration
resource "kubernetes_config_map" "osrm_config" {
  metadata {
    name      = "osrm-config"
    namespace = kubernetes_namespace.experiments.metadata[0].name
  }

  data = {
    OSM_DOWNLOAD_URL = var.osrm_config.osm_download_url
    OSM_FILENAME     = var.osrm_config.osm_filename
    OSRM_PROFILE     = var.osrm_config.osrm_profile
    OSRM_REGION      = var.osrm_config.osrm_region
    S3_REGION        = var.osrm_config.s3_region
    S3_BUCKET        = var.osrm_config.s3_bucket
  }
}

# Create Secret for OSRM S3 credentials
resource "kubernetes_secret" "osrm_secrets" {
  metadata {
    name      = "osrm-secrets"
    namespace = kubernetes_namespace.experiments.metadata[0].name
  }

  data = {
    S3_ENDPOINT   = var.osrm_secrets.s3_endpoint
    S3_ACCESS_KEY = var.osrm_secrets.s3_access_key
    S3_SECRET_KEY = var.osrm_secrets.s3_secret_key
  }

  type = "Opaque"
}