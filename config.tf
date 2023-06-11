# Main

data "jinja_template" "main_config" {
  template = "${path.module}/config/nginx.conf.j2"
  context {
    type = "json"
    data = jsonencode(local.forced_context)
  }

  lifecycle {
    precondition {
      condition     = !var.geoip_blocking_enabled || var.geoip_database_directory != null
      error_message = "GeoIP database directory must be defined when enabled."
    }
  }
}

resource "local_file" "main_config" {
  filename             = "${local.config_directory}/nginx.conf"
  content              = data.jinja_template.main_config.result
  file_permission      = "0644"
  directory_permission = "0755"
}

# Security

data "jinja_template" "security_config" {
  template = "${path.module}/config/security.conf.j2"
  context {
    type = "json"
    data = jsonencode(local.forced_context)
  }
}

resource "local_file" "security_config" {
  filename             = "${local.config_directory}/conf.d/security.conf"
  content              = data.jinja_template.security_config.result
  file_permission      = "0644"
  directory_permission = "0755"
}
