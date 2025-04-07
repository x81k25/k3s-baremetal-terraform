################################################################################
# ai-ml vars
################################################################################

variable "ai_ml_sensitive" {
  description = "ai-ml config"
  type = object({
    kubeflow = object({     
      user = string
      password = string
      service_account_token = string
      metadata_grpc_token = string
      pipeline_api_token = string
      pipeline_runner_token = string
      artifact_fetcher_token = string
      db = object({
        prod = object({
          user = string
          password = string
          host = string
          port = string
        })
        stg = object({
          user = string
          password = string
          host = string
          port = string
        })
        dev = object({
          user = string
          password = string
          host = string
          port = string
        })
      })
    })
    minio = object({
      access_key = string
      secret_key = string
    })
  })
  sensitive = true
}

################################################################################
# end of variables.tf
################################################################################