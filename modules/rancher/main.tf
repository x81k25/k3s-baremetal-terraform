resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "time_sleep" "wait_for_cert_manager" {
  depends_on = [helm_release.cert_manager]
  create_duration = "30s"
}

resource "null_resource" "cleanup_cattle_system" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl patch namespace cattle-system -p '{"metadata":{"finalizers":[]}}' --type=merge || true
      kubectl delete namespace cattle-system --force --grace-period=0 || true
      
      while kubectl get namespace cattle-system >/dev/null 2>&1; do
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
  version          = var.rancher_version

  set {
    name  = "hostname"
    value = var.rancher_hostname  
  }

  set {
    name  = "ingress.tls.source"
    value = "secret"
  }

  set {
    name  = "bootstrapPassword"
    value = var.rancher_password
  }

  set {
    name  = "replicas"
    value = "1"
  }

  set {
    name  = "tls"
    value = "external"
  }

  timeout = 600

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      kubectl delete job -n cattle-system rancher-post-delete || true
      kubectl delete namespace cattle-system || true
    EOT
  }
}

resource "time_sleep" "wait_for_rancher" {
  depends_on = [helm_release.rancher]
  create_duration = "90s"
}

resource "null_resource" "update_hosts_file" {
  provisioner "local-exec" {
    command = <<-EOT
      grep -q "${var.rancher_hostname}" /etc/hosts || \
      echo "${var.server_ip} ${var.rancher_hostname}" | sudo tee -a /etc/hosts
    EOT
  }
}