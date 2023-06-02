locals {
  config_directory = "${var.data_directory}/${var.identifier}/config"
  logs_directory   = "${var.data_directory}/${var.identifier}/logs"

  forced_context = {
    error_log_level           = var.error_log_level
    geoip_blocking_default    = var.geoip_blocking_default
    geoip_blocking_enabled    = var.geoip_blocking_enabled
    geoip_countries_blacklist = var.geoip_countries_blacklist
    geoip_countries_whitelist = var.geoip_countries_whitelist
    geoip_database_directory  = "/etc/geoip-db"
    http_external_port        = var.http_port
    http_internal_port        = 80
    https_external_port       = var.https_port
    https_internal_port       = 443
    ips_blacklist             = var.ips_blacklist
    keepalive_timeout         = var.keepalive_timeout
    types_hash_max_size       = var.types_hash_max_size
    worker_connections        = var.worker_connections
    worker_processes          = var.worker_processes
  }
}
