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

run "renewed_certificate_replaces_the_container" {
  command = plan

  assert {
    condition = anytrue([
      for label in docker_container.server.labels :
      label.label == "nginx.sites-ssl.my-app" && label.value == sha256("certificate\nkey")
    ])
    error_message = join(" ", [
      "The container must carry the digest of each site's certificate and key,",
      "to be replaced when they are renewed.",
    ])
  }
}
