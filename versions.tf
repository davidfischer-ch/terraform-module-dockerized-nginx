terraform {
  required_version = ">= 1.17"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 4.7.0"
    }

    jinja = {
      source  = "NikolaLohinski/jinja"
      version = ">= 2.0.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.2"
    }
  }
}
