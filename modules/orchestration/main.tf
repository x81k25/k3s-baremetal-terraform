################################################################################
# namespace 
################################################################################

resource "kubernetes_namespace" "pgsql" {
  metadata {
    name = "orchestration"
    labels = {
      managed-by = "terraform"
    }
  }
}

################################################################################
# env vars
################################################################################

# Create ConfigMap for Dagster host paths - prod
resource "kubernetes_config_map" "dagster_paths_prod" {
  metadata {
    name      = "dagster-paths-prod"
    namespace = "orchestration"
  }

  data = {
    DAGSTER_HOME_PATH     = var.dagster_config.prod.home_path
    DAGSTER_WORKSPACE_PATH = var.dagster_config.prod.workspace_path
  }
}

# Create ConfigMap for Dagster host paths - stg
resource "kubernetes_config_map" "dagster_paths_stg" {
  metadata {
    name      = "dagster-paths-stg"
    namespace = "orchestration"
  }

  data = {
    DAGSTER_HOME_PATH     = var.dagster_config.stg.home_path
    DAGSTER_WORKSPACE_PATH = var.dagster_config.stg.workspace_path
  }
}

# Create ConfigMap for Dagster host paths - dev
resource "kubernetes_config_map" "dagster_paths_dev" {
  metadata {
    name      = "dagster-paths-dev"
    namespace = "orchestration"
  }

  data = {
    DAGSTER_HOME_PATH     = var.dagster_config.dev.home_path
    DAGSTER_WORKSPACE_PATH = var.dagster_config.dev.workspace_path
  }
}

################################################################################
# secrets
################################################################################

# handle database secrets
resource "kubernetes_secret" "pgsql_config_prod" {
  metadata {
    name      = "pgsql-config-prod"
    namespace = "orchestration"
  }

  data = {
    PGSQL_USER     = var.dagster_pgsql_config.prod.user
    PGSQL_PASSWORD = var.dagster_pgsql_config.prod.password
    PGSQL_HOST     = var.dagster_pgsql_config.prod.host
    PGSQL_PORT     = tostring(var.dagster_pgsql_config.prod.port)
    PGSQL_DATABASE = var.dagster_pgsql_config.prod.database
  }

  type = "Opaque"
}

resource "kubernetes_secret" "pgsql_config_stg" {
  metadata {
    name      = "pgsql-config-stg"
    namespace = "orchestration"
  }

  data = {
    PGSQL_USER     = var.dagster_pgsql_config.stg.user
    PGSQL_PASSWORD = var.dagster_pgsql_config.stg.password
    PGSQL_HOST     = var.dagster_pgsql_config.stg.host
    PGSQL_PORT     = tostring(var.dagster_pgsql_config.stg.port)
    PGSQL_DATABASE = var.dagster_pgsql_config.stg.database
  }

  type = "Opaque"
}

resource "kubernetes_secret" "pgsql_config_dev" {
  metadata {
    name      = "pgsql-config-dev"
    namespace = "orchestration"
  }

  data = {
    PGSQL_USER     = var.dagster_pgsql_config.dev.user
    PGSQL_PASSWORD = var.dagster_pgsql_config.dev.password
    PGSQL_HOST     = var.dagster_pgsql_config.dev.host
    PGSQL_PORT     = tostring(var.dagster_pgsql_config.dev.port)
    PGSQL_DATABASE = var.dagster_pgsql_config.dev.database
  }

  type = "Opaque"
}

################################################################################
# end of main.tf
################################################################################