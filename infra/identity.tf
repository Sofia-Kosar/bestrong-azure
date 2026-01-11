resource "azurerm_user_assigned_identity" "app" {
  name                = "${var.prefix}-app-mi"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.tags
}

# Дозволяємо Web App (через MI) тягнути образ з ACR
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

# Якщо Key Vault у тебе є і ти хочеш читати секрети з апки — залишай.
# Якщо зараз keyvault.tf також закоментований/видалений — тоді цей блок закоментуй.
resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
