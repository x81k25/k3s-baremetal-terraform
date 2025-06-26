################################################################################
# media module
################################################################################

# create locals that will be passed to media as vars
locals {
  wst_config = {
    pgsql = {
      for env in ["prod", "stg", "dev"] : env => {
        host     = var.server_ip
        port     = var.pgsql_default_config[env].port
        database = var.pgsql_default_config.database
      }
    }
  }
}

################################################################################
# end of locals.tf
################################################################################