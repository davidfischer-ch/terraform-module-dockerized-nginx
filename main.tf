resource "docker_container" "server" {

  depends_on = [
    local_file.sites_logs_touch,
    terraform_data.data_directories
  ]

  lifecycle {
    replace_triggered_by = [
      local_file.main_config,
      local_file.security_config,
      local_file.sites_config,
      local_sensitive_file.sites_htpasswd,
      null_resource.sites_dhparam
    ]
  }

  image = var.image_id
  name  = var.identifier

  must_run = var.enabled
  start    = var.enabled
  restart  = "always"
  wait     = var.wait

  privileged = var.privileged

  dynamic "capabilities" {
    for_each = length(var.cap_add) + length(var.cap_drop) > 0 ? [1] : []
    content {
      add  = [for cap in var.cap_add : "CAP_${cap}"]
      drop = [for cap in var.cap_drop : "CAP_${cap}"]
    }
  }

  user = "${var.app_uid}:${var.app_gid}"

  # shm_size = 256 # MB

  env = ["NGINX_PID_FILE=${var.app_uid == 0 ? "/var/run/nginx.pid" : "/tmp/nginx.pid"}"]

  dynamic "host" {
    for_each = var.hosts
    content {
      host = host.key
      ip   = host.value
    }
  }

  hostname = var.identifier

  networks_advanced {
    name = var.network_id
  }

  dynamic "networks_advanced" {
    for_each = var.extra_networks
    content {
      name = networks_advanced.value.id
    }
  }

  network_mode = "bridge"

  dynamic "ports" {
    for_each = [
      for port in [
        { internal = 80, external = var.http_port },
        { internal = 443, external = var.https_port },
      ] : port if port.external != null
    ]
    content {
      internal = ports.value.internal
      external = ports.value.external
      ip       = var.listener_address
      protocol = "tcp"
    }
  }

  # Config owner root:root
  volumes {
    container_path = "${local.container_config_directory}/nginx.conf"
    host_path      = local_file.main_config.filename
    read_only      = true
  }

  # Config owner root:root
  volumes {
    container_path = "${local.container_config_directory}/conf.d"
    host_path      = "${local.host_config_directory}/conf.d"
    read_only      = true
  }

  # Config owner root:root
  volumes {
    container_path = "${local.container_config_directory}/sites-auth"
    host_path      = "${local.host_config_directory}/sites-auth"
    read_only      = true
  }

  # Config owner root:root
  volumes {
    container_path = "${local.container_config_directory}/sites-enabled"
    host_path      = "${local.host_config_directory}/sites-enabled"
    read_only      = true
  }

  # Config owner root:root
  volumes {
    container_path = "${local.container_config_directory}/sites-dhparam"
    host_path      = "${local.host_config_directory}/sites-dhparam"
    read_only      = true
  }

  # Config owner root:root
  volumes {
    container_path = "${local.container_config_directory}/sites-ssl"
    host_path      = "${local.host_config_directory}/sites-ssl"
    read_only      = true
  }

  # Logs owner root:root
  volumes {
    container_path = local.container_logs_directory
    host_path      = local.host_logs_directory
    read_only      = false
  }

  # Cache owner root:root
  volumes {
    container_path = local.container_cache_directory
    host_path      = local.host_cache_directory
    read_only      = false
  }

  # GeoIP

  # TODO make it optional
  # GeoIP owner root:root
  volumes {
    container_path = local.forced_context.geoip_database_directory
    host_path      = var.geoip_database_directory
    read_only      = true
  }

  # Extra

  # Extra owner root:root
  dynamic "volumes" {
    for_each = var.extra_volumes
    content {
      container_path = try(volumes.value.container_path, null)
      from_container = try(volumes.value.from_container, null)
      host_path      = try(volumes.value.host_path, null)
      read_only      = try(volumes.value.read_only, null)
      volume_name    = try(volumes.value.volume_name, null)
    }
  }
}
