################################################################################
# observability module main configuration
################################################################################

# Create observability namespace
resource "kubernetes_namespace" "observability" {
  metadata {
    name = "observability"
    labels = {
      managed-by = "terraform"
      purpose    = "observability-stack"
    }
  }
}

################################################################################
# namespace resource quotas
################################################################################

resource "kubernetes_resource_quota" "observability_quota" {
  metadata {
    name      = "observability-resource-quota"
    namespace = kubernetes_namespace.observability.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.observability_config.resource_quota.cpu_request
      "limits.cpu"      = var.observability_config.resource_quota.cpu_limit
      "requests.memory" = var.observability_config.resource_quota.memory_request
      "limits.memory"   = var.observability_config.resource_quota.memory_limit
    }
  }
}

################################################################################
# namespace limit ranges - default container limits
################################################################################

resource "kubernetes_limit_range" "observability_limits" {
  metadata {
    name      = "observability-limit-range"
    namespace = kubernetes_namespace.observability.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.observability_config.container_defaults.cpu_limit
        memory = var.observability_config.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.observability_config.container_defaults.cpu_request
        memory = var.observability_config.container_defaults.memory_request
      }
    }
  }
}

# Create Loki credentials secret
resource "kubernetes_secret" "loki_credentials" {
  metadata {
    name      = "loki-credentials"
    namespace = kubernetes_namespace.observability.metadata[0].name
    labels = {
      app        = "loki"
      managed-by = "terraform"
    }
  }

  type = "Opaque"

  data = {
    username = var.loki_sensitive.user
    password = var.loki_sensitive.password
  }
}

# Create Grafana credentials secret
resource "kubernetes_secret" "grafana_credentials" {
  metadata {
    name      = "grafana-credentials"
    namespace = kubernetes_namespace.observability.metadata[0].name
    labels = {
      app        = "grafana"
      managed-by = "terraform"
    }
  }

  type = "Opaque"

  data = {
    username = var.grafana_sensitive.user
    password = var.grafana_sensitive.password
  }
}

################################################################################
# end of main.tf
################################################################################