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
    container_defaults = object({
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

variable "gpu_config" {
  description = "GPU device configuration for workload scheduling"
  type = object({
    gtx960 = object({
      uuid   = string
      memory = string
    })
    rtx3060 = object({
      uuid   = string
      memory = string
    })
    quota = number
  })
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

variable "local_llm_config" {
  description = "Local LLM (Ollama) configuration"
  type = any
}

variable "cici_config" {
  description = "Cici voice assistant configuration for all environments"
  type = any
}

################################################################################
# dagster k8s_job_op inherited configs (mirrored from media namespaces)
################################################################################

variable "environment" {
  description = "Environment names (dev, stg, prod)"
  type = any
}

variable "dagster_config" {
  description = "Dagster configuration"
  type = any
}

variable "dagster_secrets" {
  description = "Dagster secrets"
  type = any
  sensitive = true
}

variable "at_config" {
  description = "Automatic Transmission pipeline configuration"
  type = any
}

variable "at_secrets" {
  description = "Automatic Transmission pipeline secrets"
  type = any
  sensitive = true
}

variable "wst_config" {
  description = "Wiring schematics configuration"
  type = any
}

variable "wst_secrets" {
  description = "Wiring schematics secrets"
  type = any
  sensitive = true
}

variable "transmission_config" {
  description = "Transmission daemon configuration"
  type = any
}

variable "transmission_secrets" {
  description = "Transmission daemon secrets"
  type = any
  sensitive = true
}

variable "rear_diff_config" {
  description = "Rear differential API configuration"
  type = any
}

variable "rear_diff_secrets" {
  description = "Rear differential API secrets"
  type = any
  sensitive = true
}

################################################################################
# end of variables.tf
################################################################################