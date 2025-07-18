resource "kubernetes_resource_quota" "cert_manager_quota" {
  metadata {
    name      = "cert-manager-resource-quota"
    namespace = "cert-manager"
  }

  spec {
    hard = {
      "requests.cpu"    = var.cert_manager_config.resource_quota.cpu_request
      "limits.cpu"      = var.cert_manager_config.resource_quota.cpu_limit
      "requests.memory" = var.cert_manager_config.resource_quota.memory_request
      "limits.memory"   = var.cert_manager_config.resource_quota.memory_limit
    }
  }
}

resource "kubernetes_limit_range" "cert_manager_limits" {
  metadata {
    name      = "cert-manager-limit-range"
    namespace = "cert-manager"
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.cert_manager_config.container_defaults.cpu_limit
        memory = var.cert_manager_config.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.cert_manager_config.container_defaults.cpu_request
        memory = var.cert_manager_config.container_defaults.memory_request
      }
    }
  }
}

resource "helm_release" "cert_manager" {
  depends_on = [
    kubernetes_resource_quota.cert_manager_quota,
    kubernetes_limit_range.cert_manager_limits
  ]
  
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_config.version

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "time_sleep" "wait_for_cert_manager" {
  depends_on      = [helm_release.cert_manager]
  create_duration = "30s"
}

resource "null_resource" "cleanup_cattle_system" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl --kubeconfig=${var.kubeconfig_path} patch namespace cattle-system -p '{"metadata":{"finalizers":[]}}' --type=merge || true
      kubectl --kubeconfig=${var.kubeconfig_path} delete namespace cattle-system --force --grace-period=0 || true
      
      while kubectl --kubeconfig=${var.kubeconfig_path} get namespace cattle-system >/dev/null 2>&1; do
        echo "Waiting for cattle-system namespace to be deleted..."
        sleep 5
      done
    EOT
  }
}

resource "kubernetes_resource_quota" "cattle_system_quota" {
  depends_on = [
    time_sleep.wait_for_cert_manager,
    null_resource.cleanup_cattle_system
  ]
  
  metadata {
    name      = "cattle-system-resource-quota"
    namespace = "cattle-system"
  }

  spec {
    hard = {
      "requests.cpu"    = var.cattle_system_config.resource_quota.cpu_request
      "limits.cpu"      = var.cattle_system_config.resource_quota.cpu_limit
      "requests.memory" = var.cattle_system_config.resource_quota.memory_request
      "limits.memory"   = var.cattle_system_config.resource_quota.memory_limit
    }
  }
}

resource "kubernetes_limit_range" "cattle_system_limits" {
  depends_on = [
    time_sleep.wait_for_cert_manager,
    null_resource.cleanup_cattle_system
  ]
  
  metadata {
    name      = "cattle-system-limit-range"
    namespace = "cattle-system"
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.cattle_system_config.container_defaults.cpu_limit
        memory = var.cattle_system_config.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.cattle_system_config.container_defaults.cpu_request
        memory = var.cattle_system_config.container_defaults.memory_request
      }
    }
  }
}

resource "helm_release" "rancher" {
  depends_on = [
    time_sleep.wait_for_cert_manager,
    null_resource.cleanup_cattle_system,
    kubernetes_resource_quota.cattle_system_quota,
    kubernetes_limit_range.cattle_system_limits
  ]
  name             = "rancher"
  namespace        = "cattle-system"
  create_namespace = true
  repository       = "https://releases.rancher.com/server-charts/stable"
  chart            = "rancher"
  version          = var.rancher_config.version

  set {
    name  = "hostname"
    value = var.rancher_config.hostname
  }

  set {
    name  = "ingress.tls.source"
    value = "secret"
  }

  set {
    name  = "bootstrapPassword"
    value = var.rancher_sensitive.admin_pw
  }

  set {
    name  = "replicas"
    value = "1"
  }

  set {
    name  = "tls"
    value = "external"
  }

  # Add these new settings
  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.extraAnnotations.kubernetes\\.io/ingress\\.class"
    value = "traefik"
  }

  set {
    name  = "ingress.http"
    value = var.rancher_config.ingress_config.http_enabled
  }

  set {
    name  = "ingress.https"
    value = var.rancher_config.ingress_config.https_enabled
  }

  timeout = 600

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete job -n cattle-system rancher-post-delete || true && kubectl delete namespace cattle-system || true"
  }
}

resource "time_sleep" "wait_for_rancher" {
  depends_on      = [helm_release.rancher]
  create_duration = "90s"
}

resource "null_resource" "update_hosts_file" {
  provisioner "local-exec" {
    command = <<-EOT
      grep -q "${var.rancher_config.hostname}" /etc/hosts || \
      echo "${var.server_ip} ${var.rancher_config.hostname}" | sudo tee -a /etc/hosts
    EOT
  }
}