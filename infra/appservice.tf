############################################
# App Service for Containers (Linux Web App)
############################################

locals {
  acr_login_server    = azurerm_container_registry.acr.login_server
  docker_registry_url = "https://${local.acr_login_server}"
  # var.container_image: myacr.azurecr.io/backend:1.0.0  ->  backend:1.0.0
  docker_image_name = replace(var.container_image, "${local.acr_login_server}/", "")
}

resource "azurerm_service_plan" "asp" {
  name                = "${var.prefix}-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  os_type  = "Linux"
  sku_name = "B1" # якщо VNet/Private Endpoint буде обмежено — тоді S1/P1v3

  tags = var.tags
}

resource "azurerm_linux_web_app" "api" {
  name                = lower("${var.prefix}-api-${random_string.suffix.result}")
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  service_plan_id = azurerm_service_plan.asp.id
  https_only      = true
  tags            = var.tags

  # 1) робимо webapp не публічним
  public_network_access_enabled = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  # outbound у VNet (для доступу до private ACR/KV/SQL/Files)
  virtual_network_subnet_id = azurerm_subnet.webapp_integration.id

  app_settings = {
    # якщо контейнер слухає не 8080 — постав реальний порт
    WEBSITES_PORT = "8080"

    # потрібно для роботи storage mount через VNet integration
    WEBSITE_CONTENTOVERVNET = "1"

    # якщо з маунтом будуть проблеми — спробуй видалити цей параметр або зробити "true"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"

    SQL_SERVER_FQDN = azurerm_mssql_server.sql.fully_qualified_domain_name
  }

  # 3) Azure Files mount як папка у контейнері
  storage_account {
    name         = "userfiles"
    type         = "AzureFiles"
    account_name = azurerm_storage_account.files.name
    share_name   = azurerm_storage_share.share.name
    access_key   = azurerm_storage_account.files.primary_access_key
    mount_path   = "/mounts/userfiles"
  }

  site_config {
    always_on              = true
    vnet_route_all_enabled = true

    application_stack {
      docker_image_name   = local.docker_image_name
      docker_registry_url = local.docker_registry_url
    }

    # Pull з ACR через Managed Identity
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.app.client_id
  }

  depends_on = [
    azurerm_role_assignment.acr_pull
  ]
}



