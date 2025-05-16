################################################################################
# k3s module
################################################################################

module "k3s" {
  source = "./modules/k3s"
  
  server_ip = var.server_ip
  mounts = var.mounts
  kubeconfig_path = var.kubeconfig_path
  k3s_config = var.k3s_config
}

################################################################################
# rancher module
################################################################################

module "rancher" {
  source = "./modules/rancher"
  depends_on = [module.k3s]
  
  server_ip = var.server_ip
  kubeconfig_path = var.kubeconfig_path
  rancher_config = var.rancher_config
  rancher_sensitive = var.rancher_sensitive
  cert_manager_config = var.cert_manager_config

  providers = {
    rancher2 = rancher2
    helm = helm
    null = null
    time = time
  }
}

################################################################################
# argocd module
################################################################################

module "argo_cd" {
  source = "./modules/argo_cd"
  depends_on = [module.rancher]
  
  github_config = var.github_config
  argo_cd_config = var.argo_cd_config
  argo_cd_sensitive = var.argo_cd_sensitive
  kubeconfig_path = var.kubeconfig_path
}

################################################################################
# pgsql module
################################################################################

module "pgsql" {
  source = "./modules/pgsql"
  depends_on = [module.k3s]

  server_ip = var.server_ip
  pgsql_config = var.pgsql_config
  pgadmin4_config = var.pgadmin4_config
}

################################################################################
# orchestration module
################################################################################

module "orchestration" {
  source = "./modules/orchestration"
  depends_on = [module.pgsql]

  dagster_config = var.dagster_config
  dagster_pgsql_config = var.dagster_pgsql_config
}

################################################################################
# media module
################################################################################

module "media" {
  source = "./modules/media"
  depends_on = [module.argo_cd]
  
  server_ip =  var.server_ip
  github_config = var.github_config
  ssh_config = var.ssh_config
  media_sensitive = var.media_sensitive
  vpn_config = var.vpn_config
  pgsql_config = var.pgsql_config
}

################################################################################
# ai-ml module
################################################################################

module "ai_ml" {
  source = "./modules/ai-ml"
  depends_on = [module.pgsql]

  ai_ml_sensitive = var.ai_ml_sensitive
  github_config = var.github_config
}

################################################################################
# end of main.tf
################################################################################