mock_provider "docker" {}
mock_provider "jinja" {}
mock_provider "local" {}
mock_provider "null" {}

variables {
  identifier     = "my-app-reverse-proxy"
  image_id       = "sha256:0123456789abcdef"
  network_id     = "my-app"
  data_directory = "/data/my-app/reverse-proxy"
  app_uid        = 101
  app_gid        = 101
  cap_add        = ["NET_BIND_SERVICE"]
  sites = {
    app = {
      name    = "my-app"
      path    = "tests/site.conf.j2"
      domains = ["my-app.example.com"]
      ssl_crt = "certificate"
      ssl_key = "key"
    }
  }
}

run "non_root_user_owns_what_it_writes_and_reads" {
  command = plan

  assert {
    condition = strcontains(
      coalesce(terraform_data.data_directories.input, "none"),
      "chown -R 101:101 '/data/my-app/reverse-proxy/logs/my-app'"
    )
    error_message = join(" ", [
      "The site's log directory must belong to the user running nginx,",
      "which creates its logs there.",
    ])
  }

  assert {
    condition = strcontains(
      coalesce(terraform_data.data_directories.input, "none"),
      join(" ", [
        "chown 101:101",
        "'/data/my-app/reverse-proxy/config/sites-ssl/my-app.crt'",
        "'/data/my-app/reverse-proxy/config/sites-ssl/my-app.key'",
      ])
    )
    error_message = join(" ", [
      "The site's certificate and key, written 0600,",
      "must belong to the user running nginx.",
    ])
  }
}

run "non_root_user_owns_the_whole_cache" {
  command = plan

  assert {
    condition = strcontains(
      coalesce(terraform_data.data_directories.input, "none"),
      "chown -R 101:101 '/data/my-app/reverse-proxy/cache'"
    )
    error_message = join(" ", [
      "The cache must belong to the user running nginx down to its temporary files,",
      "whoever wrote them before.",
    ])
  }
}

run "root_master_leaves_the_cache_to_its_workers" {
  command = plan

  variables {
    app_uid = 0
    app_gid = 0
    cap_add = []
  }

  assert {
    condition = !strcontains(
      coalesce(terraform_data.data_directories.input, "none"),
      "chown -R 0:0 '/data/my-app/reverse-proxy/cache'"
    )
    error_message = join(" ", [
      "Under a root master, the workers run as the image's nginx user and write the cache's",
      "temporary files: the cache's contents must not be handed to root.",
    ])
  }
}

run "site_keys_are_handed_over_before_the_cache_walk" {
  command = plan

  assert {
    condition = endswith(
      coalesce(terraform_data.data_directories.input, "none"),
      "chown -R 101:101 '/data/my-app/reverse-proxy/cache'"
    )
    error_message = join(" ", [
      "The walk of the live cache must come last: a file nginx removes during it fails the",
      "script, which must have handed the site's certificate and key over already.",
    ])
  }
}
