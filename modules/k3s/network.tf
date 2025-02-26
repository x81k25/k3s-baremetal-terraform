# File location: /d/k8s/terraform/network.tf

# Network configuration for K3s cluster
resource "local_file" "k3s_network_config" {
  depends_on = [null_resource.k3s_install_dir]
  filename   = "${var.k3s.mount_points.k3s_root}/network.yaml"
  content    = yamlencode({
    flannel-backend = "vxlan"  # Default networking mode
    flannel-iface   = var.k3s.network_config.interface_name # Network interface for Flannel
    node-ip         = var.k3s.network_config.host_ip
    cluster-cidr    = var.k3s.network_config.network_subnet
    service-cidr    = var.k3s.network_config.service_subnet
    cluster-dns     = var.k3s.network_config.cluster_dns
    # Additional network security policies
    flannel-ipv6-masq = true  # Enable IPv6 masquerading if needed
    disable-network-policy = false  # Enable network policies by default
  })
}

# Network validation
resource "null_resource" "network_validation" {
  depends_on = [local_file.k3s_network_config]

  provisioner "local-exec" {
    command = <<-EOT
      # Validate network interface exists
      if ! ip link show ${var.k3s.network_config.interface_name} >/dev/null 2>&1; then
        echo "Error: Network interface ${var.k3s.network_config.interface_name} does not exist"
        exit 1
      fi

      # Validate IP address format
      if ! echo ${var.k3s.network_config.host_ip} | grep -P '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$' >/dev/null; then
        echo "Error: Invalid IP address format: ${var.k3s.network_config.host_ip}"
        exit 1
      fi

      # Check if IP is already in use (if not the current machine's IP)
      if ! ip addr | grep ${var.k3s.network_config.host_ip} >/dev/null; then
        if ping -c 1 -W 1 ${var.k3s.network_config.host_ip} >/dev/null 2>&1; then
          echo "Warning: IP address ${var.k3s.network_config.host_ip} might be in use"
        fi
      fi
    EOT
  }
}