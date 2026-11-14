# Main

data "jinja_template" "main_config" {
  source {
    directory = path.module
    template  = file("${path.module}/config/nginx.conf.j2")
  }
  context {
    type = "json"
    data = jsonencode(local.forced_context)
  }

  lifecycle {
    precondition {
      condition = !var.geoip_blocking_enabled || (
        var.geoip_database_directory != null ? alltrue([
          for edition in ["GeoLite2-Country", "GeoLite2-City"] :
          fileexists("${var.geoip_database_directory}/${edition}.mmdb")
        ]) : false
      )
      error_message = join("", [
        "GeoIP blocking needs GeoLite2-Country.mmdb and GeoLite2-City.mmdb in ",
        "`geoip_database_directory` (${coalesce(var.geoip_database_directory, "undefined")}): ",
        "the updater writing them must have run first."
      ])
    }
  }
}

resource "local_file" "main_config" {
  filename             = "${local.host_config_directory}/nginx.conf"
  content              = data.jinja_template.main_config.result
  file_permission      = "0644"
  directory_permission = "0755"
}

# Security

data "jinja_template" "security_config" {
  source {
    directory = path.module
    template  = file("${path.module}/config/security.conf.j2")
  }
  context {
    type = "json"
    data = jsonencode(local.forced_context)
  }
}

resource "local_file" "security_config" {
  filename             = "${local.host_config_directory}/conf.d/security.conf"
  content              = data.jinja_template.security_config.result
  file_permission      = "0644"
  directory_permission = "0755"
}
