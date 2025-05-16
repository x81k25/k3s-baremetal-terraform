variable "dagster_config" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    prod = object({
      home_path = string
      workspace_path = string
    })
    stg = object({
      home_path = string
      workspace_path = string
    })
    dev = object({
      home_path = string
      workspace_path = string
    })
  })
}

variable "github_config" {
  description = "GitHub and GitHub Container Registry configuration"
  type = object({
    username         = string
    email            = string
    k8s_manifests_repo = string
    argo_cd_pull_k8s_manifests_token = string
    argo_cd_pull_image_token = string
  })
  sensitive = true
}

variable "dagster_pgsql_config" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    prod = object({
      user = string
      password = string
      host = string
      port = number
      database = string
    })
    stg = object({
      user = string
      password = string
      host = string
      port = number
      database = string
    })
    dev = object({
      user = string
      password = string
      host = string
      port = number
      database = string
    })
  })
  sensitive = true
}
