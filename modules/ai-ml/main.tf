################################################################################
# namespace 
################################################################################

resource "kubernetes_namespace" "ai_ml" {
  metadata {
    name = "ai-ml"
    labels = {
      managed-by = "terraform"
    }
  }
}

################################################################################
# secrets
################################################################################

resource "kubernetes_secret" "mlflow_secret" {
  metadata {
    name      = "mlflow-secret"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    mlflow_user     = var.ai_ml_sensitive.mlflow.user
    mlflow_password = var.ai_ml_sensitive.mlflow.password
  }

  type = "Opaque"
}

resource "kubernetes_secret" "mlflow_prod_secret" {
  metadata {
    name      = "mlflow-prod-secret"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    mlflow_prod_user     = var.ai_ml_sensitive.mlflow.db.prod.user
    mlflow_prod_password = var.ai_ml_sensitive.mlflow.db.prod.password
    mlflow_prod_name     = var.ai_ml_sensitive.mlflow.db.prod.name
    mlflow_prod_port     = var.ai_ml_sensitive.mlflow.db.prod.port
    mlflow_prod_database = var.ai_ml_sensitive.mlflow.db.prod.database
  }

  type = "Opaque"
}

resource "kubernetes_secret" "mlflow_stg_secret" {
  metadata {
    name      = "mlflow-stg-secret"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    mlflow_stg_user     = var.ai_ml_sensitive.mlflow.db.stg.user
    mlflow_stg_password = var.ai_ml_sensitive.mlflow.db.stg.password
    mlflow_stg_name     = var.ai_ml_sensitive.mlflow.db.stg.name
    mlflow_stg_port     = var.ai_ml_sensitive.mlflow.db.stg.port
    mlflow_stg_database = var.ai_ml_sensitive.mlflow.db.stg.database
  }

  type = "Opaque"
}

resource "kubernetes_secret" "mlflow_dev_secret" {
  metadata {
    name      = "mlflow-dev-secret"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    mlflow_dev_user     = var.ai_ml_sensitive.mlflow.db.dev.user
    mlflow_dev_password = var.ai_ml_sensitive.mlflow.db.dev.password
    mlflow_dev_name     = var.ai_ml_sensitive.mlflow.db.dev.name
    mlflow_dev_port     = var.ai_ml_sensitive.mlflow.db.dev.port
    mlflow_dev_database = var.ai_ml_sensitive.mlflow.db.dev.database
  }
 
  type = "Opaque"
}

resource "kubernetes_secret" "mlflow_artifact_store_secret" {
  metadata {
    name      = "mlflow-artifact-store-secret"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    bucket_name = var.ai_ml_sensitive.mlflow.artifact_store.bucket_name
  }
 
  type = "Opaque"
}
 
resource "kubernetes_secret" "minio_secret" {
  metadata {
    name      = "minio-secret"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    minio_access_key = var.ai_ml_sensitive.minio.access_key
    minio_secret_key = var.ai_ml_sensitive.minio.secret_key
  }
 
  type = "Opaque"
}

# pass image pull secret to ai-ml namespace
resource "kubernetes_secret" "ghcr_ai_ml" {
  metadata {
    name      = "ghcr-pull-image-token"
    namespace = "ai-ml"
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

  depends_on = [kubernetes_namespace.ai_ml]
}

################################################################################
# end of main.tf
################################################################################