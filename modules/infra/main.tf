resource "kubernetes_namespace_v1" "infra" {
  metadata {
    name = "infra"
    labels = {
      "managed-by" = "terraform"
    }
  }
}

################################################################################
# namespace resource quotas
################################################################################

resource "kubernetes_resource_quota_v1" "infra_quota" {
  metadata {
    name      = "infra-resource-quota"
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.infra_config.resource_quota.cpu_request
      "limits.cpu"      = var.infra_config.resource_quota.cpu_limit
      "requests.memory" = var.infra_config.resource_quota.memory_request
      "limits.memory"   = var.infra_config.resource_quota.memory_limit
    }
  }
}

################################################################################
# namespace limit ranges - default container limits
################################################################################

resource "kubernetes_limit_range_v1" "infra_limits" {
  metadata {
    name      = "infra-limit-range"
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.infra_config.container_defaults.cpu_limit
        memory = var.infra_config.container_defaults.memory_limit
      }
      default_request = {
        cpu    = var.infra_config.container_defaults.cpu_request
        memory = var.infra_config.container_defaults.memory_request
      }
    }
  }
}

################################################################################
# adguard home - dns server
################################################################################

resource "kubernetes_config_map_v1" "adguard_config" {
  metadata {
    name      = "adguard-config"
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
  }

  data = {
    "AdGuardHome.yaml" = templatefile("${path.module}/templates/AdGuardHome.yaml.tftpl", {
      server_ip       = var.server_ip
      tailscale_ip    = var.adguard_config.tailscale_ip
      upstream_dns    = var.adguard_config.upstream_dns
      dns_rewrites    = var.adguard_config.dns_rewrites
      username        = var.adguard_secrets.username
      password_bcrypt = var.adguard_secrets.password_bcrypt
    })
  }
}

resource "kubernetes_deployment_v1" "adguard" {
  metadata {
    name      = "adguard"
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
    labels = {
      app = "adguard"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "adguard"
      }
    }

    template {
      metadata {
        labels = {
          app = "adguard"
        }
      }

      spec {
        host_network = true
        dns_policy   = "ClusterFirstWithHostNet"

        # init container: copy configmap to writable hostpath
        init_container {
          name    = "copy-config"
          image             = "busybox:1.37"
          image_pull_policy = "IfNotPresent"
          command           = ["sh", "-c", "cp /tmp/adguard/AdGuardHome.yaml /opt/adguardhome/conf/AdGuardHome.yaml"]

          volume_mount {
            name       = "config-temp"
            mount_path = "/tmp/adguard"
            read_only  = true
          }

          volume_mount {
            name       = "conf-dir"
            mount_path = "/opt/adguardhome/conf"
          }
        }

        # main container
        container {
          name  = "adguard"
          image             = "adguard/adguardhome:${var.adguard_config.image_tag}"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 53
            protocol       = "UDP"
            name           = "dns-udp"
          }

          port {
            container_port = 53
            protocol       = "TCP"
            name           = "dns-tcp"
          }

          port {
            container_port = 3000
            protocol       = "TCP"
            name           = "web-ui"
          }

          volume_mount {
            name       = "conf-dir"
            mount_path = "/opt/adguardhome/conf"
          }

          volume_mount {
            name       = "work-dir"
            mount_path = "/opt/adguardhome/work"
          }

          resources {
            requests = {
              cpu    = var.adguard_config.resources.cpu_request
              memory = var.adguard_config.resources.memory_request
            }
            limits = {
              cpu    = var.adguard_config.resources.cpu_limit
              memory = var.adguard_config.resources.memory_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 15
            period_seconds        = 10
          }
        }

        volume {
          name = "config-temp"
          config_map {
            name = kubernetes_config_map_v1.adguard_config.metadata[0].name
          }
        }

        volume {
          name = "conf-dir"
          host_path {
            path = "/d/k8s/volumes/adguard/conf"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "work-dir"
          host_path {
            path = "/d/k8s/volumes/adguard/work"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "adguard_dns" {
  metadata {
    name      = "adguard-dns"
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
  }

  spec {
    type = "NodePort"

    selector = {
      app = "adguard"
    }

    port {
      name        = "dns-udp"
      port        = 53
      target_port = 53
      node_port   = var.adguard_config.dns_node_port
      protocol    = "UDP"
    }

    port {
      name        = "dns-tcp"
      port        = 53
      target_port = 53
      node_port   = var.adguard_config.dns_node_port
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_service_v1" "adguard_web" {
  metadata {
    name      = "adguard-web"
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
  }

  spec {
    type = "NodePort"

    selector = {
      app = "adguard"
    }

    port {
      port        = 3000
      target_port = 3000
      node_port   = var.adguard_config.web_node_port
      protocol    = "TCP"
    }
  }
}

################################################################################
# traefik ingress
################################################################################

resource "kubernetes_ingress_v1" "adguard_ingress" {
  metadata {
    name      = "adguard-ingress"
    namespace = kubernetes_namespace_v1.infra.metadata[0].name
  }

  spec {
    ingress_class_name = "traefik"

    rule {
      host = "adguard.x81"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.adguard_web.metadata[0].name

              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}

################################################################################
# end of modules/infra/main.tf
################################################################################
