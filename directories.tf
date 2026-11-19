resource "terraform_data" "data_directories" {
  depends_on = [
    local_file.sites_logs_touch,
    local_sensitive_file.sites_ssl_crt,
    local_sensitive_file.sites_ssl_key
  ]

  # Re-run on a changed path or owner, and on a rewritten certificate or key (written as the
  # Terraform user).
  triggers_replace = [
    local.directories_command,
    [for file in local_sensitive_file.sites_ssl_crt : file.id],
    [for file in local_sensitive_file.sites_ssl_key : file.id]
  ]

  input = local.directories_command

  provisioner "local-exec" {
    command = self.input
  }
}
