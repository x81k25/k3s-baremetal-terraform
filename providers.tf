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
  config_path    = var.kubeconfig_path
  config_context = "default"
}

################################################################################
# end of providers.tf
################################################################################