# The module against a real Docker daemon, driven by run.sh.
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 4.7.0"
    }
  }
}

variable "data_directory" {
  type = string
}

variable "image" {
  type = string
}

resource "docker_image" "nginx" {
  name         = var.image
  keep_locally = true
}

resource "docker_network" "e2e" {
  name = "nginx-e2e"
}

module "nginx" {
  source = "../.."

  identifier = "nginx-e2e"
  image_id   = docker_image.nginx.image_id
  network_id = docker_network.e2e.id

  # Nothing published: run.sh requests the site from inside the container.
  http_port  = null
  https_port = null

  data_directory = var.data_directory

  # The smallest parameters the module accepts, generated in a second.
  dhparam_bits    = 2048
  dhparam_use_dsa = true

  sites = {
    e2e = {
      name    = "e2e"
      path    = "site.conf.j2"
      domains = ["nginx-e2e"]
      message = "served"

      # Written by the module, read by no directive of site.conf.j2.
      ssl_crt = "unused"
      ssl_key = "unused"
    }
  }
}
