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
