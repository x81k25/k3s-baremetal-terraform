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
      username = var.github_secrets.username
      token_packages_read = var.github_secrets.token_packages_read
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
      username = var.github_secrets.username
      token_packages_read = var.github_secrets.token_packages_read
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
      host          = var.server_ip
      port_external = var.rear_diff_vars.prod.port_external
      prefix        = var.rear_diff_vars.prefix
      pgsql = {
        host     = var.pgsql_default_config.prod.host
        port     = var.pgsql_default_config.prod.port
        database = var.pgsql_default_config.database
      }
    }
    stg = {
      host          = var.server_ip
      port_external = var.rear_diff_vars.stg.port_external
      prefix        = var.rear_diff_vars.prefix
      pgsql = {
        host     = var.pgsql_default_config.stg.host
        port     = var.pgsql_default_config.stg.port
        database = var.pgsql_default_config.database
      }
    }
    dev = {
      host          = var.server_ip
      port_external = var.rear_diff_vars.dev.port_external
      prefix        = var.rear_diff_vars.prefix
      pgsql = {
        host     = var.pgsql_default_config.dev.host
        port     = var.pgsql_default_config.dev.port
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
      hyper_param_search_start = var.reel_driver_training_config.prod.hyper_param_search_start
      pgsql = {
        host     = var.pgsql_default_config.prod.host
        port     = var.pgsql_default_config.prod.port
        database = var.pgsql_default_config.database
        schema   = var.pgsql_default_config.schema
      }
    }
    stg = {
      hyper_param_search_start = var.reel_driver_training_config.stg.hyper_param_search_start
      pgsql = {
        host     = var.pgsql_default_config.stg.host
        port     = var.pgsql_default_config.stg.port
        database = var.pgsql_default_config.database
        schema   = var.pgsql_default_config.schema
      }
    }
    dev ={
      hyper_param_search_start = var.reel_driver_training_config.dev.hyper_param_search_start
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
}

################################################################################
# end of locals.tf
################################################################################