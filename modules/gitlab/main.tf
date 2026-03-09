################################################################################
# gitlab module main configuration
################################################################################

# Create gitlab namespace
resource "kubernetes_namespace_v1" "gitlab" {
  metadata {
    name = "gitlab"
    labels = {
      managed-by = "terraform"
      purpose    = "gitlab-runner"
    }
  }
}

################################################################################
# namespace resource quotas
################################################################################

resource "kubernetes_resource_quota_v1" "gitlab_quota" {
  metadata {
    name      = "gitlab-resource-quota"
    namespace = kubernetes_namespace_v1.gitlab.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.gitlab_config.resource_quota.cpu_request
      "limits.cpu"      = var.gitlab_config.resource_quota.cpu_limit
      "requests.memory" = var.gitlab_config.resource_quota.memory_request
      "limits.memory"   = var.gitlab_config.resource_quota.memory_limit
    }
  }
}

################################################################################
# namespace limit ranges - default container limits
################################################################################

resource "kubernetes_limit_range_v1" "gitlab_limits" {
  metadata {
    name      = "gitlab-limit-range"
    namespace = kubernetes_namespace_v1.gitlab.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.gitlab_config.container_defaults.cpu_limit
        memory = var.gitlab_config.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.gitlab_config.container_defaults.cpu_request
        memory = var.gitlab_config.container_defaults.memory_request
      }
    }
  }
}

################################################################################
# gitlab runner authentication token secret
# Token format: glrt-xxxx (generated via GitLab UI: Admin > CI/CD > Runners)
################################################################################

resource "kubernetes_secret_v1" "gitlab_runner_token" {
  metadata {
    name      = "gitlab-runner-token"
    namespace = kubernetes_namespace_v1.gitlab.metadata[0].name
    labels = {
      app        = "gitlab-runner"
      managed-by = "terraform"
    }
  }

  type = "Opaque"

  data = {
    runner-token = var.gitlab_sensitive.runner_token
  }
}

################################################################################
# gitlab runner configmap
################################################################################

resource "kubernetes_config_map_v1" "gitlab_runner_config" {
  metadata {
    name      = "gitlab-runner-config"
    namespace = kubernetes_namespace_v1.gitlab.metadata[0].name
    labels = {
      app        = "gitlab-runner"
      managed-by = "terraform"
    }
  }

  data = {
    gitlab_url      = var.gitlab_config.gitlab_url
    registry_url    = var.gitlab_config.registry_url
    runner_executor = "kubernetes"
  }
}
################################################################################
# end of main.tf
################################################################################
