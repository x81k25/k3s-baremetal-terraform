variable "pgsql_config" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    prod = object({
      port = number
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
      port = number
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
      port = number
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