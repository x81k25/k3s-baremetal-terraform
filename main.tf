module "k3s" {
  source = "./modules/k3s"
  
  server_ip = var.server_ip
  mounts = var.mounts
  k3s_config = var.k3s_config
}

module "kubernetes" {
  source = "./modules/kubernetes"
  
  providers = {
    kubernetes = kubernetes
  }
}


module "rancher" {
  source = "./modules/rancher"
  depends_on = [module.k3s]
  
  server_ip = var.server_ip
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

/*
# module "argocd" {
#   source = "./modules/argocd"
#   depends_on = [module.rancher]
#   argocd_config = var.argocd
#   github_config = var.github
# }
*/