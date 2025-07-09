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
# env vars & secrets
################################################################################

# Create GitHub Container Registry secret
resource "kubernetes_secret" "github_registry" {
  metadata {
    name      = "github-registry"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

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
    MLFLOW_UID                       = each.value.uid
    MLFLOW_GID                       = each.value.gid
    MLFLOW_PORT_EXTERNAL             = each.value.port_external
    MLFLOW_PATH_LOGS                 = each.value.path.logs
    MLFLOW_PATH_PACKAGES             = each.value.path.packages
    MLFLOW_PGSQL_HOST                = each.value.pgsql.host
    MLFLOW_PGSQL_PORT                = each.value.pgsql.port
    MLFLOW_PGSQL_DATABASE            = each.value.pgsql.database
    MLFLOW_MINIO_DEFAULT_ARTIFACT_ROOT = each.value.minio.default_artifact_root
    MLFLOW_MINIO_ENDPOINT            = each.value.minio.endpoint
    MLFLOW_MINIO_PORT                = each.value.minio.port
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
# end of main.tf
################################################################################