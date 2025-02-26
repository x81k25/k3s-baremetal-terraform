output "k3s_config_path" {
  value = "${var.mounts.k3s_root}/config.yaml"
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file for kubectl access"
  value       = "${var.mounts.k3s_root}/k3s.yaml"
}

output "k3s_version" {
  description = "Installed version of K3s"
  value       = var.k3s_config.version
}

output "api_server_url" {
  description = "URL for the Kubernetes API server"
  value       = "https://${var.k3s_config.network_config.host_ip}:6443"
}

output "kubectl_config_command" {
  description = "Command to configure kubectl with the cluster's kubeconfig"
  value       = "export KUBECONFIG=${var.mounts.k3s_root}/k3s.yaml"
}

output "cluster_info_command" {
  description = "Command to verify cluster information"
  value       = "kubectl cluster-info"
}

output "node_status_command" {
  description = "Command to check node status"
  value       = "kubectl get nodes -o wide"
}