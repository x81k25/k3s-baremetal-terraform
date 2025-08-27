variable "experiments_config" {
  description = "Resource configuration for experiments namespace"
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

variable "ng_github_secrets" {
  description = "ng github credentials"
  type = object({
    username = string
    token_packages_read = string
  })
  sensitive = true
}

variable "osrm_config" {
  description = "OSRM service configuration"
  type = object({
    osm_download_url = string
    osm_filename     = string
    osrm_profile     = string
    osrm_region      = string
    s3_region        = string
    s3_bucket        = string
  })
}

variable "osrm_secrets" {
  description = "OSRM service secrets for S3 storage"
  type = object({
    s3_endpoint   = string
    s3_access_key = string
    s3_secret_key = string
  })
  sensitive = true
}