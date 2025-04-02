################################################################################
# pgsql namespace
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
# PostgreSQL Dev Environment Secrets
################################################################################

resource "kubernetes_secret" "pgsql_dev_secrets" {
  metadata {
    name      = "pgsql-dev-secrets"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = "dev"
      managed-by = "terraform"
    }
  }

  data = {
    username = var.pgsql_config.dev.user
    password = var.pgsql_config.dev.password
    database = var.pgsql_config.dev.database
    port     = tostring(var.pgsql_config.dev.port)
    server_ip = var.server_ip
    mount    = var.pgsql_config.dev.mount
  }

  type = "Opaque"
}

################################################################################
# PostgreSQL Staging Environment Secrets
################################################################################

resource "kubernetes_secret" "pgsql_stg_secrets" {
  metadata {
    name      = "pgsql-stg-secrets"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = "stg"
      managed-by = "terraform"
    }
  }

  data = {
    username = var.pgsql_config.stg.user
    password = var.pgsql_config.stg.password
    database = var.pgsql_config.stg.database
    port     = tostring(var.pgsql_config.stg.port)
    server_ip = var.server_ip
    mount    = var.pgsql_config.stg.mount
  }

  type = "Opaque"
}

################################################################################
# PostgreSQL Production Environment Secrets
################################################################################

resource "kubernetes_secret" "pgsql_prod_secrets" {
  metadata {
    name      = "pgsql-prod-secrets"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = "prod"
      managed-by = "terraform"
    }
  }

  data = {
    username = var.pgsql_config.prod.user
    password = var.pgsql_config.prod.password
    database = var.pgsql_config.prod.database
    port     = tostring(var.pgsql_config.prod.port)
    server_ip = var.server_ip
    mount    = var.pgsql_config.prod.mount
  }

  type = "Opaque"
}

################################################################################
# PostgreSQL Performance Config Secrets
################################################################################

resource "kubernetes_secret" "pgsql_dev_performance" {
  metadata {
    name      = "pgsql-dev-performance"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = "dev"
      managed-by = "terraform"
      type       = "performance"
    }
  }

  data = {
    shared_buffers      = tostring(var.pgsql_config.dev.performance.shared_buffers)
    work_mem            = tostring(var.pgsql_config.dev.performance.work_mem)
    maintenance_work_mem = tostring(var.pgsql_config.dev.performance.maintenance_work_mem)
    max_connections     = tostring(var.pgsql_config.dev.performance.max_connections)
    effective_cache_size = tostring(var.pgsql_config.dev.performance.effective_cache_size)
  }

  type = "Opaque"
}

resource "kubernetes_secret" "pgsql_stg_performance" {
  metadata {
    name      = "pgsql-stg-performance"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = "stg"
      managed-by = "terraform"
      type       = "performance"
    }
  }

  data = {
    shared_buffers      = tostring(var.pgsql_config.stg.performance.shared_buffers)
    work_mem            = tostring(var.pgsql_config.stg.performance.work_mem)
    maintenance_work_mem = tostring(var.pgsql_config.stg.performance.maintenance_work_mem)
    max_connections     = tostring(var.pgsql_config.stg.performance.max_connections)
    effective_cache_size = tostring(var.pgsql_config.stg.performance.effective_cache_size)
  }

  type = "Opaque"
}

resource "kubernetes_secret" "pgsql_prod_performance" {
  metadata {
    name      = "pgsql-prod-performance"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = "prod"
      managed-by = "terraform"
      type       = "performance"
    }
  }

  data = {
    shared_buffers      = tostring(var.pgsql_config.prod.performance.shared_buffers)
    work_mem            = tostring(var.pgsql_config.prod.performance.work_mem)
    maintenance_work_mem = tostring(var.pgsql_config.prod.performance.maintenance_work_mem)
    max_connections     = tostring(var.pgsql_config.prod.performance.max_connections)
    effective_cache_size = tostring(var.pgsql_config.prod.performance.effective_cache_size)
  }

  type = "Opaque"
}

################################################################################
# PostgreSQL Security Config Secrets
################################################################################

resource "kubernetes_secret" "pgsql_security" {
  for_each = {
    dev  = var.pgsql_config.dev.security
    stg  = var.pgsql_config.stg.security
    prod = var.pgsql_config.prod.security
  }

  metadata {
    name      = "pgsql-${each.key}-security"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = each.key
      managed-by = "terraform"
      type       = "security"
    }
  }

  data = {
    uid = tostring(each.value.UID)
    gid = tostring(each.value.GID)
  }

  type = "Opaque"
}

################################################################################
# pgAdmin4 Secrets
################################################################################

resource "kubernetes_secret" "pgadmin4_secrets" {
  metadata {
    name      = "pgadmin4-secrets"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgadmin4"
      managed-by = "terraform"
    }
  }

  data = {
    email         = var.pgadmin4_config.email
    password      = var.pgadmin4_config.password
    uid           = tostring(var.pgadmin4_config.UID)
    gid           = tostring(var.pgadmin4_config.GID)
    fs_group      = tostring(var.pgadmin4_config.fs_grounp)
    listen_address = var.pgadmin4_config.listen_address
    listen_port    = tostring(var.pgadmin4_config.listen_port)
    server_mode    = tostring(var.pgadmin4_config.server_mode)
    server_ip      = var.server_ip
    mount          = var.pgadmin4_config.mount
    port           = tostring(var.pgadmin4_config.port)
  }

  type = "Opaque"
}

################################################################################
# pgAdmin4 Server Connections Secret
################################################################################

resource "kubernetes_secret" "pgadmin4_servers" {
  metadata {
    name      = "pgadmin4-servers-secret"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgadmin4"
      managed-by = "terraform"
    }
  }

  data = {
    "servers.json" = jsonencode({
      Servers = {
        "1" = {
          Name = "PostgreSQL-DEV"
          Group = "Development"
          Host = "dev-pgsql.${kubernetes_namespace.pgsql.metadata[0].name}.svc.cluster.local"
          Port = var.pgsql_config.dev.port
          MaintenanceDB = var.pgsql_config.dev.database
          Username = var.pgsql_config.dev.user
          Password = var.pgsql_config.dev.password
          SSLMode = "prefer"
        },
        "2" = {
          Name = "PostgreSQL-STG"
          Group = "Staging"
          Host = "stg-pgsql.${kubernetes_namespace.pgsql.metadata[0].name}.svc.cluster.local"
          Port = var.pgsql_config.stg.port
          MaintenanceDB = var.pgsql_config.stg.database
          Username = var.pgsql_config.stg.user
          Password = var.pgsql_config.stg.password
          SSLMode = "prefer"
        },
        "3" = {
          Name = "PostgreSQL-PROD"
          Group = "Production"
          Host = "prod-pgsql.${kubernetes_namespace.pgsql.metadata[0].name}.svc.cluster.local"
          Port = var.pgsql_config.prod.port
          MaintenanceDB = var.pgsql_config.prod.database
          Username = var.pgsql_config.prod.user
          Password = var.pgsql_config.prod.password
          SSLMode = "prefer"
        }
      }
    })
  }

  type = "Opaque"
}

################################################################################
# Global Configuration Secret
################################################################################

resource "kubernetes_config_map" "server_ip_config" {
  metadata {
    name      = "server-ip-config"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      managed-by = "terraform"
    }
  }

  data = {
    SERVER_IP = var.server_ip
  }
}

################################################################################
# end of main.tf
################################################################################