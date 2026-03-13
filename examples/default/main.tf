resource "aws_route53_zone" "main" {
  name = "example.com"
}

resource "acme_registration" "main" {
  email_address = var.acme_email
}

resource "acme_certificate" "my_app" {
  account_key_pem = acme_registration.main.account_key_pem
  common_name     = "my-app.example.com"

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = aws_route53_zone.main.zone_id
    }
  }
}

resource "docker_image" "nginx" {
  name         = "nginx:1.28.0"
  keep_locally = true
}

resource "docker_network" "app" {
  name   = "my-app"
  driver = "bridge"
}

module "reverse_proxy" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-nginx.git?ref=1.1.2"

  identifier     = "my-app-reverse-proxy"
  image_id       = docker_image.nginx.image_id
  data_directory = "/data/my-app/reverse-proxy"

  network_id = docker_network.app.id

  sites = {
    app = {
      name    = "my-app"
      path    = "${path.module}/sites/app.conf.j2"
      domains = ["my-app.example.com"]

      address = "my-app"
      port    = 8000

      redirect_ssl  = true
      with_dhparam  = true
      with_http2    = true
      with_ssl      = true
      ssl_crt       = join("", [acme_certificate.my_app.certificate_pem, acme_certificate.my_app.issuer_pem])
      ssl_key       = acme_certificate.my_app.private_key_pem
      max_body_size = "20M"
    }
  }
}
