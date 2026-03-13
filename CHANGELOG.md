# Changelog

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
