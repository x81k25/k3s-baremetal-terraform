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
    username = base64encode(var.loki_sensitive.user)
    password = base64encode(var.loki_sensitive.password)
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
    username = base64encode(var.grafana_sensitive.user)
    password = base64encode(var.grafana_sensitive.password)
  }
}

################################################################################
# end of main.tf
################################################################################