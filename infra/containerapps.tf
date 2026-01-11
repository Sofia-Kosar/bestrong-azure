# resource "azurerm_user_assigned_identity" "app" {
#   name                = "${var.prefix}-app-mi"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   tags                = var.tags
# }

# resource "azurerm_container_app_environment" "env" {
#   name                     = "${var.prefix}-aca-env"
#   location                 = azurerm_resource_group.rg.location
#   resource_group_name      = azurerm_resource_group.rg.name
#   infrastructure_subnet_id = azurerm_subnet.aca_infra.id

#   log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
#   tags                       = var.tags
# }

# resource "azurerm_role_assignment" "acr_pull" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.app.principal_id
# }

# resource "azurerm_role_assignment" "kv_secrets_user" {
#   scope                = azurerm_key_vault.kv.id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = azurerm_user_assigned_identity.app.principal_id
# }

# resource "azurerm_container_app_environment_storage" "files" {
#   name                         = "userfiles"
#   container_app_environment_id = azurerm_container_app_environment.env.id
#   account_name                 = azurerm_storage_account.files.name
#   share_name                   = azurerm_storage_share.share.name
#   access_key                   = azurerm_storage_account.files.primary_access_key
#   access_mode                  = "ReadWrite"
# }

# resource "azurerm_container_app" "backend" {
#   name                         = "${var.prefix}-backend"
#   container_app_environment_id = azurerm_container_app_environment.env.id
#   resource_group_name          = azurerm_resource_group.rg.name
#   revision_mode                = "Single"
#   tags                         = var.tags

#   identity {
#     type         = "UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.app.id]
#   }

#   ingress {
#     external_enabled = false
#     target_port      = 8080
#     transport        = "http"
#     traffic_weight {
#       percentage      = 100
#       latest_revision = true
#     }
#   }

#   registry {
#     server   = azurerm_container_registry.acr.login_server
#     identity = azurerm_user_assigned_identity.app.id
#   }

#   template {
#     min_replicas = 1
#     max_replicas = 3

#     volume {
#       name         = "userfiles"
#       storage_name = azurerm_container_app_environment_storage.files.name
#       storage_type = "AzureFile"
#     }

#     container {
#       name   = "backend"
#       image  = var.container_image
#       cpu    = 0.5
#       memory = "1Gi"

#       env {
#         name  = "APPINSIGHTS_CONNECTION_STRING"
#         value = azurerm_application_insights.appi.connection_string
#       }

#       env {
#         name  = "SQL_SERVER_FQDN"
#         value = azurerm_mssql_server.sql.fully_qualified_domain_name
#       }

#       volume_mounts {
#         name = "userfiles"
#         path = "/mnt/userfiles"
#       }
#     }
#   }
# }
