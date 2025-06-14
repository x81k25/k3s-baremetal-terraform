terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 3.0.0" # Use appropriate version
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1" # Match your root version
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2" # Match your root version
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0" # Use appropriate version
    }
  }
}