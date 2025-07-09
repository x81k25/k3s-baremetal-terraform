################################################################################
# ai-ml vars
################################################################################

variable "github_config" {
  description = "github credentials"
  type = object({
    username                         = string
    email                            = string
    k8s_manifests_repo               = string
    argo_cd_pull_k8s_manifests_token = string
    argo_cd_pull_image_token         = string
  })
  sensitive = true
}

variable "mlflow_config" {
  description = "holds all env vars for mlflow"
  type = object({
    prod = object({
      uid = string
      gid = string
      port_external = string
      path = object({
        logs = string
        packages = string
      })
      pgsql = object({
        host = string
        port = string
        database = string
      })
      minio = object({
        default_artifact_root = string
        endpoint = object({
          external = string
          internal = string
        })
        port = object({
          external = string
          internal = string
        })
      })
    })
    stg = object({
      uid = string
      gid = string
      port_external = string
      path = object({
        logs = string
        packages = string
      })
      pgsql = object({
        host = string
        port = string
        database = string
      })
      minio = object({
        default_artifact_root = string
        endpoint = object({
          external = string
          internal = string
        })
        port = object({
          external = string
          internal = string
        })
      })
    })
    dev = object({
      uid = string
      gid = string
      port_external = string
      path = object({
        logs = string
        packages = string
      })
      pgsql = object({
        host = string
        port = string
        database = string
      })
      minio = object({
        default_artifact_root = string
        endpoint = object({
          external = string
          internal = string
        })
        port = object({
          external = string
          internal = string
        })
      })
    })
  })
}

variable "mlflow_secrets" {
  description = "credentials for mlflow instances"
  type = object({
    prod = object({
      username = string
      password = string
      pgsql = object({
        username = string
        password = string
      })
      minio = object({
        aws_access_key_id = string
        aws_secret_access_key = string
      })
    })
    stg = object({
      username = string
      password = string
      pgsql = object({
        username = string
        password = string
      })
      minio = object({
        aws_access_key_id = string
        aws_secret_access_key = string
      })
    })
    dev = object({
      username = string
      password = string
      pgsql = object({
        username = string
        password = string
      })
      minio = object({
        aws_access_key_id = string
        aws_secret_access_key = string
      })
    })
  })
  sensitive = true
}

################################################################################
# end of variables.tf
################################################################################