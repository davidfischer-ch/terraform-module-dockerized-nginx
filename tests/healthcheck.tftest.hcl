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

run "waits_on_a_healthcheck_the_module_defines" {
  command = plan

  assert {
    condition     = length(docker_container.server.healthcheck) == 1
    error_message = "The healthcheck must be defined by default."
  }

  assert {
    condition = (
      !docker_container.server.wait || length(docker_container.server.healthcheck) == 1
    )
    error_message = join(" ", [
      "The official Nginx image defines no healthcheck:",
      "waiting for a healthy container needs the module's own.",
    ])
  }
}

run "wait_requires_the_healthcheck" {
  command = plan

  variables {
    healthcheck_enabled = false
  }

  expect_failures = [docker_container.server]
}

run "disabled_healthcheck_plans_without_wait" {
  command = plan

  variables {
    healthcheck_enabled = false
    wait                = false
  }

  assert {
    condition     = length(docker_container.server.healthcheck) == 0
    error_message = "A disabled healthcheck must leave the image's own, if any."
  }
}
