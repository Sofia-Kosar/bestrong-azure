############################################
# App Service for Containers (Linux Web App)
############################################

locals {
  acr_login_server    = azurerm_container_registry.acr.login_server
  registry_host       = split("/", var.container_image)[0]
  docker_registry_url = "https://${local.registry_host}"
  # У application_stack блоці НЕ потрібен префікс DOCKER|
  docker_image_name = var.container_image
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

  public_network_access_enabled = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  virtual_network_subnet_id = azurerm_subnet.webapp_integration.id
  app_settings = {
    WEBSITES_PORT                       = "8080"
    WEBSITE_CONTENTOVERVNET             = "1"
    WEBSITE_PULL_IMAGE_OVER_VNET        = "1"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    SQL_SERVER_FQDN                     = azurerm_mssql_server.sql.fully_qualified_domain_name
    SQL_ADMIN_LOGIN                     = var.sql_admin_login
    # ТИМЧАСОВО: пароль напряму (Key Vault secret закоментовано через RBAC issues)
    SQL_ADMIN_PASSWORD = var.sql_admin_password
    # SQL_ADMIN_PASSWORD                         = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.sql_password.versionless_id})"
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.appi.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
  }


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

    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.app.client_id
  }

  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_role_assignment.kv_secrets_user,
    # azurerm_key_vault_secret.sql_password, # Закоментовано тимчасово
  ]
}
