# Changelog

## Release v1.1.0 (2026-03-13)

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
