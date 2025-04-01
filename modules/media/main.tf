################################################################################
# media namespaces
################################################################################

resource "kubernetes_namespace" "media-prod" {
  metadata {
    name = "media-prod"
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_namespace" "media-stg" {
  metadata {
    name = "media-stg"
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_namespace" "media-dev" {
  metadata {
    name = "media-dev"
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_secret" "plex_secret" {
  metadata {
    name = "plex-config"
    namespace = "media-prod"
  }

  data = {
    PLEX_CLAIM = var.media_sensitive.plex_claim
  }
}

# Create a RuntimeClass for NVIDIA
data "kubernetes_resource" "nvidia_runtime_class" {
  api_version = "node.k8s.io/v1"
  kind        = "RuntimeClass"
  metadata {
    name = "nvidia"
  }
}

# Mount the NVIDIA drivers in the DaemonSet
resource "helm_release" "nvidia_device_plugin" {
  name       = "nvidia-device-plugin"
  repository = "https://nvidia.github.io/k8s-device-plugin"
  chart      = "nvidia-device-plugin"
  namespace  = kubernetes_namespace.media-prod.metadata[0].name
  version    = "0.14.0"

  set {
    name  = "migStrategy"
    value = "none"
  }

  set {
    name  = "compatWithCPUManager"
    value = "true"
  }
  
  # Set the runtime class to use the NVIDIA runtime
  set {
    name  = "runtimeClassName"
    value = "nvidia"
  }
  
  # Add volume mounts for NVIDIA libraries
  values = [
    <<-EOT
    volumeMounts:
      - name: nvidia-driver-libs
        mountPath: /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1
        subPath: libnvidia-ml.so.1
    volumes:
      - name: nvidia-driver-libs
        hostPath:
          path: /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1
          type: File
    EOT
  ]
}

resource "kubernetes_resource_quota" "media_prod_gpu" {
  metadata {
    name      = "gpu-quota"
    namespace = "media-prod"
  }

  spec {
    hard = {
      "nvidia.com/gpu" = 1
    }
  }
}

################################################################################
# end of main.tf
################################################################################
