################################################################################
# argocd module
################################################################################

locals {
  argocd_config = merge(var.argocd_config, {
    kubeconfig_path = var.kubeconfig_path
  })

  argocd_secrets = {
    admin_pw = var.argocd_secrets.admin_pw
    ssh_private_key_path = var.argocd_secrets.ssh_private_key_path
    github = {
      username = var.github_secrets.username
      token_packages_read = var.github_secrets.token_packages_read
    }
  }
}

################################################################################
# pgsql module
################################################################################

locals {
  pgsql_secrets = {
    github = {
      username            = var.github_secrets.username
      token_packages_read = var.github_secrets.token_packages_read
    }
    gitlab = {
      username = var.gitlab_secrets.username
      token    = var.gitlab_secrets.token
    }
  }

  flyway_config = {
    prod = {
      pgsql = {
        host     = var.pgsql_default_config.prod.host
        port     = var.pgsql_default_config.prod.port
        database = var.pgsql_default_config.database
      }
    }
    stg = {
      pgsql = {
        host     = var.pgsql_default_config.stg.host
        port     = var.pgsql_default_config.stg.port
        database = var.pgsql_default_config.database
      }
    }
    dev = {
      pgsql = {
        host     = var.pgsql_default_config.dev.host
        port     = var.pgsql_default_config.dev.port
        database = var.pgsql_default_config.database
      }
    }
  }

  flyway_secrets = {
    prod = {
      pgsql = {
        username = var.pgsql_config.prod.user
        password = var.pgsql_config.prod.password
      }
    }
    stg = {
      pgsql = {
        username = var.pgsql_config.stg.user
        password = var.pgsql_config.stg.password
      }
    }
    dev = {
      pgsql = {
        username = var.pgsql_config.dev.user
        password = var.pgsql_config.dev.password
      }
    }
  }

  minio_config = {
    prod = {
      uid = var.minio_config.uid
      gid = var.minio_config.gid
      region = var.minio_config.region
      port = {
        external = {
          console = var.minio_config.prod.port.external.console
          api     = var.minio_config.prod.port.external.api
        }
        internal = {
          api = var.minio_config.prod.port.internal.api
        }
      }
      endpoint = {
        internal = var.minio_config.prod.endpoint.internal
      }
      path = {
        data = "${var.minio_config.path.root}prod/${var.minio_config.path.directories.data}"
      }
    }
    stg = {
      uid = var.minio_config.uid
      gid = var.minio_config.gid
      region = var.minio_config.region
      port = {
        external = {
          console = var.minio_config.stg.port.external.console
          api     = var.minio_config.stg.port.external.api
        }
        internal = {
          api = var.minio_config.stg.port.internal.api
        }
      }
      endpoint = {
        internal = var.minio_config.stg.endpoint.internal
      }
      path = {
        data = "${var.minio_config.path.root}stg/${var.minio_config.path.directories.data}"
      }
    }
    dev = {
      uid = var.minio_config.uid
      gid = var.minio_config.gid
      region = var.minio_config.region
      port = {
        external = {
          console = var.minio_config.dev.port.external.console
          api     = var.minio_config.dev.port.external.api
        }
        internal = {
          api = var.minio_config.dev.port.internal.api
        }
      }
      endpoint = {
        internal = var.minio_config.dev.endpoint.internal
      }
      path = {
        data = "${var.minio_config.path.root}dev/${var.minio_config.path.directories.data}"
      }
    }
  }
}

################################################################################
# media module
################################################################################

