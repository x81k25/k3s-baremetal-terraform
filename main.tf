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
# argocd module
################################################################################

module "argocd" {
  source     = "./modules/argocd"
  depends_on = [module.k3s]

  argocd_config          = local.argocd_config
  argocd_secrets         = local.argocd_secrets
  enable_image_updater   = var.enable_image_updater
  image_updater_log_level = var.image_updater_log_level
  enable_monitoring      = var.enable_monitoring
  reloader_config        = var.reloader_config
}

################################################################################
# pgsql module
################################################################################

module "pgsql" {
  source     = "./modules/pgsql"
  depends_on = [module.k3s]

  # globarl vars
  server_ip       = var.server_ip
  pgsql_secrets   = local.pgsql_secrets
  # pgsql config vars
  pgsql_namespace_config = var.pgsql_namespace_config
  pgsql_config    = var.pgsql_config
  # pgadmin vars
  pgadmin4_config = var.pgadmin4_config
  # flywheel vars 
  flyway_config   = local.flyway_config
  flyway_secrets  = local.flyway_secrets
  # minio vars
  minio_config    = local.minio_config
  minio_secrets   = var.minio_secrets   
}

################################################################################
# media module
################################################################################

module "media" {
  source     = "./modules/media"
  depends_on = [module.argocd, module.pgsql]

  # global vars
  server_ip     = var.server_ip
  environment   = var.environment
  ssh_config    = var.ssh_config
  # namespace vars
  media_config  = var.media_config
  # plex vars
  plex_secrets  = var.plex_secrets
  media_secrets = local.media_secrets
  # atd vars
  vpn_config          = var.vpn_config
  transmission_config = local.transmission_config
  transmission_secrets = var.transmission_secrets
  # read diff vars
  rear_diff_config  = local.rear_diff_config
  rear_diff_secrets = var.rear_diff_secrets
  # center-console vars
  center_console_config = var.center_console_config
  # dagster vars
  dagster_config  = local.dagster_config
  dagster_secrets = var.dagster_secrets
  # at vars
  at_config  = local.at_config
  at_secrets = local.at_secrets
  # wst vars
  wst_config  = local.wst_config
  wst_secrets = var.wst_secrets
  # reel driver vars
  reel_driver_config = local.reel_driver_config
  reel_driver_training_config = local.reel_driver_training_config
  reel_driver_secrets = local.reel_driver_secrets
  reel_driver_training_secrets = local.reel_driver_training_secrets
}

################################################################################
# ai-ml module
################################################################################

module "ai_ml" {
  source     = "./modules/ai-ml"
  depends_on = [module.pgsql]

  # namespace vars
  ai_ml_config = var.ai_ml_config
  ai_ml_secrets = local.ai_ml_secrets
  # mflow vars
  mlflow_config  = local.mlflow_config
  mlflow_secrets = local.mlflow_secrets
  # reel-driver vars
  reel_driver_config = local.reel_driver_config
  reel_driver_api_config = local.reel_driver_api_config
  reel_driver_training_config = local.reel_driver_training_config
  reel_driver_secrets = local.reel_driver_secrets
  reel_driver_training_secrets = local.reel_driver_training_secrets
}

################################################################################
# experiments module
################################################################################

module "experiments" {
  source     = "./modules/experiments"
  depends_on = [module.k3s]

  experiments_config = var.experiments_config
  ng_github_secrets = var.ng_github_secrets
}

################################################################################
# observability module
################################################################################

module "observability" {
  source     = "./modules/observability"
  depends_on = [module.k3s]

  observability_config = var.observability_config
  loki_sensitive    = var.loki_sensitive
  grafana_sensitive = var.grafana_sensitive
}

################################################################################
# end of main.tf
################################################################################