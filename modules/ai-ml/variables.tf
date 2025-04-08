################################################################################
# ai-ml vars
################################################################################

variable "ai_ml_sensitive" {
  description = "credentials needed for the ai-ml namespace"
  type = object({
    mlflow = object({     
      user = string
      password = string
      db = object({
        prod = object({
          user = string
          password = string
          name = string
          port = string
          database = string
        })
        stg = object({
          user = string
          password = string
          name = string
          port = string
          database = string
        })
        dev = object({
          user = string
          password = string
          name = string
          port = string
          database = string
        })
        
      })
      artifact_store = object({
        bucket_name = string
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