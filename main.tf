################################################################################
# k3s module
################################################################################

module "k3s" {
  source = "./modules/k3s"

  server_ip       = var.server_ip
  mounts          = var.mounts
  kubeconfig_path = var.kubeconfig_path
  k3s_config      = var.k3s_config
}

################################################################################
# rancher module
################################################################################

module "rancher" {
  source     = "./modules/rancher"
  depends_on = [module.k3s]

  server_ip           = var.server_ip
  kubeconfig_path     = var.kubeconfig_path
  rancher_config      = var.rancher_config
  rancher_sensitive   = var.rancher_sensitive
  cert_manager_config = var.cert_manager_config

  providers = {
    rancher2 = rancher2
    helm     = helm
    null     = null
    time     = time
  }
}

################################################################################
# argocd module
################################################################################

module "argo_cd" {
  source     = "./modules/argo_cd"
  depends_on = [module.rancher]

  github_config     = var.github_config
  argo_cd_config    = var.argo_cd_config
  argo_cd_sensitive = var.argo_cd_sensitive
  kubeconfig_path   = var.kubeconfig_path
}

################################################################################
# pgsql module
################################################################################

module "pgsql" {
  source     = "./modules/pgsql"
  depends_on = [module.k3s]

  server_ip       = var.server_ip
  pgsql_config    = var.pgsql_config
  github_config   = var.github_config
  flyway_config   = local.flyway_config
  flyway_secrets  = local.flyway_secrets
  pgadmin4_config = var.pgadmin4_config
}

################################################################################
# media module
################################################################################

module "media" {
  source     = "./modules/media"
  depends_on = [module.argo_cd, module.pgsql]

  # global vars
  server_ip     = var.server_ip
  environment   = var.environment
  github_config = var.github_config
  ssh_config    = var.ssh_config
  # plex vars
  media_sensitive = var.media_sensitive
  # atd vars
  vpn_config          = var.vpn_config
  transmission_config = local.transmission_config
  transmission_secrets = var.transmission_secrets
  # read diff vars
  rear_diff_config  = local.rear_diff_config
  rear_diff_secrets = var.rear_diff_secrets
  # reel-driver vars
  reel_driver_config = local.reel_driver_config
  # dagster vars
  dagster_config  = local.dagster_config
  dagster_secrets = var.dagster_secrets
  # at vars
  at_config  = local.at_config
  at_secrets = local.at_secrets
  # wst vars
  wst_config  = local.wst_config
  wst_secrets = var.wst_secrets
}

################################################################################
# ai-ml module
################################################################################

module "ai_ml" {
  source     = "./modules/ai-ml"
  depends_on = [module.pgsql]

  ai_ml_sensitive = var.ai_ml_sensitive
  github_config   = var.github_config
}

################################################################################
# observability module
################################################################################

module "observability" {
  source     = "./modules/observability"
  depends_on = [module.k3s]

  loki_sensitive    = var.loki_sensitive
  grafana_sensitive = var.grafana_sensitive
}

################################################################################
# end of main.tf
################################################################################