data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name = lower("${var.prefix}kv${random_string.suffix.result}")

  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  public_network_access_enabled = false
  rbac_authorization_enabled    = true

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  tags = var.tags
}

resource "azurerm_private_endpoint" "pe_kv" {
  name                = "${var.prefix}-pe-kv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.prefix}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "kv-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.zones["kv"].id]
  }
}


# DNS зона має існувати в dns.tf:
# webapp = "privatelink.azurewebsites.net"

resource "azurerm_private_endpoint" "pe_webapp_sites" {
  name                = "${var.prefix}-pe-webapp-sites"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.prefix}-webapp-sites-psc"
    private_connection_resource_id = azurerm_linux_web_app.api.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "webapp-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.zones["webapp"].id]
  }
}

# resource "azurerm_private_endpoint" "pe_webapp_scm" {
#   name                = "${var.prefix}-pe-webapp-scm"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   subnet_id           = azurerm_subnet.private_endpoints.id
#   tags                = var.tags

#   private_service_connection {
#     name                           = "${var.prefix}-webapp-scm-psc"
#     private_connection_resource_id = azurerm_linux_web_app.api.id
#     subresource_names              = ["scm"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "webapp-dns"
#     private_dns_zone_ids = [azurerm_private_dns_zone.zones["webapp"].id]
#   }
# }
