resource "kubernetes_namespace" "experiments" {
  metadata {
    name = "experiments"
    labels = {
      "managed-by" = "terraform"
    }
  }
}

################################################################################
# namespace resource quotas
################################################################################

resource "kubernetes_resource_quota" "experiments_quota" {
  metadata {
    name      = "experiments-resource-quota"
    namespace = kubernetes_namespace.experiments.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.experiments_config.resource_quota.cpu_request
      "limits.cpu"      = var.experiments_config.resource_quota.cpu_limit
      "requests.memory" = var.experiments_config.resource_quota.memory_request
      "limits.memory"   = var.experiments_config.resource_quota.memory_limit
    }
  }
}

################################################################################
# namespace limit ranges - default container limits
################################################################################

resource "kubernetes_limit_range" "experiments_limits" {
  metadata {
    name      = "experiments-limit-range"
    namespace = kubernetes_namespace.experiments.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.experiments_config.container_defaults.cpu_limit
        memory = var.experiments_config.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.experiments_config.container_defaults.cpu_request
        memory = var.experiments_config.container_defaults.memory_request
      }
    }
  }
}

# Create GitHub Container Registry secret
resource "kubernetes_secret" "ng_github_registry" {
  metadata {
    name      = "ng-github-registry"
    namespace = kubernetes_namespace.experiments.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          username = var.ng_github_secrets.username
          password = var.ng_github_secrets.token_packages_read
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}