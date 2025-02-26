terraform {
  required_version = ">= 1.5.0"
  required_providers {
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
  }
}

# helm called by multiple modules
variable "k3s_configured" {
  description = "Whether k3s is configured and kubeconfig exists"
  type        = bool
  default     = false
}

provider "helm" {
  kubernetes {
    config_path = var.k3s_configured ? "/d/k8s/k3s.yaml" : null
  }
}

