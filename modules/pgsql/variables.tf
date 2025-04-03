variable "server_ip" {
  description = "interal ip address of servers hosts cluster"
  type = string
}

variable "pgsql_config" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    prod = object({
      user = string
      password = string
      database = string
      mount = string
      performance = object({
        shared_buffers = number
        work_mem = number
        maintenance_work_mem = number
        max_connections = number
        effective_cache_size = number
      })
      security = object({
        UID = number
        GID = number 
      })
    })
    stg = object({
      user = string
      password = string
      database = string
      mount = string
      performance = object({
        shared_buffers = number
        work_mem = number
        maintenance_work_mem = number
        max_connections = number
        effective_cache_size = number
      })
      security = object({
        UID = number
        GID = number 
      })
    })
    dev = object({
      user = string
      password = string
      database = string
      mount = string
      performance = object({
        shared_buffers = number
        work_mem = number
        maintenance_work_mem = number
        max_connections = number
        effective_cache_size = number
      })
      security = object({
        UID = number
        GID = number 
      })
    })
  })
  sensitive = true
}

variable "pgadmin4_config" {
  description = "config vars for the pgadmin4 web app"
  type = object({
    email = string
    password = string
    UID = number
    GID = number
    fs_group = number
    mount = string
    port = number
    server_mode = bool
    listen_address = string
    listen_port = number
  })
  sensitive = true
}