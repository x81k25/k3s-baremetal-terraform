resource "null_resource" "backup_directory" {
  count = var.k3s_config.backup_config.enabled ? 1 : 0

  provisioner "local-exec" {
    command = "mkdir -p ${var.k3s_config.backup_config.backup_location}"
  }
}

resource "local_file" "backup_script" {
  count    = var.k3s_config.backup_config.enabled ? 1 : 0
  filename = "${var.mounts.k3s_root}/backup.sh"
  content  = <<-EOT
    #!/bin/bash
    DATE=$(date +%Y%m%d_%H%M%S)
    k3s etcd-snapshot save --name etcd-snapshot-$DATE
    find ${var.k3s_config.backup_config.backup_location} -name "etcd-snapshot-*" -mtime +${var.k3s_config.backup_config.retention_days} -delete
  EOT

  provisioner "local-exec" {
    command = "chmod +x ${var.mounts.k3s_root}/backup.sh"
  }
}