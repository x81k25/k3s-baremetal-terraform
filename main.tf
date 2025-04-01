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
# kuburnetes module
################################################################################

module "kubernetes" {
  source = "./modules/kubernetes"
  
  server_ip =  var.server_ip
  github_config = var.github_config

  providers = {
    kubernetes = kubernetes
  }
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
}

################################################################################
# media module
################################################################################

module "media" {
  source = "./modules/media"
  depends_on = [module.argo_cd]
  
  server_ip =  var.server_ip
  ssh_config = var.ssh_config
  media_sensitive = var.media_sensitive
}

################################################################################
# end of main.tf
################################################################################
