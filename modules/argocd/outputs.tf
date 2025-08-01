# ArgoCD namespace
output "namespace" {
  description = "The namespace where ArgoCD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

# ArgoCD server URL
output "server_url" {
  description = "The URL to access ArgoCD server"
  value       = var.argocd_config.ingress.enabled ? "https://${var.argocd_config.ingress.host}" : null
}

# ArgoCD version
output "version" {
  description = "Installed version of ArgoCD"
  value       = var.argocd_config.version
}

# Server service details
output "server_service" {
  description = "ArgoCD server service details"
  value = {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    type      = var.argocd_config.ingress.enabled ? "ClusterIP" : "LoadBalancer"
  }
}

# Deployment status
output "is_ready" {
  description = "Whether ArgoCD deployment is ready"
  value       = null_resource.wait_for_argo.id != "" ? true : false
}

# Configuration status
output "config_status" {
  description = "Configuration status of key ArgoCD features"
  value = {
    ha_enabled      = var.argocd_config.enable_ha
    dex_enabled     = var.argocd_config.enable_dex
    ingress_enabled = var.argocd_config.ingress.enabled
  }
}