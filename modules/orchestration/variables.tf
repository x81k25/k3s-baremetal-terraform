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
