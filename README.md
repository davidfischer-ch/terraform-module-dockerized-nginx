# Nginx Terraform Module (Dockerized)

Manage Nginx reverse proxy and virtual hosts.

* Runs in bridge networking mode
* Exposes HTTPS and HTTP ports
* Configuration rendered via Jinja templates
* Automatic DH parameter generation (with DSA option for faster generation)
* Per-site SSL certificate and basic auth management
* Optional GeoIP-based access control with country blacklist/whitelist
* IP blacklist support

## Usage

See [examples/default](examples/default) for a complete working configuration.

```hcl
module "reverse_proxy" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-nginx.git?ref=1.1.0"

  identifier     = "my-app-reverse-proxy"
  enabled        = true
  image_id       = docker_image.nginx.image_id
  data_directory = "/data/my-app/reverse-proxy"

  # Logging

  error_log_level = "warn"

  # Miscellaneous

  modules = []

  # Networking

  hosts      = { "myserver" = "10.0.0.1" }
  network_id = docker_network.app.id
  https_port = 443
  http_port  = 80

  # Security

  dhparam_use_dsa = false

  # Sites

  sites = {
    app = {
      name     = "my-app"
      path     = "${path.module}/sites/app.conf.j2"
      inc_path = module.templates.inc_path
      host     = module.app.host
      port     = module.app.port
      domains  = ["my-app.example.com"]

      redirect_ssl = true
      with_dhparam = true
      with_http2   = true
      with_ssl     = true
      ssl_crt      = var.ssl_crt
      ssl_key      = var.ssl_key

      max_body_size = "20M"
    }
  }
}
```

## Data layout

All persistent data lives under `data_directory`:

```
data_directory/
├── cache/   # Nginx cache files
├── config/  # Generated configuration (nginx.conf, conf.d/, sites-enabled/, SSL, dhparam)
└── logs/    # Nginx access and error logs
```

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `identifier` | `string` | — | Unique name for resources (must match `^[a-z]+(-[a-z0-9]+)*$`). |
| `enabled` | `bool` | — | Start or stop the container. |
| `wait` | `bool` | `false` | Wait for the container to reach a healthy state after creation. |
| `image_id` | `string` | — | [Nginx](https://hub.docker.com/_/nginx/tags) Docker image's ID. |
| `app_uid` | `number` | `0` | UID of the user running the container (default root). |
| `app_gid` | `number` | `0` | GID of the user running the container (default root). |
| `privileged` | `bool` | `false` | Run the container in privileged mode. |
| `cap_add` | `set(string)` | `[]` | Linux capabilities to add (e.g. `["NET_BIND_SERVICE"]`). |
| `cap_drop` | `set(string)` | `[]` | Linux capabilities to drop from the container. |
| `data_directory` | `string` | — | Host path for persistent volumes. |
| `extra_volumes` | `list(object)` | `[]` | Additional volume mounts. |
| `error_log_level` | `string` | `"warn"` | Nginx error log level. |
| `modules` | `list(string)` | `[]` | Nginx modules to enable. |
| `keepalive_timeout` | `number` | `75` | HTTP keepalive timeout. |
| `types_hash_max_size` | `number` | `1024` | Types hash table size. |
| `worker_connections` | `number` | `1024` | Worker connections limit. |
| `worker_processes` | `number` | `0` | Worker processes (0 = auto). |
| `hosts` | `map(string)` | `{}` | Extra `/etc/hosts` entries for the container. |
| `network_id` | `string` | — | Docker network to attach to. |
| `https_port` | `number` | `443` | HTTPS bind port. |
| `http_port` | `number` | `80` | HTTP bind port. |
| `dhparam_bits` | `number` | `4096` | DH parameter bits. |
| `dhparam_use_dsa` | `bool` | `false` | Use DSA instead of DH params (faster but weaker). |
| `geoip_blocking_enabled` | `bool` | `false` | Enable GeoIP-based access control. |
| `geoip_blocking_default` | `string` | `"allow"` | Default GeoIP action. |
| `geoip_countries_blacklist` | `list(string)` | `[]` | Country codes to block. |
| `geoip_countries_whitelist` | `list(string)` | `[]` | Country codes to allow. |
| `geoip_database_directory` | `string` | `null` | Host path to GeoIP MaxMind databases. |
| `ips_blacklist` | `list(string)` | `[]` | IP addresses to block. |
| `sites` | — | — | Virtual host configurations (site-specific Jinja templates). |

## Running as non-root

By default the container runs as root (UID/GID 0), which is required to bind ports 80 and 443.
To run as an unprivileged user, set `app_uid` / `app_gid` to a non-root value and grant the
`NET_BIND_SERVICE` capability so Nginx can still bind privileged ports:

```hcl
module "reverse_proxy" {
  # ...
  app_uid = 1000
  app_gid = 1000
  cap_add = ["NET_BIND_SERVICE"]
}
```

## Requirements

* Terraform >= 1.6
* [kreuzwerker/docker](https://github.com/kreuzwerker/terraform-provider-docker) >= 3.0.2
* [NikolaLohinski/jinja](https://github.com/NikolaLohinski/terraform-provider-jinja) >= 1.17.0
* [hashicorp/local](https://github.com/hashicorp/terraform-provider-local) >= 2.2.3
* [hashicorp/null](https://github.com/hashicorp/terraform-provider-null) >= 3.2.2

## References

* https://hub.docker.com/_/nginx
* https://linuxhint.com/what-are-worker-connections-nginx/
* https://github.com/davidfischer-ch/ansible-role-nginx
