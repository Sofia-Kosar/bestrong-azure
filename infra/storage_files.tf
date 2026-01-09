resource "azurerm_storage_account" "files" {
  name = lower("${var.prefix}files${random_string.suffix.result}")

  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false

  tags = var.tags
}

resource "azurerm_storage_share" "share" {
  name               = "userfiles"
  storage_account_id = azurerm_storage_account.files.id
  quota              = 100
}

resource "azurerm_private_endpoint" "pe_files" {
  name                = "${var.prefix}-pe-files"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.prefix}-files-psc"
    private_connection_resource_id = azurerm_storage_account.files.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "files-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.zones["file"].id]
  }
}
