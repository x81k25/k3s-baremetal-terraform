################################################################################
# ai-ml vars
################################################################################

variable "ai_ml_config" {
  description = "Resource configuration for ai-ml namespace"
  type = object({
    resource_quota = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
  })
}

variable "ai_ml_secrets" {
  description = "namespace-level secrets for ai-ml services"
  type = object({
    github = object({
      username = string
      token_packages_read = string
    })
  })
  sensitive = true
}

variable "mlflow_config" {
  description = "holds all env vars for mlflow"
  type = any
}

variable "mlflow_secrets" {
  description = "credentials for mlflow instances"
  type = any
  sensitive = true
}

variable "reel_driver_config" {
  description = "reel-driver configuration for all environments"
  type = any
}

variable "reel_driver_api_config" {
  description = "reel-driver API configuration"
  type = any
}

variable "reel_driver_training_config" {
  description = "reel-driver training configuration"
  type = any
}

variable "reel_driver_secrets" {
  description = "reel-driver secrets"
  type = any
  sensitive = true
}

variable "reel_driver_training_secrets" {
  description = "reel-driver training secrets"
  type = any
  sensitive = true
}

################################################################################
# end of variables.tf
################################################################################