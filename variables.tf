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
  default     = true
}

variable "wait" {
  type        = bool
  description = "Wait for the container to reach an healthy state after creation."
  default     = true
}

variable "image_id" {
  type        = string
  description = "Nginx image's ID."
}

# Process ------------------------------------------------------------------------------------------

variable "app_uid" {
  type        = number
  description = <<EOT
    UID of the user running the container.
    Defaults to root (0), required to bind ports 80/443.
    Set to a non-root UID and add NET_BIND_SERVICE to cap_add to run as an unprivileged user.
  EOT
  default     = 0
}

variable "app_gid" {
  type        = number
  description = <<EOT
    GID of the user running the container.
    Defaults to root (0), required to bind ports 80/443.
    Set to a non-root GID and add NET_BIND_SERVICE to cap_add to run as an unprivileged user.
  EOT
  default     = 0
}

variable "privileged" {
  type        = bool
  description = "Run the container in privileged mode."
  default     = false
}

variable "cap_add" {
  type        = set(string)
  description = <<EOT
    Linux capabilities to add to the container.
    Use ["NET_BIND_SERVICE"] together with a non-root app_uid/app_gid
    to allow binding ports 80/443 without running as root.
  EOT
  default     = []
}

variable "cap_drop" {
  type        = set(string)
  description = "Linux capabilities to drop from the container."
  default     = []
}

# Storage ------------------------------------------------------------------------------------------

variable "data_directory" {
  type        = string
  description = "Where data will be persisted (volumes will be mounted as sub-directories)."
}

variable "extra_volumes" {
  type = map(object({
    container_path = optional(string)
    from_container = optional(string)
    host_path      = optional(string)
    read_only      = optional(bool)
    volume_name    = optional(string)
  }))
  description = "Extra volumes to mount in the container."
  default     = {}
}

# Logging ------------------------------------------------------------------------------------------

variable "error_log_level" {
  type        = string
  description = "Nginx error log level."
  default     = "warn"

  validation {
    condition     = contains(["debug", "info", "notice", "warn", "error", "crit", "alert", "emerg"], var.error_log_level)
    error_message = "Argument `error_log_level` must be one of: debug, info, notice, warn, error, crit, alert, emerg."
  }
}

# Miscellaneous ------------------------------------------------------------------------------------

variable "modules" {
  type        = list(string)
  description = "Modules to enable. The GeoIP module is loaded automatically based on `geoip_blocking_enabled`."
  default     = []
}

variable "keepalive_timeout" {
  type        = number
  description = "http://nginx.org/en/docs/http/ngx_http_core_module.html#keepalive_timeout"
  default     = 75

  validation {
    condition     = var.keepalive_timeout >= 0
    error_message = "Argument `keepalive_timeout` must be 0 or a positive integer."
  }
}

variable "types_hash_max_size" {
  type        = number
  description = "http://nginx.org/en/docs/http/ngx_http_core_module.html#types_hash_max_size"
  default     = 1024

  validation {
    condition     = var.types_hash_max_size >= 1
    error_message = "Argument `types_hash_max_size` must be at least 1."
  }
}

variable "worker_connections" {
  type        = number
  description = "Maximum number of simultaneous connections per worker process."
  default     = 1024

  validation {
    condition     = var.worker_connections >= 1
    error_message = "Argument `worker_connections` must be at least 1."
  }
}

variable "worker_processes" {
  type        = number
  description = "Number of worker processes (0 = auto-detect based on CPU cores)."
  default     = 0

  validation {
    condition     = var.worker_processes >= 0
    error_message = "Argument `worker_processes` must be 0 (auto) or a positive integer."
  }
}

# Networking ---------------------------------------------------------------------------------------

variable "hosts" {
  type        = map(string)
  description = "Add entries to container hosts file."
  default     = {}
}

variable "network_id" {
  type        = string
  description = "Attach the containers to given network."
}

variable "https_port" {
  type        = number
  description = "Bind the reverse proxy's HTTPS port."
  default     = 443

  validation {
    condition     = var.https_port >= 1 && var.https_port <= 65535
    error_message = "Argument `https_port` must be between 1 and 65535."
  }
}

variable "http_port" {
  type        = number
  description = "Bind the reverse proxy's HTTP port."
  default     = 80

  validation {
    condition     = var.http_port >= 1 && var.http_port <= 65535
    error_message = "Argument `http_port` must be between 1 and 65535."
  }
}

# Security -----------------------------------------------------------------------------------------

variable "dhparam_bits" {
  type        = number
  description = "DH parameters key size in bits (minimum 2048)."
  default     = 4096

  validation {
    condition     = var.dhparam_bits >= 2048
    error_message = "Argument `dhparam_bits` must be at least 2048."
  }
}

variable "dhparam_use_dsa" {
  type        = bool
  description = <<EOT
    Use DSA (converted to DH) instead of "pure" DH params (DH by default).
    Much faster to generate but using "weaker" prime numbers.

    See https://docs.openssl.org/3.4/man1/openssl-dhparam/#options
  EOT
  default     = false
}

variable "geoip_blocking_enabled" {
  type        = bool
  description = "Enable GeoIP-based IP blocking."
  default     = false
}

variable "geoip_blocking_default" {
  type        = string
  description = "Default GeoIP policy when the country is not in any list (allow or block)."
  default     = "allow"

  validation {
    condition     = contains(["allow", "block"], var.geoip_blocking_default)
    error_message = "Argument `geoip_blocking_default` must be either \"allow\" or \"block\"."
  }
}

variable "geoip_countries_blacklist" {
  type        = list(string)
  description = "List of country codes to block (when geoip_blocking_default is allow)."
  default     = []
}

variable "geoip_countries_whitelist" {
  type        = list(string)
  description = "List of country codes to allow (when geoip_blocking_default is block)."
  default     = []
}

variable "geoip_database_directory" {
  type        = string
  description = "Directory containing MaxMind GeoIP2 database files."
  default     = null
}

variable "ips_blacklist" {
  type        = list(string)
  description = "List of IP addresses or CIDR ranges to block."
  default     = []
}

# Sites

variable "sites" {
  description = "Map of Nginx virtual host configurations."
}
