output "tfstate_rg" { value = azurerm_resource_group.rg.name }
output "tfstate_sa" { value = azurerm_storage_account.sa.name }
output "tfstate_container" { value = azurerm_storage_container.tfstate.name }
