resource "azurerm_container_registry" "acr" {
  name = lower("${var.prefix}acr${random_string.suffix.result}")

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku           = "Premium"
  admin_enabled = true # Потрібно для GitHub Actions authentication

  # Дозволяємо публічний доступ для GitHub Actions push
  # Private endpoint все ще працює для App Service
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "random_string" "acr_suffix" {
  length  = 6
  upper   = false
  special = false
}


resource "azurerm_private_endpoint" "pe_acr" {
  name                = "${var.prefix}-pe-acr"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.prefix}-acr-psc"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.zones["acr"].id]
  }
}
