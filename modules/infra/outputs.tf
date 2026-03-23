output "namespace_name" {
  description = "Name of the infra namespace"
  value       = kubernetes_namespace_v1.infra.metadata[0].name
}
