variable "identifier" {
  type = string
}

variable "enabled" {
  type = bool
}

variable "image_id" {
  type        = string
  description = "Nginx image's ID."
}

variable "data_directory" {
  type = string
}

# Logging

variable "error_log_level" {
  type    = string
  default = "warn"
  # TODO check if ...
}

# Miscellaneous

variable "modules" {
  type        = list(string)
  default     = []
  description = "Modules to enable. The GeoIP module is loaded automatically based on `geoip_blocking_enabled`."
}

variable "keepalive_timeout" {
  type        = number
  default     = 75
  description = "http://nginx.org/en/docs/http/ngx_http_core_module.html#keepalive_timeout"
}

variable "types_hash_max_size" {
  type        = number
  default     = 1024
  description = "http://nginx.org/en/docs/http/ngx_http_core_module.html#types_hash_max_size"
}

variable "worker_connections" {
  type    = number
  default = 1024
}

variable "worker_processes" {
  type    = number
  default = 0
}

# Networking

variable "https_port" {
  type    = number
  default = 443
}

variable "http_port" {
  type    = number
  default = 80
}

# Security

variable "dhparam_bits" {
  type    = number
  default = 4096
  # validate >= 2048
}

variable "geoip_blocking_enabled" {
  type    = bool
  default = false
}

variable "geoip_blocking_default" {
  type    = string
  default = "allow"
  # validate allow block enum
}

variable "geoip_countries_blacklist" {
  type    = list(string)
  default = []
}

variable "geoip_countries_whitelist" {
  type    = list(string)
  default = []
}

variable "geoip_database_directory" {
  type    = string
  default = null
}

variable "ips_blacklist" {
  type    = list(string)
  default = []
}

# Sites

variable "main_domain" {
  type = string
}

variable "sites" {
  # TODO type =
}
