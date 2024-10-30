variable "identifier" {
  type        = string
  description = "Identifier (must be unique, used to name resources)."
  validation {
    condition     = regex("^[a-z]+(-[a-z0-9]+)*$", var.identifier) != null
    error_message = "Argument `identifier` must match regex ^[a-z]+(-[a-z0-9]+)*$."
  }
}

variable "enabled" {
  type        = bool
  description = "Toggle the containers (started or stopped)."
}

variable "image_id" {
  type        = string
  description = "Nginx image's ID."
}

variable "data_directory" {
  type        = string
  description = "Where data will be persisted (volumes will be mounted as sub-directories)."
}

variable "extra_volumes" {
  type = list(object({
    container_path = optional(string)
    from_container = optional(string)
    host_path      = optional(string)
    read_only      = optional(bool)
    volume_name    = optional(string)
  }))
  default = []
}

# Logging ------------------------------------------------------------------------------------------

variable "error_log_level" {
  type    = string
  default = "warn"
  # TODO check if ...
}

# Miscellaneous ------------------------------------------------------------------------------------

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

# Networking ---------------------------------------------------------------------------------------

variable "hosts" {
  type        = map(string)
  default     = {}
  description = "Add entries to container hosts file."
}

variable "network_id" {
  type        = string
  description = "Attach the containers to given network."
}

variable "https_port" {
  type        = number
  default     = 443
  description = "Bind the reverse proxy's HTTPS port."
}

variable "http_port" {
  type        = number
  default     = 80
  description = "Bind the reverse proxy's HTTP port."
}

# Security -----------------------------------------------------------------------------------------

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

variable "sites" {
  # TODO type =
}
