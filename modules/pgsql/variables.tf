################################################################################
# global vars
################################################################################

variable "server_ip" {
  description = "interal ip address of servers hosts cluster"
  type        = string
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

################################################################################
# postgres vars
################################################################################

variable "pgsql_config" {
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

################################################################################
# flyway vars
################################################################################

variable "flyway_config" {
  description = "environment variables to fun flyway migration containers"
  type = object({
    prod = object({
      pgsql = object({
        host = string
        port = string
        database = string
      })
    })  
    stg = object({
      pgsql = object({
        host = string
        port = string
        database = string
      })
    })
    dev = object({
      pgsql = object({
        host = string
        port = string
        database = string
      })
    })
  })
}

variable "flyway_secrets" {
  description = "secret env vars for flyway migration containers"
  type = object({
    prod = object({
      pgsql = object({  
        username = string
        password = string
      })
    })
    stg = object({
      pgsql = object({  
        username = string
        password = string
      })
    })
    dev = object({
      pgsql = object({  
        username = string
        password = string
      })
    })
  })
}

################################################################################
# pgadmin vars
################################################################################

variable "pgadmin4_config" {
  description = "config vars for the pgadmin4 web app"
  type = object({
    email    = string
    password = string
  })
  sensitive = true
}

################################################################################
# end of ./modules/pgsql/variables.tf
################################################################################