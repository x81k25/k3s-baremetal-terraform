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
# Flattened ConfigMaps for each environment
################################################################################

# Development Environment ConfigMap
resource "kubernetes_config_map" "pgsql_dev_config" {
  metadata {
    name      = "pgsql-dev-config"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = "dev"
      managed-by = "terraform"
    }
  }

  data = {
    pgsql_dev_user     = var.pgsql_config.dev.user
    pgsql_dev_database = var.pgsql_config.dev.database
    pgsql_dev_port     = tostring(var.pgsql_config.dev.port)
    pgsql_dev_mount    = var.pgsql_config.dev.mount
    server_ip          = var.server_ip
  }
}

# Staging Environment ConfigMap
resource "kubernetes_config_map" "pgsql_stg_config" {
  metadata {
    name      = "pgsql-stg-config"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = "stg"
      managed-by = "terraform"
    }
  }

  data = {
    pgsql_stg_user     = var.pgsql_config.stg.user
    pgsql_stg_database = var.pgsql_config.stg.database
    pgsql_stg_port     = tostring(var.pgsql_config.stg.port)
    pgsql_stg_mount    = var.pgsql_config.stg.mount
    server_ip          = var.server_ip
  }
}

# Production Environment ConfigMap
resource "kubernetes_config_map" "pgsql_prod_config" {
  metadata {
    name      = "pgsql-prod-config"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = "prod"
      managed-by = "terraform"
    }
  }

  data = {
    pgsql_prod_user     = var.pgsql_config.prod.user
    pgsql_prod_database = var.pgsql_config.prod.database
    pgsql_prod_port     = tostring(var.pgsql_config.prod.port)
    pgsql_prod_mount    = var.pgsql_config.prod.mount
    server_ip           = var.server_ip
  }
}

################################################################################
# Flattened Secrets for each environment
################################################################################

# Development Environment Secrets
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
    pgsql_dev_user     = var.pgsql_config.dev.user
    pgsql_dev_password = var.pgsql_config.dev.password
    pgsql_dev_database = var.pgsql_config.dev.database
    pgsql_dev_port     = tostring(var.pgsql_config.dev.port)
    server_ip          = var.server_ip
    pgsql_dev_mount    = var.pgsql_config.dev.mount
  }

  type = "Opaque"
}

# Staging Environment Secrets
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
    pgsql_stg_user     = var.pgsql_config.stg.user
    pgsql_stg_password = var.pgsql_config.stg.password
    pgsql_stg_database = var.pgsql_config.stg.database
    pgsql_stg_port     = tostring(var.pgsql_config.stg.port)
    server_ip          = var.server_ip
    pgsql_stg_mount    = var.pgsql_config.stg.mount
  }

  type = "Opaque"
}

# Production Environment Secrets
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
    pgsql_prod_user     = var.pgsql_config.prod.user
    pgsql_prod_password = var.pgsql_config.prod.password
    pgsql_prod_database = var.pgsql_config.prod.database
    pgsql_prod_port     = tostring(var.pgsql_config.prod.port)
    server_ip           = var.server_ip
    pgsql_prod_mount    = var.pgsql_config.prod.mount
  }

  type = "Opaque"
}

################################################################################
# Flattened Performance ConfigMaps
################################################################################

# Development Performance ConfigMap
resource "kubernetes_config_map" "pgsql_dev_performance" {
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
    pgsql_dev_shared_buffers      = tostring(var.pgsql_config.dev.performance.shared_buffers)
    pgsql_dev_work_mem            = tostring(var.pgsql_config.dev.performance.work_mem)
    pgsql_dev_maintenance_work_mem = tostring(var.pgsql_config.dev.performance.maintenance_work_mem)
    pgsql_dev_max_connections     = tostring(var.pgsql_config.dev.performance.max_connections)
    pgsql_dev_effective_cache_size = tostring(var.pgsql_config.dev.performance.effective_cache_size)
  }
}

# Staging Performance ConfigMap
resource "kubernetes_config_map" "pgsql_stg_performance" {
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
    pgsql_stg_shared_buffers      = tostring(var.pgsql_config.stg.performance.shared_buffers)
    pgsql_stg_work_mem            = tostring(var.pgsql_config.stg.performance.work_mem)
    pgsql_stg_maintenance_work_mem = tostring(var.pgsql_config.stg.performance.maintenance_work_mem)
    pgsql_stg_max_connections     = tostring(var.pgsql_config.stg.performance.max_connections)
    pgsql_stg_effective_cache_size = tostring(var.pgsql_config.stg.performance.effective_cache_size)
  }
}

# Production Performance ConfigMap
resource "kubernetes_config_map" "pgsql_prod_performance" {
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
    pgsql_prod_shared_buffers      = tostring(var.pgsql_config.prod.performance.shared_buffers)
    pgsql_prod_work_mem            = tostring(var.pgsql_config.prod.performance.work_mem)
    pgsql_prod_maintenance_work_mem = tostring(var.pgsql_config.prod.performance.maintenance_work_mem)
    pgsql_prod_max_connections     = tostring(var.pgsql_config.prod.performance.max_connections)
    pgsql_prod_effective_cache_size = tostring(var.pgsql_config.prod.performance.effective_cache_size)
  }
}

################################################################################
# Flattened Security ConfigMaps
################################################################################

# Development Security ConfigMap
resource "kubernetes_config_map" "pgsql_dev_security" {
  metadata {
    name      = "pgsql-dev-security"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = "dev"
      managed-by = "terraform"
      type       = "security"
    }
  }

  data = {
    pgsql_dev_uid = tostring(var.pgsql_config.dev.security.UID)
    pgsql_dev_gid = tostring(var.pgsql_config.dev.security.GID)
  }
}

