resource "helm_release" "cert_manager" {
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

resource "helm_release" "rancher" {
  depends_on = [
    time_sleep.wait_for_cert_manager,
    null_resource.cleanup_cattle_system
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