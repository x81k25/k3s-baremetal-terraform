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

variable "pgadmin4_config" {
  description = "config vars for the pgadmin4 web app"
  type = object({
    email = string
    password = string
  })
  sensitive = true
}