locals {
  media_secrets = {
    github = {
      username            = var.github_secrets.username
      token_packages_read = var.github_secrets.token_packages_read
    }
    gitlab = {
      username = var.gitlab_secrets.username
      token    = var.gitlab_secrets.token
    }
  }

  dagster_config = {
    path = {
      prod = {
        home      = var.dagster_vars.path.prod.home
        workspace = var.dagster_vars.path.prod.workspace
        timezone  = var.dagster_vars.timezone
      }
      stg = {
        home      = var.dagster_vars.path.stg.home
        workspace = var.dagster_vars.path.stg.workspace
        timezone  = var.dagster_vars.timezone
      }
      dev = {
        home      = var.dagster_vars.path.dev.home
        workspace = var.dagster_vars.path.dev.workspace
        timezone  = var.dagster_vars.timezone
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
      env_vars = {
        speed_limit_down         = var.transmission_env_config.prod.speed_limit_down
        speed_limit_down_enabled = var.transmission_env_config.prod.speed_limit_down_enabled
        speed_limit_up           = var.transmission_env_config.prod.speed_limit_up
        speed_limit_up_enabled   = var.transmission_env_config.prod.speed_limit_up_enabled
        download_queue_enabled   = var.transmission_env_config.prod.download_queue_enabled
        download_queue_size      = var.transmission_env_config.prod.download_queue_size
        seed_queue_enabled       = var.transmission_env_config.prod.seed_queue_enabled
        seed_queue_size          = var.transmission_env_config.prod.seed_queue_size
        queue_stalled_enabled    = var.transmission_env_config.prod.queue_stalled_enabled
        queue_stalled_minutes    = var.transmission_env_config.prod.queue_stalled_minutes
        peer_limit_global        = var.transmission_env_config.prod.peer_limit_global
        peer_limit_per_torrent   = var.transmission_env_config.prod.peer_limit_per_torrent
        cache_size_mb            = var.transmission_env_config.prod.cache_size_mb
        preallocation            = var.transmission_env_config.prod.preallocation
      }
    }
    stg = {
      host = var.server_ip
      port = var.transmission_vars.stg.port
      env_vars = {
        speed_limit_down         = var.transmission_env_config.stg.speed_limit_down
        speed_limit_down_enabled = var.transmission_env_config.stg.speed_limit_down_enabled
        speed_limit_up           = var.transmission_env_config.stg.speed_limit_up
        speed_limit_up_enabled   = var.transmission_env_config.stg.speed_limit_up_enabled
        download_queue_enabled   = var.transmission_env_config.stg.download_queue_enabled
        download_queue_size      = var.transmission_env_config.stg.download_queue_size
        seed_queue_enabled       = var.transmission_env_config.stg.seed_queue_enabled
        seed_queue_size          = var.transmission_env_config.stg.seed_queue_size
        queue_stalled_enabled    = var.transmission_env_config.stg.queue_stalled_enabled
        queue_stalled_minutes    = var.transmission_env_config.stg.queue_stalled_minutes
        peer_limit_global        = var.transmission_env_config.stg.peer_limit_global
        peer_limit_per_torrent   = var.transmission_env_config.stg.peer_limit_per_torrent
        cache_size_mb            = var.transmission_env_config.stg.cache_size_mb
        preallocation            = var.transmission_env_config.stg.preallocation
      }
    }
    dev = {
      host = var.server_ip
      port = var.transmission_vars.dev.port
      env_vars = {
        speed_limit_down         = var.transmission_env_config.dev.speed_limit_down
        speed_limit_down_enabled = var.transmission_env_config.dev.speed_limit_down_enabled
        speed_limit_up           = var.transmission_env_config.dev.speed_limit_up
        speed_limit_up_enabled   = var.transmission_env_config.dev.speed_limit_up_enabled
        download_queue_enabled   = var.transmission_env_config.dev.download_queue_enabled
        download_queue_size      = var.transmission_env_config.dev.download_queue_size
        seed_queue_enabled       = var.transmission_env_config.dev.seed_queue_enabled
        seed_queue_size          = var.transmission_env_config.dev.seed_queue_size
        queue_stalled_enabled    = var.transmission_env_config.dev.queue_stalled_enabled
        queue_stalled_minutes    = var.transmission_env_config.dev.queue_stalled_minutes
        peer_limit_global        = var.transmission_env_config.dev.peer_limit_global
        peer_limit_per_torrent   = var.transmission_env_config.dev.peer_limit_per_torrent
        cache_size_mb            = var.transmission_env_config.dev.cache_size_mb
        preallocation            = var.transmission_env_config.dev.preallocation
      }
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
      reel_driver = {
        host   = var.reel_driver_api_config.prod.host.internal
        port   = var.reel_driver_api_config.prod.port.internal
        prefix = var.reel_driver_api_config.prefix
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
      reel_driver = {
        host   = var.reel_driver_api_config.stg.host.internal
        port   = var.reel_driver_api_config.stg.port.internal
        prefix = var.reel_driver_api_config.prefix
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
      reel_driver = {
        host   = var.reel_driver_api_config.dev.host.internal
        port   = var.reel_driver_api_config.dev.port.internal
        prefix = var.reel_driver_api_config.prefix
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
    prod = {
      host                  = var.server_ip
      port_external         = var.rear_diff_vars.prod.port_external
      prefix                = var.rear_diff_vars.prefix
      file_deletion_enabled = var.rear_diff_vars.file_deletion_enabled
      pgsql = {
        host     = var.pgsql_default_config.prod.host
        port     = var.pgsql_default_config.prod.port
        database = var.pgsql_default_config.database
      }
      transmission = {
        host = var.server_ip
        port = var.transmission_vars.prod.port
      }
      paths = {
        media_cache_path          = var.at_vars.prod.download_dir
        media_library_path_movies = var.at_vars.prod.movie_dir
        media_library_path_tv     = var.at_vars.prod.tv_show_dir
      }
      api_urls = {
        movie_search  = var.at_vars.movie_search_api_base_url
        movie_details = var.at_vars.movie_details_api_base_url
        movie_ratings = var.at_vars.movie_ratings_api_base_url
        tv_search     = var.at_vars.tv_search_api_base_utl
        tv_details    = var.at_vars.tv_details_api_base_url
        tv_ratings    = var.at_vars.tv_ratings_api_base_url
      }
    }
    stg = {
      host                  = var.server_ip
      port_external         = var.rear_diff_vars.stg.port_external
      prefix                = var.rear_diff_vars.prefix
      file_deletion_enabled = var.rear_diff_vars.file_deletion_enabled
      pgsql = {
        host     = var.pgsql_default_config.stg.host
        port     = var.pgsql_default_config.stg.port
        database = var.pgsql_default_config.database
      }
      transmission = {
        host = var.server_ip
        port = var.transmission_vars.stg.port
      }
      paths = {
        media_cache_path          = var.at_vars.stg.download_dir
        media_library_path_movies = var.at_vars.stg.movie_dir
        media_library_path_tv     = var.at_vars.stg.tv_show_dir
      }
      api_urls = {
        movie_search  = var.at_vars.movie_search_api_base_url
        movie_details = var.at_vars.movie_details_api_base_url
        movie_ratings = var.at_vars.movie_ratings_api_base_url
        tv_search     = var.at_vars.tv_search_api_base_utl
        tv_details    = var.at_vars.tv_details_api_base_url
        tv_ratings    = var.at_vars.tv_ratings_api_base_url
      }
    }
    dev = {
      host                  = var.server_ip
      port_external         = var.rear_diff_vars.dev.port_external
      prefix                = var.rear_diff_vars.prefix
      file_deletion_enabled = var.rear_diff_vars.file_deletion_enabled
      pgsql = {
        host     = var.pgsql_default_config.dev.host
        port     = var.pgsql_default_config.dev.port
        database = var.pgsql_default_config.database
      }
      transmission = {
        host = var.server_ip
        port = var.transmission_vars.dev.port
      }
      paths = {
        media_cache_path          = var.at_vars.dev.download_dir
        media_library_path_movies = var.at_vars.dev.movie_dir
        media_library_path_tv     = var.at_vars.dev.tv_show_dir
      }
      api_urls = {
        movie_search  = var.at_vars.movie_search_api_base_url
        movie_details = var.at_vars.movie_details_api_base_url
        movie_ratings = var.at_vars.movie_ratings_api_base_url
        tv_search     = var.at_vars.tv_search_api_base_utl
        tv_details    = var.at_vars.tv_details_api_base_url
        tv_ratings    = var.at_vars.tv_ratings_api_base_url
      }
    }
  }

  rear_diff_secrets = {
    prod = {
      pgsql = {
        username = var.rear_diff_secrets.prod.pgsql.username
        password = var.rear_diff_secrets.prod.pgsql.password
      }
      transmission = {
        username = var.transmission_secrets.prod.username
        password = var.transmission_secrets.prod.password
      }
      movie_search_api_key  = var.at_secret_vars.movie_search_api_key
      movie_details_api_key = var.at_secret_vars.movie_details_api_key
      movie_ratings_api_key = var.at_secret_vars.movie_ratings_api_key
      tv_search_api_key     = var.at_secret_vars.tv_search_api_key
      tv_details_api_key    = var.at_secret_vars.tv_details_api_key
      tv_ratings_api_key    = var.at_secret_vars.tv_ratings_api_key
    }
    stg = {
      pgsql = {
        username = var.rear_diff_secrets.stg.pgsql.username
        password = var.rear_diff_secrets.stg.pgsql.password
      }
      transmission = {
        username = var.transmission_secrets.stg.username
        password = var.transmission_secrets.stg.password
      }
      movie_search_api_key  = var.at_secret_vars.movie_search_api_key
      movie_details_api_key = var.at_secret_vars.movie_details_api_key
      movie_ratings_api_key = var.at_secret_vars.movie_ratings_api_key
      tv_search_api_key     = var.at_secret_vars.tv_search_api_key
      tv_details_api_key    = var.at_secret_vars.tv_details_api_key
      tv_ratings_api_key    = var.at_secret_vars.tv_ratings_api_key
    }
    dev = {
      pgsql = {
        username = var.rear_diff_secrets.dev.pgsql.username
        password = var.rear_diff_secrets.dev.pgsql.password
      }
      transmission = {
        username = var.transmission_secrets.dev.username
        password = var.transmission_secrets.dev.password
      }
      movie_search_api_key  = var.at_secret_vars.movie_search_api_key
      movie_details_api_key = var.at_secret_vars.movie_details_api_key
      movie_ratings_api_key = var.at_secret_vars.movie_ratings_api_key
      tv_search_api_key     = var.at_secret_vars.tv_search_api_key
      tv_details_api_key    = var.at_secret_vars.tv_details_api_key
      tv_ratings_api_key    = var.at_secret_vars.tv_ratings_api_key
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

  center_console_config = {
    for env in ["prod", "stg", "dev"] : env => {
      port_external = var.center_console_config[env].port_external
      api_timeout   = var.center_console_config[env].api_timeout
      mlflow = {
        host = var.mflow_conifg[env].host.internal
        port = var.mflow_conifg[env].port.internal
      }
    }
  }

  center_console_secrets = {
    for env in ["prod", "stg", "dev"] : env => {
      mlflow = {
        username = var.mlflow_secrets[env].username
        password = var.mlflow_secrets[env].password
      }
    }
  }
}

################################################################################
# ai-ml locals
################################################################################

locals {
  ai_ml_secrets = {
    github = {
      username = var.github_secrets.username
      token_packages_read = var.github_secrets.token_packages_read
    }
  }
  
  mlflow_config = {
    prod = {
      uid = var.minio_config.uid
      gid = var.minio_config.gid
      port_external = var.mlflow_vars.prod.port_external
      path = {
        logs = "${var.mlflow_vars.path.root}prod/${var.mlflow_vars.path.directories.logs}"
        packages = "${var.mlflow_vars.path.root}prod/${var.mlflow_vars.path.directories.packages}"
      }
      pgsql = {
        host = var.pgsql_default_config.prod.host
        port = var.pgsql_default_config.prod.port
        database = var.mlflow_vars.pgsql.database
      }
      minio = {
        default_artifact_root = var.mlflow_vars.minio.default_artifact_root
        endpoint = {
          external = var.server_ip
          internal = var.minio_config.prod.endpoint.internal
        }
        port = {
          external = var.minio_config.prod.port.external.api
          internal = var.minio_config.prod.port.internal.api
        }
      }
    }
    stg = {
      uid = var.minio_config.uid
      gid = var.minio_config.gid
      port_external = var.mlflow_vars.stg.port_external
      path = {
        logs = "${var.mlflow_vars.path.root}stg/${var.mlflow_vars.path.directories.logs}"
        packages = "${var.mlflow_vars.path.root}stg/${var.mlflow_vars.path.directories.packages}"
      }
      pgsql = {
        host = var.pgsql_default_config.stg.host
        port = var.pgsql_default_config.stg.port
        database = var.mlflow_vars.pgsql.database
      }
      minio = {
        default_artifact_root = var.mlflow_vars.minio.default_artifact_root
        endpoint = {
          external = var.server_ip
          internal = var.minio_config.stg.endpoint.internal
        }
        port = {
          external = var.minio_config.stg.port.external.api
          internal = var.minio_config.stg.port.internal.api
        }
      }
    }
    dev = {
      uid = var.minio_config.uid
      gid = var.minio_config.gid
      port_external = var.mlflow_vars.dev.port_external
      path = {
        logs = "${var.mlflow_vars.path.root}dev/${var.mlflow_vars.path.directories.logs}"
        packages = "${var.mlflow_vars.path.root}dev/${var.mlflow_vars.path.directories.packages}"
      }
      pgsql = {
        host = var.pgsql_default_config.dev.host
        port = var.pgsql_default_config.dev.port
        database = var.mlflow_vars.pgsql.database
      }
      minio = {
        default_artifact_root = var.mlflow_vars.minio.default_artifact_root
        endpoint = {
          external = var.server_ip
          internal = var.minio_config.dev.endpoint.internal
        }
        port = {
          external = var.minio_config.dev.port.external.api
          internal = var.minio_config.dev.port.internal.api
        }
      }
    }
  }

  mlflow_secrets = {
    prod = {
      username = var.mlflow_secrets.prod.username
      password = var.mlflow_secrets.prod.password
      pgsql = {
        username = var.mlflow_secrets.prod.pgsql.username
        password = var.mlflow_secrets.prod.pgsql.password
      }
      minio = {
        aws_access_key_id = var.minio_secrets.prod.access_key
        aws_secret_access_key = var.minio_secrets.prod.secret_key
      }
    }
    stg = {
      username = var.mlflow_secrets.stg.username
      password = var.mlflow_secrets.stg.password
      pgsql = {
        username = var.mlflow_secrets.stg.pgsql.username
        password = var.mlflow_secrets.stg.pgsql.password
      }
      minio = {
        aws_access_key_id = var.minio_secrets.stg.access_key
        aws_secret_access_key = var.minio_secrets.stg.secret_key
      }
    }
    dev = {
      username = var.mlflow_secrets.dev.username
      password = var.mlflow_secrets.dev.password
      pgsql = {
        username = var.mlflow_secrets.dev.pgsql.username
        password = var.mlflow_secrets.dev.pgsql.password
      }
      minio = {
        aws_access_key_id = var.minio_secrets.dev.access_key
        aws_secret_access_key = var.minio_secrets.dev.secret_key
      }
    }
  }

  reel_driver_config = {
    prod = {
      mflow = {
        host = var.mflow_conifg.prod.host.internal
        port = var.mflow_conifg.prod.port.internal
        experiment = var.reel_driver_config.mlflow.experiment
        model = var.reel_driver_config.mlflow.model
      }
      minio = {
        endpoint = var.minio_config.prod.endpoint.internal
        port = var.minio_config.prod.port.internal.api
      }
    }
    stg = {
      mflow = {
        host = var.mflow_conifg.stg.host.internal
        port = var.mflow_conifg.stg.port.internal
        experiment = var.reel_driver_config.mlflow.experiment
        model = var.reel_driver_config.mlflow.model
      }
      minio = {
        endpoint = var.minio_config.stg.endpoint.internal
        port = var.minio_config.stg.port.internal.api
      }
    }
    dev = {
      mflow = {
        host = var.mflow_conifg.dev.host.internal
        port = var.mflow_conifg.dev.port.internal
        experiment = var.reel_driver_config.mlflow.experiment
        model = var.reel_driver_config.mlflow.model
      }
      minio = {
        endpoint = var.minio_config.dev.endpoint.internal
        port = var.minio_config.dev.port.internal.api
      }
    }
  }
  
  reel_driver_api_config = {
    prod = {
      host       = var.reel_driver_api_config.prod.host.external
      port = {
        external = var.reel_driver_api_config.prod.port.external
        internal = var.reel_driver_api_config.prod.port.internal
      }
      prefix     = var.reel_driver_api_config.prefix
      log_level  = var.reel_driver_api_config.log_level
    }
    stg ={
      host       = var.reel_driver_api_config.stg.host.external
      port = {
        external = var.reel_driver_api_config.stg.port.external
        internal = var.reel_driver_api_config.stg.port.internal
      }
      prefix     = var.reel_driver_api_config.prefix
      log_level  = var.reel_driver_api_config.log_level      
    }
    dev = {
      host       = var.reel_driver_api_config.dev.host.external
      port = {
        external = var.reel_driver_api_config.dev.port.external
        internal = var.reel_driver_api_config.dev.port.internal
      }
      prefix     = var.reel_driver_api_config.prefix
      log_level  = var.reel_driver_api_config.log_level      
    }
  }
  
  reel_driver_training_config = {
    prod = {
      optuna_n_trials          = var.reel_driver_training_config.prod.optuna_n_trials
      xgboost_n_estimators_max = var.reel_driver_training_config.prod.xgboost_n_estimators_max
      pgsql = {
        host     = var.pgsql_default_config.prod.host
        port     = var.pgsql_default_config.prod.port
        database = var.pgsql_default_config.database
        schema   = var.pgsql_default_config.schema
      }
    }
    stg = {
      optuna_n_trials          = var.reel_driver_training_config.stg.optuna_n_trials
      xgboost_n_estimators_max = var.reel_driver_training_config.stg.xgboost_n_estimators_max
      pgsql = {
        host     = var.pgsql_default_config.stg.host
        port     = var.pgsql_default_config.stg.port
        database = var.pgsql_default_config.database
        schema   = var.pgsql_default_config.schema
      }
    }
    dev = {
      optuna_n_trials          = var.reel_driver_training_config.dev.optuna_n_trials
      xgboost_n_estimators_max = var.reel_driver_training_config.dev.xgboost_n_estimators_max
      pgsql = {
        host     = var.pgsql_default_config.dev.host
        port     = var.pgsql_default_config.dev.port
        database = var.pgsql_default_config.database
        schema   = var.pgsql_default_config.schema
      }
    }
  }

  reel_driver_secrets = {
    prod = {
      minio = {
        access_key  = var.minio_secrets.prod.access_key
        secrest_key = var.minio_secrets.prod.secret_key  
      }
    }
    stg = {
      minio = {
        access_key  = var.minio_secrets.stg.access_key
        secrest_key = var.minio_secrets.stg.secret_key  
      }
    }
    dev = {
      minio = {
        access_key  = var.minio_secrets.stg.access_key
        secrest_key = var.minio_secrets.stg.secret_key  
      }
    }
  }

  reel_driver_training_secrets = {
    prod = {
      pgsql = {
        username = var.pgsql_config.prod.user
        password = var.pgsql_config.prod.password
      }
    }
    stg = {
      pgsql = {
        username = var.pgsql_config.stg.user
        password = var.pgsql_config.stg.password
      }
    }
    dev = {
      pgsql = {
        username = var.pgsql_config.dev.user
        password = var.pgsql_config.dev.password
      }
    }
  }

  # local LLM config with server_ip for external access
  local_llm_config = {
    model = var.local_llm_config.model
    host = {
      external = var.server_ip
      internal = "ollama.ai-ml.svc.cluster.local"
    }
    port = {
      internal = var.local_llm_config.port.internal
      external = var.local_llm_config.port.external
    }
  }

  # cici voice assistant config with derived K8s hosts
  cici_config = {
    for env in ["dev", "prod"] : env => {
      # inter-service shared config
      sample_rate  = var.cici_config.sample_rate
      log_level    = var.cici_config.log_level
      default_cwd  = var.cici_config.default_cwd
      claude_model = var.cici_config.claude_model

      # local LLM reference
      local_llm = {
        host = local.local_llm_config.host.internal
        port = local.local_llm_config.port.internal
        model = local.local_llm_config.model
      }

      # face - external exposure (NodePort)
      face = {
        host = {
          internal = "cici-face-${env}.ai-ml.svc.cluster.local"
          external = var.server_ip
        }
        port = {
          internal = var.cici_config.face.port_internal
          external = var.cici_config.face[env].port_external
        }
      }

      # mind - internal only
      mind = {
        host = {
          internal = "cici-mind-${env}.ai-ml.svc.cluster.local"
        }
        port = {
          internal = var.cici_config.mind.port_internal
        }
      }

      # ears - internal only
      ears = {
        host = {
          internal = "cici-ears-${env}.ai-ml.svc.cluster.local"
        }
        port = {
          internal = var.cici_config.ears.port_internal
        }
        silence_ms = var.cici_config.ears.silence_ms
        debug      = var.cici_config.ears.debug
      }

      # mouth - internal only
      mouth = {
        host = {
          internal = "cici-mouth-${env}.ai-ml.svc.cluster.local"
        }
        port = {
          internal = var.cici_config.mouth.port_internal
        }
        piper_voice       = var.cici_config.mouth.piper_voice
        piper_sample_rate = var.cici_config.mouth.piper_sample_rate
      }
    }
  }
}

################################################################################
# experiments locals  
################################################################################

locals {
  experiments_secrets = {
    github = {
      username            = var.github_secrets.username
      token_packages_read = var.github_secrets.token_packages_read
    }
    github_secrets_ng = {
      username            = var.github_secrets_ng.username
      token_packages_read = var.github_secrets_ng.token_packages_read
    }
  }
}

################################################################################
# end of locals.tf
################################################################################