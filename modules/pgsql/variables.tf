################################################################################
# global vars
################################################################################

variable "server_ip" {
  description = "internal ip address of servers hosts cluster"
  type        = string
}

variable "pgsql_namespace_config" {
  description = "Resource configuration for pgsql namespace"
  type = object({
    resource_quota = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
    container_defaults = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
  })
}

variable "pgsql_secrets" {
  description = "PostgreSQL module secrets"
  type = object({
    github = object({
      username = string
      token_packages_read = string
    })
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
# minio vars
################################################################################

variable "minio_config" {
  description = "all env vars for minio"
  type = object({
    prod = object({
      uid = string
      gid = string
      region = string
      port = object({
        external = object({
          console = string
          api     = string
        })
        internal = object({
          api = string
        })
      })
      endpoint = object({
        internal = string
      })
      path = object({
        data = string
      })
    })
    stg = object({
      uid = string
      gid = string
      region = string
      port = object({
        external = object({
          console = string
          api     = string
        })
        internal = object({
          api = string
        })
      })
      endpoint = object({
        internal = string
      })
      path = object({
        data = string
      })
    })
    dev = object({
      uid = string
      gid = string
      region = string
      port = object({
        external = object({
          console = string
          api     = string
        })
        internal = object({
          api = string
        })
      })
      endpoint = object({
        internal = string
      })
      path = object({
        data = string
      })
    })
  })
}

variable "minio_secrets" {
  description = "credentials for minio service"
  type = object({
    prod = object({
      access_key = string
      secret_key = string
    })
    stg = object({
      access_key = string
      secret_key = string
    })
    dev = object({
      access_key = string
      secret_key = string
    })
  })
  sensitive = true
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