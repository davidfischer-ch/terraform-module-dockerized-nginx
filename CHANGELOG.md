# Changelog


## Release v1.6.2 (2026-11-20)

Diff: https://github.com/davidfischer-ch/terraform-module-dockerized-nginx/compare/1.6.1...1.6.2

### Fix and enhancements

Server:

* Fix the large proxied responses and request bodies cut under a root master: the cache directory alone is handed to `app_uid`, its contents staying with the workers
    * A 1.6.1 apply under `app_uid = 0` handed the cache's level directories to root: chown them back to the image's `nginx` user once by hand (`chown -R 101:101 <data_directory>/cache/*_temp`)
* Hand each site's certificate and key to `app_uid` before walking the cache, which a file nginx removes meanwhile can no longer leave root-owned


## Release v1.6.1 (2026-11-19)

Diff: https://github.com/davidfischer-ch/terraform-module-dockerized-nginx/compare/1.6.0...1.6.1

### Features

Server:

* Add a healthcheck on the master process and its `healthcheck_enabled` input
    * `wait` requires the healthcheck: `wait = true` with `healthcheck_enabled = false` fails the plan

Actions:

* Add `test` and `reload` actions, checking and loading the configuration without recreating the container

CI:

* Add CI: formatting, validation and the tests, in the GitHub workflow (with the newest providers and their minimums) and in the GitLab pipeline
* Add an end-to-end test of the module and its actions against a real Docker daemon, on nginx 1.28

### Fix and enhancements

Server:

* Replace the container when a site's certificate or key is renewed, through a digest label per site
    * The container is replaced once on upgrade, and at each renewal from then on
* Start nginx as a non-root `app_uid`, owner of the cache and logs directories, of each site's logs and of its certificate and key
* Quote the host paths of the shell commands
* Pass `ALL` in `cap_add` and `cap_drop` to Docker as its wildcard instead of `CAP_ALL`

Requirements:

* Require Terraform 1.17
* Require the Docker provider 4.7.0

Docs:

* Document `ALL` in `cap_add` and `cap_drop`
* Point the README and the examples at this release


## Release v1.6.0 (2026-11-14)

Diff: https://github.com/davidfischer-ch/terraform-module-dockerized-nginx/compare/1.5.0...1.6.0

### Minor compatibility breaks

GeoIP:

* Read `GeoLite2-Country.mmdb` and `GeoLite2-City.mmdb` directly in `geoip_database_directory`, no longer in a subfolder per edition
    * Move the files up one level, or point the variable at the folder `geoipupdate` writes

### Fix and enhancements

GeoIP:

* Stop the plan when blocking is on and either database is missing from `geoip_database_directory`
* Reload the City database within five minutes of its replacement, like the Country one

## Release v1.5.0 (2026-11-10)

Diff: https://github.com/davidfischer-ch/terraform-module-dockerized-nginx/compare/1.4.0...1.5.0

### Minor compatibility breaks

Networking:

* Publish the HTTP and HTTPS ports on `listener_address`, `127.0.0.1` by default instead of `0.0.0.0`
    * Set `listener_address = "0.0.0.0"` to keep them reachable from every network

### Features

Networking:

* Add `extra_networks` to attach the container to further Docker networks, to proxy to their containers by name
* Allow `http_port` and `https_port` to be `null`, to publish no port

## Release v1.4.0 (2026-11-09)

Diff: https://github.com/davidfischer-ch/terraform-module-dockerized-nginx/compare/1.3.0...1.4.0

### Minor compatibility breaks

GeoIP:

* Let private addresses (LAN, Docker networks) through even when `geoip_blocking_default` is `block`

### Features

GeoIP:

* Add `geoip_continents_whitelist` to allow whole continents, the blacklisted countries still blocked within them
* Expose the continent code to the sites as `$geoip2_data_continent_code`

## Release v1.3.0 (2026-04-28)

### Minor compatibility breaks

* Bump minimum `NikolaLohinski/jinja` provider version from `1.17.0` to `2.0.0`. Consumers must run `terraform init -upgrade` to refresh the provider.

### Fix and enhancements

* Add http-scope `resolver` directive (Cloudflare + Google) so OCSP stapling and runtime DNS lookups work
* Add `resolver_ipv6` variable to disable AAAA lookups on IPv4-only hosts where they hang
* Migrate `jinja_template` data sources from deprecated `template` attribute to `source` block

## Release v1.2.2 (2026-03-21)

### Fix and enhancements

* Replace local-exec provisioners with a terraform_data resource for directory management

## Release v1.2.1 (2026-03-14)

### Fix and enhancements

* Reorder variables to be consistent

## Release v1.2.0 (2026-03-13)

### Minor compatibility breaks

* The `cap_add` and `cap_drop` capabilities names are prefixed with `CAP_` for the Docker provider
* The `cap_add` and `cap_drop` variables are now validated against the exhaustive list of Linux capabilities

## Release v1.1.3 (2026-03-13)

### Fix and enhancements

* Set `enabled` and `wait` defaults to `true`
* Refine variable descriptions, validators, and attribute ordering
* Remove redundant default values from examples and README

## Release v1.1.2 (2026-03-13)

### Fix and enhancements

* Set `NGINX_PID_FILE` env var (`/var/run/nginx.pid` for root, `/tmp/nginx.pid` for non-root)

## Release v1.1.1 (2026-03-13)

### Fix and enhancements

* Fix non-root operation: skip `user nginx;` directive and use `/tmp/nginx.pid` when
  running as a non-root user to avoid a fatal Permission denied error on startup

## Release v1.1.0 (2026-03-13)

### Minor compatibility breaks

* SSL certificate and key files under `sites-ssl/` changed permissions from `0440`
  to `0600` — existing deployments will see these files recreated on next apply

### Fix and enhancements

* Add `# Process` section: `app_uid`, `app_gid`, `privileged`, `cap_add`, `cap_drop`
  variables wired into the container via `user`, `privileged`, and a dynamic `capabilities` block
  (defaults to root UID/GID 0, required to bind ports 80/443)
* Add per-site basic auth: manage `htpasswd` files and recreate the server on credential changes
* Add `examples/default/` Terraform example

## Release v1.0.2 (2025-06-11)

### Features

* Add variable `dhparam_use_dsa` (default to `false`)

## Release v1.0.1 (2025-03-03)

### Fix and enhancements

* Set network mode to bridge to prevent infinite recreate loop

## Release v1.0.0 (2025-01-20)

Initial release
