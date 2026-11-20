mock_provider "docker" {}
mock_provider "jinja" {}
mock_provider "local" {}
mock_provider "null" {}

variables {
  identifier     = "my-app-reverse-proxy"
  image_id       = "sha256:0123456789abcdef"
  network_id     = "my-app"
  data_directory = "/data/my-app/reverse-proxy"
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

run "directories_reach_the_shell_as_one_word_each" {
  command = plan

  variables {
    data_directory = "/data/a proxy's; id"
  }

  assert {
    condition = local.directories_command == join("\n", [
      "set -e",
      "mkdir -p '/data/a proxy'\\''s; id/cache' '/data/a proxy'\\''s; id/logs'",
      "chown -R 0:0 '/data/a proxy'\\''s; id/logs'",
      "chown -R 0:0 '/data/a proxy'\\''s; id/logs/my-app'",
      join(" ", [
        "chown 0:0",
        "'/data/a proxy'\\''s; id/config/sites-ssl/my-app.crt'",
        "'/data/a proxy'\\''s; id/config/sites-ssl/my-app.key'",
      ]),
      "chown 0:0 '/data/a proxy'\\''s; id/cache'",
    ])
    error_message = "Each path must reach the shell as one single-quoted word."
  }
}
