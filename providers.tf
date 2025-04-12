################################################################################
# terraform providers
################################################################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    # root providers
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
    # rancher provider    
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 3.0.0"  
    }
  }
}

################################################################################
# providers use by multiple modules
################################################################################

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

################################################################################
# kubernetes provider
################################################################################

provider "kubernetes" {
  config_path = var.kubeconfig_path
  config_context = "default"
}

################################################################################
# rancher providers
################################################################################

provider "rancher2" {
  api_url   = "https://${var.server_ip}"
  bootstrap = true
  insecure  = true  # For initial setup only
}

################################################################################
# end of providers.tf
################################################################################