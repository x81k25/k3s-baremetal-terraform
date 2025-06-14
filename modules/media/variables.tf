variable "server_ip" {
  type = string
}

variable "github_config" {
  description = "GitHub and GitHub Container Registry configuration"
  type = object({
    username                         = string
    email                            = string
    k8s_manifests_repo               = string
    argo_cd_pull_k8s_manifests_token = string
    argo_cd_pull_image_token         = string
  })
  sensitive = true
}

variable "media_sensitive" {
  type = object({
    plex_claim = string
  })
  sensitive = true
}

variable "ssh_config" {
  type = object({
    user             = string
    private_key_path = string
  })
  sensitive = true
}

variable "vpn_config" {
  description = "vpn credendtials"
  type = object({
    username = string
    password = string
    config   = string
  })
}

variable "rear_diff_pgsql_config" {
  description = "parameters to connect rear differential API to DB"
  type = object({
    prod = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
    stg = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
    dev = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
  })
  sensitive = true
}

variable "dagster_config" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    prod = object({
      home_path      = string
      workspace_path = string
    })
    stg = object({
      home_path      = string
      workspace_path = string
    })
    dev = object({
      home_path      = string
      workspace_path = string
    })
  })
}

variable "dagster_pgsql_config" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    prod = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
    stg = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
    dev = object({
      user     = string
      password = string
      host     = string
      port     = number
      database = string
    })
  })
  sensitive = true
}