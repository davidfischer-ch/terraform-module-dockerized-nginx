terraform {
  required_version = ">= 1.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.23.0"
    }

    jinja = {
      source  = "NikolaLohinski/jinja"
      version = ">= 1.15.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
  }
}
