################################################################################
# namespace 
################################################################################

locals {
  environments = ["dev", "stg", "prod"]
}

resource "kubernetes_namespace" "pgsql" {
  metadata {
    name = "pgsql"
    labels = {
      managed-by = "terraform"
    }
  }
}

################################################################################
# namespace resource quotas
################################################################################

resource "kubernetes_resource_quota" "pgsql_quota" {
  metadata {
    name      = "pgsql-resource-quota"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.pgsql_namespace_config.resource_quota.cpu_request
      "limits.cpu"      = var.pgsql_namespace_config.resource_quota.cpu_limit
      "requests.memory" = var.pgsql_namespace_config.resource_quota.memory_request
      "limits.memory"   = var.pgsql_namespace_config.resource_quota.memory_limit
    }
  }
}

################################################################################
# namespace limit ranges - default container limits
################################################################################

resource "kubernetes_limit_range" "pgsql_limits" {
  metadata {
    name      = "pgsql-limit-range"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.pgsql_namespace_config.container_defaults.cpu_limit
        memory = var.pgsql_namespace_config.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.pgsql_namespace_config.container_defaults.cpu_request
        memory = var.pgsql_namespace_config.container_defaults.memory_request
      }
    }
  }
}

resource "kubernetes_secret" "ghcr_pull_image_secret" {
  metadata {
    name      = "ghcr-pull-image-secret"
    namespace = "pgsql"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          username = var.pgsql_secrets.github.username
          password = var.pgsql_secrets.github.token_packages_read
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_secret" "gitlab_registry" {
  metadata {
    name      = "gitlab-registry"
    namespace = "pgsql"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "192.168.50.2:5050" = {
          username = var.pgsql_secrets.gitlab.username
          password = var.pgsql_secrets.gitlab.token
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}


################################################################################
# pgsql config pass
################################################################################

resource "kubernetes_secret" "pgsql_prod_config" {
  metadata {
    name      = "pgsql-prod-config"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
  }

  data = {
    pgsql_prod_user     = var.pgsql_config.prod.user
    pgsql_prod_password = var.pgsql_config.prod.password
    pgsql_prod_database = var.pgsql_config.prod.database
  }

  type = "Opaque"
}

resource "kubernetes_secret" "pgsql_stg_config" {
  metadata {
    name      = "pgsql-stg-config"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
  }

  data = {
    pgsql_stg_user     = var.pgsql_config.stg.user
    pgsql_stg_password = var.pgsql_config.stg.password
    pgsql_stg_database = var.pgsql_config.stg.database
  }

  type = "Opaque"
}

resource "kubernetes_secret" "pgsql_dev_config" {
  metadata {
    name      = "pgsql-dev-config"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
  }

  data = {
    pgsql_dev_user     = var.pgsql_config.dev.user
    pgsql_dev_password = var.pgsql_config.dev.password
    pgsql_dev_database = var.pgsql_config.dev.database
  }

  type = "Opaque"
}

################################################################################
# set flywat env vars and secrets
################################################################################

# env vars
resource "kubernetes_config_map" "flway_config_prod" {

  metadata {
    name      = "flyway-config-prod"
    namespace = "pgsql"
  }

  data = {
    FLYWAY_PGSQL_HOST     = var.flyway_config.prod.pgsql.host
    FLYWAY_PGSQL_PORT     = var.flyway_config.prod.pgsql.port
    FLYWAY_PGSQL_DATABASE = var.flyway_config.prod.pgsql.database
  }
}

resource "kubernetes_config_map" "flway_config_stg" {

  metadata {
    name      = "flyway-config-stg"
    namespace = "pgsql"
  }

  data = {
    FLYWAY_PGSQL_HOST     = var.flyway_config.stg.pgsql.host
    FLYWAY_PGSQL_PORT     = var.flyway_config.stg.pgsql.port
    FLYWAY_PGSQL_DATABASE = var.flyway_config.stg.pgsql.database
  }
}

resource "kubernetes_config_map" "flway_config_dev" {

  metadata {
    name      = "flyway-config-dev"
    namespace = "pgsql"
  }

  data = {
    FLYWAY_PGSQL_HOST     = var.flyway_config.dev.pgsql.host
    FLYWAY_PGSQL_PORT     = var.flyway_config.dev.pgsql.port
    FLYWAY_PGSQL_DATABASE = var.flyway_config.dev.pgsql.database
  }
}

# secrets for flyway
resource "kubernetes_secret" "flyway_secrets_prod" {

  metadata {
    name      = "flyway-secrets-prod"
    namespace = "pgsql"
  }

  type = "Opaque"

  data = {
    FLYWAY_PGSQL_USERNAME = var.flyway_secrets.prod.pgsql.username
    FLYWAY_PGSQL_PASSWORD = var.flyway_secrets.prod.pgsql.password
  }
}

resource "kubernetes_secret" "flyway_secrets_stg" {

  metadata {
    name      = "flyway-secrets-stg"
    namespace = "pgsql"
  }

  type = "Opaque"

  data = {
    FLYWAY_PGSQL_USERNAME = var.flyway_secrets.stg.pgsql.username
    FLYWAY_PGSQL_PASSWORD = var.flyway_secrets.stg.pgsql.password
  }
}

resource "kubernetes_secret" "flyway_secrets_dev" {
  metadata {
    name      = "flyway-secrets-dev"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
  }

  data = {
    FLYWAY_PGSQL_USERNAME = var.flyway_secrets.dev.pgsql.username
    FLYWAY_PGSQL_PASSWORD = var.flyway_secrets.dev.pgsql.password
  }

  type = "Opaque"
}

################################################################################
# minio config and secrets
################################################################################

# Create ConfigMaps for non-sensitive minio env vars
resource "kubernetes_config_map" "minio_config" {
  for_each = var.minio_config

  metadata {
    name      = "minio-config-${each.key}"
    namespace = "pgsql"
  }

  data = {
    MINIO_REGION                = each.value.region
    MINIO_PORT_EXTERNAL_CONSOLE = each.value.port.external.console
    MINIO_PORT_EXTERNAL_API     = each.value.port.external.api
    MINIO_PORT_INTERNAL_API     = each.value.port.internal.api
    MINIO_ENDPOINT_INTERNAL     = each.value.endpoint.internal
    MINIO_PATH_DATA             = each.value.path.data
    MINIO_UID                   = each.value.uid
    MINIO_GID                   = each.value.gid
  }
}

# Create Secrets for sensitive minio env vars
resource "kubernetes_secret" "minio_secrets" {
  for_each = toset(local.environments)

  metadata {
    name      = "minio-secrets-${each.key}"
    namespace = "pgsql"
  }

  data = {
    MINIO_ACCESS_KEY = var.minio_secrets[each.key].access_key
    MINIO_SECRET_KEY = var.minio_secrets[each.key].secret_key
  }

  type = "Opaque"
}

################################################################################
# pgadmin config pass
################################################################################

resource "kubernetes_secret" "pgadmin_credentials" {
  metadata {
    name      = "pgadmin-credentials"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
  }

  data = {
    pgadmin_email    = var.pgadmin4_config.email
    pgadmin_password = var.pgadmin4_config.password
  }

  type = "Opaque"
}

################################################################################
# end of main.tf
################################################################################