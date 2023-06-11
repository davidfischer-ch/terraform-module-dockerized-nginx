resource "docker_container" "server" {

  depends_on = [
    local_file.sites_logs_touch
  ]

  lifecycle {
    replace_triggered_by = [
      local_file.main_config,
      local_file.security_config,
      local_file.sites_config,
      null_resource.sites_dhparam
    ]
  }

  image = var.image_id
  name  = var.identifier

  must_run = var.enabled
  start    = var.enabled
  restart  = "always"
  # wait   = true

  # shm_size = 256 # MB

  hostname = var.identifier

  networks_advanced {
    name = var.network_id
  }

  env = [
    #"GITLAB_LOG_LEVEL=${var.log_level}",
    #"GITLAB_OMNIBUS_CONFIG=${join("\n", local.config)}"
  ]

  ports {
    internal = "80"
    external = var.http_port
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  ports {
    internal = "443"
    external = var.https_port
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  volumes {
    container_path = "/etc/nginx/nginx.conf"
    host_path      = local_file.main_config.filename
    read_only      = true
  }

  volumes {
    container_path = "/etc/nginx/conf.d"
    host_path      = "${local.config_directory}/conf.d"
    read_only      = true
  }

  volumes {
    container_path = "/etc/nginx/sites-enabled"
    host_path      = "${local.config_directory}/sites-enabled"
    read_only      = true
  }

  volumes {
    container_path = "/etc/nginx/sites-dhparam"
    host_path      = "${local.config_directory}/sites-dhparam"
    read_only      = true
  }

  volumes {
    container_path = "/etc/nginx/sites-ssl"
    host_path      = "${local.config_directory}/sites-ssl"
    read_only      = true
  }

  volumes {
    container_path = "/var/log/nginx"
    host_path      = local.logs_directory
    read_only      = false
  }

  volumes {
    container_path = "/var/cache/nginx"
    host_path      = "${var.data_directory}/${var.identifier}/cache"
    read_only      = false
  }

  # GeoIP

  # TODO make it optional
  volumes {
    container_path = local.forced_context.geoip_database_directory
    host_path      = var.geoip_database_directory
    read_only      = true
  }
}
