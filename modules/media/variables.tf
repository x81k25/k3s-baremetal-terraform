################################################################################
# global vars
################################################################################

variable "server_ip" {
  type = string
}

variable "media_config" {
  description = "Resource configuration for media namespaces"
  type = object({
    prod = object({
      resource_quota = object({
        cpu_request    = string
        cpu_limit      = string
        memory_request = string
        memory_limit   = string
      })
    })
    stg = object({
      resource_quota = object({
        cpu_request    = string
        cpu_limit      = string
        memory_request = string
        memory_limit   = string
      })
    })
    dev = object({
      resource_quota = object({
        cpu_request    = string
        cpu_limit      = string
        memory_request = string
        memory_limit   = string
      })
    })
  })
}

variable "environment" {
  description = "Map of environment names"
  type = object({
    dev  = string
    stg  = string
    prod = string
  })
}


variable "ssh_config" {
  type = object({
    user             = string
    private_key_path = string
  })
  sensitive = true
}

################################################################################
# plex vars
################################################################################

variable "media_secrets" {
  type = object({
    plex_claim = string
    github = object({
      username = string
      token_packages_read = string
    })
  })
  sensitive = true
}

################################################################################
# atd vars
################################################################################

variable "vpn_config" {
  description = "vpn credendtials"
  type = object({
    username = string
    password = string
    config   = string
  })
}

variable "transmission_config" {
  description = "Transmission configuration per environment"
  type = object({
    prod = object({
      host = string
      port = string
    })
    stg = object({
      host = string
      port = string
    })
    dev = object({
      host = string
      port = string
    })
  })
}

variable "transmission_secrets" {
  description = "Transmission authentication credentials per environment"
  type = object({
    prod = object({
      username = string
      password = string
    })
    stg = object({
      username = string
      password = string
    })
    dev = object({
      username = string
      password = string
    })
  })
  sensitive = true
}

################################################################################
# rear diff vars
################################################################################

variable "rear_diff_config" {
  description = "parameters to connect rear differential API to DB"
  type = object({
    prod = object({
      host = string
      port_external = string
      prefix = string
      pgsql = object({
        host     = string
        port     = string
        database = string
      })
    })
    stg = object({
      host = string
      port_external = string
      prefix = string
      pgsql = object({
        host     = string
        port     = string
        database = string
      })
    })
    dev = object({
      host = string
      port_external = string
      prefix = string
      pgsql = object({
        host     = string
        port     = string
        database = string
      })
    })
  })
}

variable "rear_diff_secrets" {
  description = "parameters to connect rear differential API to DB"
  type = object({
    prod = object({
      pgsql = object({
          username = string
          password = string
      })
    })
    stg = object({
      pgsql = object({
        username = string
        password = string
      })
    })
    dev = object({
      pgsql = object({
        username = string
        password = string
      })
    })
  })
  sensitive = true
}

################################################################################
# center console vars
################################################################################

variable "center_console_config" {
  description = "env var for center-console UI tool"
  type = object({
    prod = object({
      port_external = string
      api_timeout = string
    })
    stg = object({
      port_external = string
      api_timeout = string
    })
    dev = object({
      port_external = string
      api_timeout = string
    })
  })
}


################################################################################
# dagster vars
################################################################################

variable "dagster_config" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    path = object({
      prod = object({
        home      = string
        workspace = string
        timezone  = string
      })
      stg = object({
        home      = string
        workspace = string
        timezone  = string
      })
      dev = object({
        home      = string
        workspace = string
        timezone  = string
      })
    })
    pgsql = object({
      prod = object({
        host     = string
        port     = string
        database = string
      })
      stg = object({
        host     = string
        port     = string
        database = string
      })
      dev = object({
        host     = string
        port     = string
        database = string
      })
    })
  })
}

variable "dagster_secrets" {
  description = "parameters to insantiate and connect the pgsql databases within the cluster"
  type = object({
    prod = object({
      username = string
      password = string
    })
    stg = object({
      username = string
      password = string
    })
    dev = object({
      username = string
      password = string
    })
  })
  sensitive = true
}

################################################################################
# automatic-transmission vars
################################################################################

