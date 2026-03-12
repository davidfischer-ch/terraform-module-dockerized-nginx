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

variable "wait" {
  type        = bool
  default     = false
  description = "Wait for the container to reach an healthy state after creation."
}

variable "image_id" {
  type        = string
  description = "Nginx image's ID."
}

# Process ------------------------------------------------------------------------------------------

variable "app_uid" {
  type        = number
  default     = 0
  description = <<EOT
    UID of the user running the container.
    Defaults to root (0), required to bind ports 80/443.
    Set to a non-root UID and add NET_BIND_SERVICE to cap_add to run as an unprivileged user.
  EOT
}

variable "app_gid" {
  type        = number
  default     = 0
  description = <<EOT
    GID of the user running the container.
    Defaults to root (0), required to bind ports 80/443.
    Set to a non-root GID and add NET_BIND_SERVICE to cap_add to run as an unprivileged user.
  EOT
}

variable "privileged" {
  type        = bool
  default     = false
  description = "Run the container in privileged mode."
}

variable "cap_add" {
  type        = set(string)
  default     = []
  description = <<EOT
    Linux capabilities to add to the container.
    Use ["NET_BIND_SERVICE"] together with a non-root app_uid/app_gid
    to allow binding ports 80/443 without running as root.
  EOT
}

variable "cap_drop" {
  type        = set(string)
  default     = []
  description = "Linux capabilities to drop from the container."
}

# Storage ------------------------------------------------------------------------------------------

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

variable "dhparam_use_dsa" {
  type        = bool
  default     = false
  description = <<EOT
    Use DSA (converted to DH) instead of "pure" DH params (DH by default).
    Much faster to generate but using "weaker" prime numbers.

    See https://docs.openssl.org/3.4/man1/openssl-dhparam/#options
  EOT
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
