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
resource "kubernetes_manifest" "nvidia_runtime_class" {
  manifest = {
    apiVersion = "node.k8s.io/v1"
    kind       = "RuntimeClass"
    metadata = {
      name = "nvidia"
    }
    handler = "nvidia"
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

# Improve the NVIDIA Container Toolkit installation
resource "null_resource" "install_nvidia_container_toolkit" {
  provisioner "remote-exec" {
    inline = [
      "distribution=$(. /etc/os-release;echo $ID$VERSION_ID)",
      "curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg",
      "curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list",
      "sudo apt-get update",
      "sudo apt-get install -y nvidia-container-toolkit",
      "sudo nvidia-ctk runtime configure --runtime=containerd",
      
      # Create NVIDIA runtime configuration for containerd
      "sudo mkdir -p /etc/containerd/config.toml.d/",
      "cat <<EOF | sudo tee /etc/containerd/config.toml.d/nvidia-container-runtime.toml",
      "version = 2",
      "",
      "[plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.nvidia]",
      "  privileged_without_host_devices = false",
      "  runtime_engine = \"\"",
      "  runtime_root = \"\"",
      "  runtime_type = \"io.containerd.runc.v2\"",
      "  [plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.nvidia.options]",
      "    BinaryName = \"/usr/bin/nvidia-container-runtime\"",
      "EOF",
      
      # Ensure the NVIDIA driver libraries are accessible
      "sudo ln -sf /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.570.86.15 /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 || true",
      
      # Restart services
      "sudo systemctl restart containerd",
      "sudo systemctl restart k3s"
    ]
    
    connection {
      type        = "ssh"
      user        = var.ssh_config.user
      private_key = file(var.ssh_config.private_key_path)
      host        = var.server_ip
    }
  }
}