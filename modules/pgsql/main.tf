################################################################################
# namespace 
################################################################################

resource "kubernetes_namespace" "pgsql" {
  metadata {
    name = "pgsql"
    labels = {
      managed-by = "terraform"
    }
  }
}

################################################################################
# pgsql config pass
################################################################################

resource "kubernetes_secret" "pgsql_prod_config" {
  metadata {
    name      = "pgsql-prod-config"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
  }

  data = {
    pgsql_prod_user     = var.pgsql_config.prod.user
    pgsql_prod_password = var.pgsql_config.prod.password
    pgsql_prod_database = var.pgsql_config.prod.database
  }

  type = "Opaque"
}

resource "kubernetes_secret" "pgsql_stg_config" {
  metadata {
    name      = "pgsql-stg-config"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
  }

  data = {
    pgsql_stg_user     = var.pgsql_config.stg.user
    pgsql_stg_password = var.pgsql_config.stg.password
    pgsql_stg_database = var.pgsql_config.stg.database
  }

  type = "Opaque"
}

resource "kubernetes_secret" "pgsql_dev_config" {
  metadata {
    name      = "pgsql-dev-config"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
  }

  data = {
    pgsql_dev_user     = var.pgsql_config.dev.user
    pgsql_dev_password = var.pgsql_config.dev.password
    pgsql_dev_database = var.pgsql_config.dev.database
  }

  type = "Opaque"
}

################################################################################
# pgadmin config pass
################################################################################

resource "kubernetes_secret" "pgadmin_credentials" {
  metadata {
    name      = "pgadmin-credentials"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
  }

  data = {
    pgadmin_email    = var.pgadmin4_config.email
    pgadmin_password = var.pgadmin4_config.password
  }

  type = "Opaque"
}

################################################################################
# end of main.tf
################################################################################