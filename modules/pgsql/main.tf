################################################################################
# namespace 
################################################################################

locals {
  environments = ["dev", "stg", "prod"]
}

resource "kubernetes_namespace" "pgsql" {
  metadata {
    name = "pgsql"
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_secret" "github_secrets" {
  metadata {
    name      = "github-secrets"
    namespace = "pgsql"
  }

  data = {
    GHCR_PULL_IMAGE_TOKEN = var.github_config.argo_cd_pull_image_token
  }

  type = "Opaque"
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
# set flywat env vars and secrets
################################################################################

# env vars
resource "kubernetes_config_map" "flway_config_prod" {

  metadata {
    name      = "flyway-config-prod"
    namespace = "pgsql"
  }

  data = {
    FLYWAY_PGSQL_HOST     = var.flyway_config.prod.pgsql.host
    FLYWAY_PGSQL_PORT     = var.flyway_config.prod.pgsql.port
    FLYWAY_PGSQL_DATABASE = var.flyway_config.prod.pgsql.database
  }
}

resource "kubernetes_config_map" "flway_config_stg" {

  metadata {
    name      = "flyway-config-stg"
    namespace = "pgsql"
  }

  data = {
    FLYWAY_PGSQL_HOST     = var.flyway_config.stg.pgsql.host
    FLYWAY_PGSQL_PORT     = var.flyway_config.stg.pgsql.port
    FLYWAY_PGSQL_DATABASE = var.flyway_config.stg.pgsql.database
  }
}

resource "kubernetes_config_map" "flway_config_dev" {

  metadata {
    name      = "flyway-config-dev"
    namespace = "pgsql"
  }

  data = {
    FLYWAY_PGSQL_HOST     = var.flyway_config.dev.pgsql.host
    FLYWAY_PGSQL_PORT     = var.flyway_config.dev.pgsql.port
    FLYWAY_PGSQL_DATABASE = var.flyway_config.dev.pgsql.database
  }
}

# secrets for flyway
resource "kubernetes_secret" "flyway_secrets_prod" {

  metadata {
    name      = "flyway-secrets-prod"
    namespace = "pgsql"
  }

  type = "Opaque"

  data = {
    FLYWAY_PGSQL_USERNAME = var.flyway_secrets.prod.pgsql.username
    FLYWAY_PGSQL_PASSWORD = var.flyway_secrets.prod.pgsql.password
  }
}

resource "kubernetes_secret" "flyway_secrets_stg" {

  metadata {
    name      = "flyway-secrets-stg"
    namespace = "pgsql"
  }

  type = "Opaque"

  data = {
    FLYWAY_PGSQL_USERNAME = var.flyway_secrets.stg.pgsql.username
    FLYWAY_PGSQL_PASSWORD = var.flyway_secrets.stg.pgsql.password
  }
}

resource "kubernetes_secret" "flyway_secrets_dev" {
  metadata {
    name      = "flyway-secrets-dev"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
  }

  data = {
    FLYWAY_PGSQL_USERNAME = var.flyway_secrets.dev.pgsql.username
    FLYWAY_PGSQL_PASSWORD = var.flyway_secrets.dev.pgsql.password
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