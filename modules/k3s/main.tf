resource "null_resource" "k3s_install_dir" {
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ${var.mounts.k3s_root}
      chmod 755 ${var.mounts.k3s_root}
      if command -v systemd-detect-virt >/dev/null 2>&1; then
        chown -R root:root ${var.mounts.k3s_root}
      fi
    EOT
  }
}

resource "local_file" "k3s_config" {
  depends_on = [null_resource.k3s_install_dir]
  filename   = "${var.mounts.k3s_root}/config.yaml"
  content    = yamlencode({
    data-dir  = var.mounts.k3s_root
    node-label      = []
    node-taint     = []
    write-kubeconfig = "${var.kubeconfig_path}"
    write-kubeconfig-mode = "644"
    kube-apiserver-arg  = []
    kubelet-arg = [
      "max-pods=150",
      "cpu-manager-policy=static",
      "kube-reserved=cpu=500m,memory=500Mi,ephemeral-storage=1Gi",
      "system-reserved=cpu=500m,memory=500Mi,ephemeral-storage=1Gi",
      "cpu-cfs-quota=true",
      "cpu-cfs-quota-period=100ms",
      "kube-api-qps=50",
      "kube-api-burst=100",
      "cpu-manager-policy=static",
      "system-reserved=cpu=2,memory=2Gi",
      "kube-reserved=cpu=2,memory=2Gi"
    ]
  })
}

resource "null_resource" "k3s_install" {
  depends_on = [local_file.k3s_config]

  provisioner "local-exec" {
    command = <<-EOT
      if systemctl is-active --quiet k3s; then
        echo "K3s is already running, stopping service..."
        systemctl stop k3s
      fi

      mkdir -p $(dirname ${var.mounts.k3s_root}/config.yaml)
      chmod 755 $(dirname ${var.mounts.k3s_root}/config.yaml)

      curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${var.k3s_config.version} \
        INSTALL_K3S_EXEC="server \
        --config ${var.mounts.k3s_root}/config.yaml \
        --config ${var.mounts.k3s_root}/network.yaml" \
        sh -

      if ! systemctl is-active --quiet k3s; then
        echo "K3s installation failed. Checking logs..."
        journalctl -xeu k3s.service
        exit 1
      fi
    EOT
  }
}