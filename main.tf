module "k3s" {
  source = "./modules/k3s"
  k3s = var.k3s
}

/*
# module "rancher" {
#   source = "./modules/rancher"
#   depends_on = [module.k3s]
#   rancher_config = var.rancher
# }

# module "argocd" {
#   source = "./modules/argocd"
#   depends_on = [module.rancher]
#   argocd_config = var.argocd
#   github_config = var.github
# }
*/