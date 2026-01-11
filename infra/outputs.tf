output "acr_login_server" { value = azurerm_container_registry.acr.login_server }
output "key_vault_uri" { value = azurerm_key_vault.kv.vault_uri }
output "sql_fqdn" { value = azurerm_mssql_server.sql.fully_qualified_domain_name }
//output "container_app_name" { value = azurerm_container_app.backend.name }
output "app_service_url" {
  value = "https://${azurerm_linux_web_app.api.default_hostname}"
}
output "app_files_mount_path" {
  value = "/mounts/userfiles"
}