variable "at_config" {
  description = "Automatic transmission configuration per environment"
  type = object({
    prod = object({
      movie_search_api_base_url      = string
      movie_details_api_base_url     = string
      movie_ratings_api_base_url     = string
      tv_search_api_base_utl         = string
      tv_details_api_base_url        = string
      tv_ratings_api_base_url        = string
      rss_sources                    = string
      rss_urls                       = string
      uid                            = string
      gid                            = string
      batch_size                     = string
      log_level                      = string
      stale_metadata_threshold       = string
      reel_driver_threshold          = string
      target_active_items            = string
      transferred_item_cleanup_delay = string
      hung_item_cleanup_delay        = string
      download_dir                   = string
      movie_dir                      = string
      tv_show_dir                    = string
      pgsql = object({
        host     = string
        port     = string
        database = string
        schema   = string
      })
      reel_driver = object({
        host   = string
        port   = string
        prefix = string
      })
    })
    stg = object({
      movie_search_api_base_url      = string
      movie_details_api_base_url     = string
      movie_ratings_api_base_url     = string
      tv_search_api_base_utl         = string
      tv_details_api_base_url        = string
      tv_ratings_api_base_url        = string
      rss_sources                    = string
      rss_urls                       = string
      uid                            = string
      gid                            = string
      batch_size                     = string
      log_level                      = string
      stale_metadata_threshold       = string
      reel_driver_threshold          = string
      target_active_items            = string
      transferred_item_cleanup_delay = string
      hung_item_cleanup_delay        = string
      download_dir                   = string
      movie_dir                      = string
      tv_show_dir                    = string
      pgsql = object({
        host     = string
        port     = string
        database = string
        schema   = string
      })
      reel_driver = object({
        host   = string
        port   = string
        prefix = string
      })
    })
    dev = object({
      movie_search_api_base_url      = string
      movie_details_api_base_url     = string
      movie_ratings_api_base_url     = string
      tv_search_api_base_utl         = string
      tv_details_api_base_url        = string
      tv_ratings_api_base_url        = string
      rss_sources                    = string
      rss_urls                       = string
      uid                            = string
      gid                            = string
      batch_size                     = string
      log_level                      = string
      stale_metadata_threshold       = string
      reel_driver_threshold          = string
      target_active_items            = string
      transferred_item_cleanup_delay = string
      hung_item_cleanup_delay        = string
      download_dir                   = string
      movie_dir                      = string
      tv_show_dir                    = string
      pgsql = object({
        host     = string
        port     = string
        database = string
        schema   = string
      })
      reel_driver = object({
        host   = string
        port   = string
        prefix = string
      })
    })
  })
}

variable "at_secrets" {
  description = "Automatic transmission secrets per environment"
  type = object({
    prod = object({
      movie_search_api_key  = string
      movie_details_api_key = string
      movie_ratings_api_key = string
      tv_search_api_key     = string
      tv_details_api_key    = string
      tv_ratings_api_key    = string
      pgsql = object({
        username = string
        password = string
      })
    })
    stg = object({
      movie_search_api_key  = string
      movie_details_api_key = string
      movie_ratings_api_key = string
      tv_search_api_key     = string
      tv_details_api_key    = string
      tv_ratings_api_key    = string
      pgsql = object({
        username = string
        password = string
      })
    })
    dev = object({
      movie_search_api_key  = string
      movie_details_api_key = string
      movie_ratings_api_key = string
      tv_search_api_key     = string
      tv_details_api_key    = string
      tv_ratings_api_key    = string
      pgsql = object({
        username = string
        password = string
      })
    })
  })
  sensitive = true
}

################################################################################
# wiring-schema-tics vars
################################################################################

variable "wst_config" {
  description = "env vars for wst services running in dagster"
  type = object({
    pgsql = object({
      prod = object({
        host     = string
        port     = string
        database = string
      })
      stg = object({
        host     = string
        port     = string
        database = string
      })
      dev = object({
        host     = string
        port     = string
        database = string
      })
    })
  })
}

variable "wst_secrets" {
  description = "contains secrest for wst services running in dagster"
  type = object({
    pgsql = object({
      prod = object({
        username = string
        password = string
      })
      stg = object({
        username = string
        password = string
      })
      dev = object({
        username = string
        password = string
      })
    })
  })
  sensitive = true
}

################################################################################
# reel driver vars
################################################################################

variable "reel_driver_config" {
  description = "Reel driver configuration per environment"
  type = any
}

variable "reel_driver_training_config" {
  description = "Reel driver training configuration per environment"
  type = any
}

variable "reel_driver_secrets" {
  description = "Reel driver secrets per environment"
  type = any
  sensitive = true
}

variable "reel_driver_training_secrets" {
  description = "Reel driver training secrets per environment"
  type = any
  sensitive = true
}

################################################################################
# end of variables.tf
################################################################################