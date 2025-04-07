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

resource "kubernetes_secret" "kubeflow_secret" {
  metadata {
    name      = "kubeflow-secret"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    kubeflow_user                   = var.ai_ml_sensitive.kubeflow.user
    kubeflow_password               = var.ai_ml_sensitive.kubeflow.password
    kubeflow_service_account_token  = var.ai_ml_sensitive.kubeflow.service_account_token
    kubeflow_metadata_grpc_token    = var.ai_ml_sensitive.kubeflow.metadata_grpc_token
    kubeflow_pipeline_api_token     = var.ai_ml_sensitive.kubeflow.pipeline_api_token
    kubeflow_pipeline_runner_token  = var.ai_ml_sensitive.kubeflow.pipeline_runner_token
    kubeflow_artifact_fetcher_token = var.ai_ml_sensitive.kubeflow.artifact_fetcher_token
  }

  type = "Opaque"
}

resource "kubernetes_secret" "kubeflow_prod_secret" {
  metadata {
    name      = "kubeflow-prod-secret"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    kubeflow_prod_user     = var.ai_ml_sensitive.kubeflow.db.prod.user
    kubeflow_prod_password = var.ai_ml_sensitive.kubeflow.db.prod.password
    kubeflow_prod_host     = var.ai_ml_sensitive.kubeflow.db.prod.host
    kubeflow_prod_port     = var.ai_ml_sensitive.kubeflow.db.prod.port
  }

  type = "Opaque"
}

resource "kubernetes_secret" "kubeflow_stg_secret" {
  metadata {
    name      = "kubeflow-stg-secret"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    kubeflow_stg_user     = var.ai_ml_sensitive.kubeflow.db.stg.user
    kubeflow_stg_password = var.ai_ml_sensitive.kubeflow.db.stg.password
    kubeflow_stg_host     = var.ai_ml_sensitive.kubeflow.db.stg.host
    kubeflow_stg_port     = var.ai_ml_sensitive.kubeflow.db.stg.port
  }

  type = "Opaque"
}

resource "kubernetes_secret" "kubeflow_dev_secret" {
  metadata {
    name      = "kubeflow-dev-secret"
    namespace = kubernetes_namespace.ai_ml.metadata[0].name
  }

  data = {
    kubeflow_dev_user     = var.ai_ml_sensitive.kubeflow.db.dev.user
    kubeflow_dev_password = var.ai_ml_sensitive.kubeflow.db.dev.password
    kubeflow_dev_host     = var.ai_ml_sensitive.kubeflow.db.dev.host
    kubeflow_dev_port     = var.ai_ml_sensitive.kubeflow.db.dev.port
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

################################################################################
# end of main.tf
################################################################################