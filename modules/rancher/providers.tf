provider "rancher2" {
  api_url   = "https://${var.server_ip}"
  bootstrap = true
  insecure  = true  # For initial setup only
}