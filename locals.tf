################################################################################
# media module
################################################################################

# create locals that will be passed to media as vars
locals {
  dagster_config = {
    path = {
      prod = {
        home      = var.dagster_path_config.prod.home
        workspace = var.dagster_path_config.prod.workspace
      }
      stg = {
        home      = var.dagster_path_config.stg.home
        workspace = var.dagster_path_config.stg.workspace
      }
      dev = {
        home      = var.dagster_path_config.dev.home
        workspace = var.dagster_path_config.dev.workspace
      }
    }
    pgsql = {
      for env in ["prod", "stg", "dev"] : env => {
        host     = var.pgsql_default_config[env].host
        port     = var.pgsql_default_config[env].port
        database = "dagster"
      }
    }
  }

  transmission_config = {
    prod = {
      host = var.server_ip
      port = var.transmission_vars.prod.port
    }
    stg = {
      host = var.server_ip
      port = var.transmission_vars.stg.port
    }
    dev = {
      host = var.server_ip
      port = var.transmission_vars.dev.port
    }
  }

  reel_driver_config = {
    prod = {
      host   = var.server_ip
      port   = var.reel_driver_vars.prod.port
      prefix = var.reel_driver_vars.prefix
    }
    stg = {
      host   = var.server_ip
      port   = var.reel_driver_vars.stg.port
      prefix = var.reel_driver_vars.prefix
    }
    dev = {
      host   = var.server_ip
      port   = var.reel_driver_vars.dev.port
      prefix = var.reel_driver_vars.prefix
    }
  }

  at_config = {
    prod = {
      movie_search_api_base_url      = var.at_vars.movie_search_api_base_url
      movie_details_api_base_url     = var.at_vars.movie_details_api_base_url
      movie_ratings_api_base_url     = var.at_vars.movie_ratings_api_base_url
      tv_search_api_base_utl         = var.at_vars.tv_search_api_base_utl
      tv_details_api_base_url        = var.at_vars.tv_details_api_base_url
      tv_ratings_api_base_url        = var.at_vars.tv_ratings_api_base_url
      rss_sources                    = var.at_vars.rss_sources
      rss_urls                       = var.at_vars.rss_urls
      uid                            = var.at_vars.uid
      gid                            = var.at_vars.gid
      batch_size                     = var.at_vars.prod.batch_size
      log_level                      = var.at_vars.prod.log_level
      stale_metadata_threshold       = var.at_vars.prod.stale_metadata_threshold
      reel_driver_threshold          = var.at_vars.prod.reel_driver_threshold
      target_active_items            = var.at_vars.prod.target_active_items
      transferred_item_cleanup_delay = var.at_vars.prod.transferred_item_cleanup_delay
      hung_item_cleanup_delay        = var.at_vars.prod.hung_item_cleanup_delay
      download_dir                   = var.at_vars.prod.download_dir
      movie_dir                      = var.at_vars.prod.movie_dir
      tv_show_dir                    = var.at_vars.prod.tv_show_dir
      pgsql = {
        host     = var.pgsql_default_config.prod.host
        port     = var.pgsql_default_config.prod.port
        database = var.pgsql_default_config.database
        schema   = var.pgsql_default_config.schema
      }
    }
    stg = {
      movie_search_api_base_url      = var.at_vars.movie_search_api_base_url
      movie_details_api_base_url     = var.at_vars.movie_details_api_base_url
      movie_ratings_api_base_url     = var.at_vars.movie_ratings_api_base_url
      tv_search_api_base_utl         = var.at_vars.tv_search_api_base_utl
      tv_details_api_base_url        = var.at_vars.tv_details_api_base_url
      tv_ratings_api_base_url        = var.at_vars.tv_ratings_api_base_url
      rss_sources                    = var.at_vars.rss_sources
      rss_urls                       = var.at_vars.rss_urls
      uid                            = var.at_vars.stg.uid
      gid                            = var.at_vars.stg.gid
      batch_size                     = var.at_vars.stg.batch_size
      log_level                      = var.at_vars.stg.log_level
      stale_metadata_threshold       = var.at_vars.stg.stale_metadata_threshold
      reel_driver_threshold          = var.at_vars.stg.reel_driver_threshold
      target_active_items            = var.at_vars.stg.target_active_items
      transferred_item_cleanup_delay = var.at_vars.stg.transferred_item_cleanup_delay
      hung_item_cleanup_delay        = var.at_vars.stg.hung_item_cleanup_delay
      download_dir                   = var.at_vars.stg.download_dir
      movie_dir                      = var.at_vars.stg.movie_dir
      tv_show_dir                    = var.at_vars.stg.tv_show_dir
      pgsql = {
        host     = var.pgsql_default_config.stg.host
        port     = var.pgsql_default_config.stg.port
        database = var.pgsql_default_config.database
        schema   = var.pgsql_default_config.schema
      }
    }
    dev = {
      movie_search_api_base_url      = var.at_vars.movie_search_api_base_url
      movie_details_api_base_url     = var.at_vars.movie_details_api_base_url
      movie_ratings_api_base_url     = var.at_vars.movie_ratings_api_base_url
      tv_search_api_base_utl         = var.at_vars.tv_search_api_base_utl
      tv_details_api_base_url        = var.at_vars.tv_details_api_base_url
      tv_ratings_api_base_url        = var.at_vars.tv_ratings_api_base_url
      rss_sources                    = var.at_vars.rss_sources
      rss_urls                       = var.at_vars.rss_urls
      uid                            = var.at_vars.dev.uid
      gid                            = var.at_vars.dev.gid
      batch_size                     = var.at_vars.dev.batch_size
      log_level                      = var.at_vars.dev.log_level
      stale_metadata_threshold       = var.at_vars.dev.stale_metadata_threshold
      reel_driver_threshold          = var.at_vars.dev.reel_driver_threshold
      target_active_items            = var.at_vars.dev.target_active_items
      transferred_item_cleanup_delay = var.at_vars.dev.transferred_item_cleanup_delay
      hung_item_cleanup_delay        = var.at_vars.dev.hung_item_cleanup_delay
      download_dir                   = var.at_vars.dev.download_dir
      movie_dir                      = var.at_vars.dev.movie_dir
      tv_show_dir                    = var.at_vars.dev.tv_show_dir
      pgsql = {
        host     = var.pgsql_default_config.dev.host
        port     = var.pgsql_default_config.dev.port
        database = var.pgsql_default_config.database
        schema   = var.pgsql_default_config.schema
      }
    }
  }

  at_secrets = {
    prod = {
      movie_search_api_key  = var.at_secret_vars.movie_search_api_key
      movie_details_api_key = var.at_secret_vars.movie_details_api_key
      movie_ratings_api_key = var.at_secret_vars.movie_ratings_api_key
      tv_search_api_key     = var.at_secret_vars.tv_search_api_key
      tv_details_api_key    = var.at_secret_vars.tv_details_api_key
      tv_ratings_api_key    = var.at_secret_vars.tv_ratings_api_key
      pgsql = {
        username = var.pgsql_config.prod.user
        password = var.pgsql_config.prod.password
      }
    }
    stg = {
      movie_search_api_key  = var.at_secret_vars.movie_search_api_key
      movie_details_api_key = var.at_secret_vars.movie_details_api_key
      movie_ratings_api_key = var.at_secret_vars.movie_ratings_api_key
      tv_search_api_key     = var.at_secret_vars.tv_search_api_key
      tv_details_api_key    = var.at_secret_vars.tv_details_api_key
      tv_ratings_api_key    = var.at_secret_vars.tv_ratings_api_key
      pgsql = {
        username = var.pgsql_config.stg.user
        password = var.pgsql_config.stg.password
      }
    }
    dev = {
      movie_search_api_key  = var.at_secret_vars.movie_search_api_key
      movie_details_api_key = var.at_secret_vars.movie_details_api_key
      movie_ratings_api_key = var.at_secret_vars.movie_ratings_api_key
      tv_search_api_key     = var.at_secret_vars.tv_search_api_key
      tv_details_api_key    = var.at_secret_vars.tv_details_api_key
      tv_ratings_api_key    = var.at_secret_vars.tv_ratings_api_key
      pgsql = {
        username = var.pgsql_config.dev.user
        password = var.pgsql_config.dev.password
      }
    }
  }

  rear_diff_config = {
    pgsql = {
      for env in ["prod", "stg", "dev"] : env => {
        host     = var.pgsql_default_config[env].host
        port     = var.pgsql_default_config[env].port
        database = var.pgsql_default_config.database
      }
    }
  }

  wst_config = {
    pgsql = {
      for env in ["prod", "stg", "dev"] : env => {
        host     = var.pgsql_default_config[env].host
        port     = var.pgsql_default_config[env].port
        database = var.pgsql_default_config.database
      }
    }
  }
}



################################################################################
# end of locals.tf
################################################################################