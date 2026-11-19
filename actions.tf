# On-demand operations on the server, run with `terraform apply -invoke=<action address>`.

# Check the configuration nginx would load, its syntax and the files it names.
action "docker_exec" "test" {
  config {
    container = docker_container.server.name
    user      = "${var.app_uid}:${var.app_gid}"
    command   = ["nginx", "-t"]
  }
}

# Load the configuration again without recreating the container. A configuration nginx cannot read
# fails the action and leaves the running one.
action "docker_exec" "reload" {
  config {
    container = docker_container.server.name
    user      = "${var.app_uid}:${var.app_gid}"
    command   = ["nginx", "-s", "reload"]
  }
}
