output "acr_login_server" { value = azurerm_container_registry.acr.login_server }
output "key_vault_uri" { value = azurerm_key_vault.kv.vault_uri }
output "sql_fqdn" { value = azurerm_mssql_server.sql.fully_qualified_domain_name }
output "container_app_name" { value = azurerm_container_app.backend.name }
