################################################################################
# global vars
################################################################################

variable "server_ip" {
  type = string
}

variable "environment" {
  description = "Map of environment names"
  type = object({
    dev  = string
    stg  = string
    prod = string
  })
}

variable "github_config" {
  description = "GitHub and GitHub Container Registry configuration"
  type = object({
    username                         = string
    email                            = string
    k8s_manifests_repo               = string
    argo_cd_pull_k8s_manifests_token = string
    argo_cd_pull_image_token         = string
  })
  sensitive = true
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

variable "media_sensitive" {
  type = object({
    plex_claim = string
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

variable "rear_diff_secrets" {
  description = "parameters to connect rear differential API to DB"
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

variable "reel_driver_config" {
  description = "Reel driver configuration per environment"
  type = object({
    prod = object({
      host   = string
      port   = string
      prefix = string
    })
    stg = object({
      host   = string
      port   = string
      prefix = string
    })
    dev = object({
      host   = string
      port   = string
      prefix = string
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
# end of variables.tf
################################################################################