# Staging Security ConfigMap
resource "kubernetes_config_map" "pgsql_stg_security" {
  metadata {
    name      = "pgsql-stg-security"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = "stg"
      managed-by = "terraform"
      type       = "security"
    }
  }

  data = {
    pgsql_stg_uid = tostring(var.pgsql_config.stg.security.UID)
    pgsql_stg_gid = tostring(var.pgsql_config.stg.security.GID)
  }
}

# Production Security ConfigMap
resource "kubernetes_config_map" "pgsql_prod_security" {
  metadata {
    name      = "pgsql-prod-security"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgsql"
      environment = "prod"
      managed-by = "terraform"
      type       = "security"
    }
  }

  data = {
    pgsql_prod_uid = tostring(var.pgsql_config.prod.security.UID)
    pgsql_prod_gid = tostring(var.pgsql_config.prod.security.GID)
  }
}

################################################################################
# Flattened pgAdmin4 ConfigMap
################################################################################

resource "kubernetes_config_map" "pgadmin4_config" {
  metadata {
    name      = "pgadmin4-config"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgadmin4"
      managed-by = "terraform"
    }
  }

  data = {
    pgadmin4_email         = var.pgadmin4_config.email
    pgadmin4_uid           = tostring(var.pgadmin4_config.UID)
    pgadmin4_gid           = tostring(var.pgadmin4_config.GID)
    pgadmin4_fs_group      = tostring(var.pgadmin4_config.fs_group)
    pgadmin4_listen_address = var.pgadmin4_config.listen_address
    pgadmin4_listen_port    = tostring(var.pgadmin4_config.listen_port)
    pgadmin4_server_mode    = tostring(var.pgadmin4_config.server_mode)
    pgadmin4_server_ip      = var.server_ip
    pgadmin4_mount          = var.pgadmin4_config.mount
    pgadmin4_port           = tostring(var.pgadmin4_config.port)
  }
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
    pgadmin4_email         = var.pgadmin4_config.email
    pgadmin4_password      = var.pgadmin4_config.password
    pgadmin4_uid           = tostring(var.pgadmin4_config.UID)
    pgadmin4_gid           = tostring(var.pgadmin4_config.GID)
    pgadmin4_fs_group      = tostring(var.pgadmin4_config.fs_group)
    pgadmin4_listen_address = var.pgadmin4_config.listen_address
    pgadmin4_listen_port    = tostring(var.pgadmin4_config.listen_port)
    pgadmin4_server_mode    = tostring(var.pgadmin4_config.server_mode)
    pgadmin4_server_ip      = var.server_ip
    pgadmin4_mount          = var.pgadmin4_config.mount
    pgadmin4_port           = tostring(var.pgadmin4_config.port)
  }

  type = "Opaque"
}

################################################################################
# pgAdmin4 Server Connections Config
################################################################################

resource "kubernetes_config_map" "pgadmin4_servers_config" {
  metadata {
    name      = "pgadmin4-servers-config"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgadmin4"
      managed-by = "terraform"
    }
  }

  data = {
    pgadmin4_dev_server_name = "PostgreSQL-DEV"
    pgadmin4_dev_server_group = "Development"
    pgadmin4_dev_server_host = "dev-pgsql.${kubernetes_namespace.pgsql.metadata[0].name}.svc.cluster.local"
    pgadmin4_dev_server_port = tostring(var.pgsql_config.dev.port)
    pgadmin4_dev_server_db = var.pgsql_config.dev.database
    pgadmin4_dev_server_user = var.pgsql_config.dev.user
    pgadmin4_dev_server_sslmode = "prefer"
    
    pgadmin4_stg_server_name = "PostgreSQL-STG"
    pgadmin4_stg_server_group = "Staging"
    pgadmin4_stg_server_host = "stg-pgsql.${kubernetes_namespace.pgsql.metadata[0].name}.svc.cluster.local"
    pgadmin4_stg_server_port = tostring(var.pgsql_config.stg.port)
    pgadmin4_stg_server_db = var.pgsql_config.stg.database
    pgadmin4_stg_server_user = var.pgsql_config.stg.user
    pgadmin4_stg_server_sslmode = "prefer"
    
    pgadmin4_prod_server_name = "PostgreSQL-PROD"
    pgadmin4_prod_server_group = "Production"
    pgadmin4_prod_server_host = "prod-pgsql.${kubernetes_namespace.pgsql.metadata[0].name}.svc.cluster.local"
    pgadmin4_prod_server_port = tostring(var.pgsql_config.prod.port)
    pgadmin4_prod_server_db = var.pgsql_config.prod.database
    pgadmin4_prod_server_user = var.pgsql_config.prod.user
    pgadmin4_prod_server_sslmode = "prefer"
  }
}

################################################################################
# pgAdmin4 Server Connections Secret for Passwords
################################################################################

resource "kubernetes_secret" "pgadmin4_servers_secrets" {
  metadata {
    name      = "pgadmin4-servers-secrets"
    namespace = kubernetes_namespace.pgsql.metadata[0].name
    labels = {
      app        = "pgadmin4"
      managed-by = "terraform"
    }
  }

  data = {
    pgadmin4_dev_server_password = var.pgsql_config.dev.password
    pgadmin4_stg_server_password = var.pgsql_config.stg.password
    pgadmin4_prod_server_password = var.pgsql_config.prod.password
  }

  type = "Opaque"
}

################################################################################
# Global Configuration 
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
    server_ip = var.server_ip
  }
}

################################################################################
# end of main.tf
################################################################################