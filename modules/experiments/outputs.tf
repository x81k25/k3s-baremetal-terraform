output "namespace_name" {
  description = "Name of the experiments namespace"
  value       = kubernetes_namespace.experiments.metadata[0].name
}