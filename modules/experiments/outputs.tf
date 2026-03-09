output "namespace_name" {
  description = "Name of the experiments namespace"
  value       = kubernetes_namespace_v1.experiments.metadata[0].name
}