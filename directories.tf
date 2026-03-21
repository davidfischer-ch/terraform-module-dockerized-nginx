resource "terraform_data" "data_directories" {
  triggers_replace = [
    local.host_cache_directory,
    local.host_logs_directory
  ]

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p '${local.host_cache_directory}'
      mkdir -p '${local.host_logs_directory}'
      chown ${var.app_uid}:${var.app_gid} '${local.host_cache_directory}'
      chown ${var.app_uid}:${var.app_gid} '${local.host_logs_directory}'
    EOT
  }
}
