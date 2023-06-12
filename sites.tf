data "jinja_template" "sites_config" {
  for_each = var.sites

  template = each.value.path
  context {
    type = "json"
    data = jsonencode(merge(each.value, local.forced_context))
  }
}

resource "local_file" "sites_config" {
  for_each = var.sites

  filename             = "${local.host_config_directory}/sites-enabled/${each.value.name}.conf"
  content              = data.jinja_template.sites_config[each.key].result
  file_permission      = "0644"
  directory_permission = "0755"
}

resource "null_resource" "sites_dhparam" {
  for_each = var.sites

  provisioner "local-exec" {
    command = join(" ", [
      "mkdir -p ${local.host_config_directory}/sites-dhparam/ && openssl dhparam",
      "-out ${local.host_config_directory}/sites-dhparam/${each.value.name}.pem",
      var.dhparam_bits
    ])
  }
}

resource "local_file" "sites_logs_touch" {
  for_each = var.sites

  filename             = "${local.host_logs_directory}/${each.value.name}/.touch"
  content              = "Generate by Terraform to setup the logs directory for the site."
  file_permission      = "0644"
  directory_permission = "0755"
}

resource "local_sensitive_file" "sites_ssl_crt" {
  for_each = var.sites

  filename             = "${local.host_config_directory}/sites-ssl/${each.value.name}.crt"
  content              = each.value.ssl_crt
  file_permission      = "0440"
  directory_permission = "0755"
}

resource "local_sensitive_file" "sites_ssl_key" {
  for_each = var.sites

  filename             = "${local.host_config_directory}/sites-ssl/${each.value.name}.key"
  content              = each.value.ssl_key
  file_permission      = "0440"
  directory_permission = "0755"
}
