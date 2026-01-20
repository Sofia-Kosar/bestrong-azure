# 🔧 Фінальне виправлення Key Vault RBAC

## Проблема
Service Principal GitHub Actions не може читати Key Vault secret через RBAC permissions.

## Що вже зроблено:
1. ✅ Purge існуючий secret з Key Vault
2. ✅ Додано `-refresh=false` в terraform plan
3. ✅ Додано `time_sleep` для RBAC propagation
4. ✅ Додано `create_before_destroy` для role assignment

## Якщо все ще не працює - Фінальне рішення:

### Варіант А: Тимчасово закоментувати secret в Terraform

**Файл:** `infra/keyvault.tf`

```hcl
# Тимчасово закоментовано - створимо вручну після успішного deploy
# resource "time_sleep" "wait_for_rbac" {
#   create_duration = "60s"
#   depends_on = [
#     azurerm_role_assignment.kv_admin_current_user
#   ]
# }

# resource "azurerm_key_vault_secret" "sql_password" {
#   name         = "sql-admin-password"
#   value        = var.sql_admin_password
#   key_vault_id = azurerm_key_vault.kv.id
#   depends_on = [
#     azurerm_role_assignment.kv_admin_current_user,
#     time_sleep.wait_for_rbac
#   ]
# }
```

**Також в** `infra/appservice.tf` закоментувати використання:

```hcl
app_settings = {
  WEBSITES_PORT                             = "8080"
  WEBSITE_CONTENTOVERVNET                   = "1"
  WEBSITE_PULL_IMAGE_OVER_VNET              = "1"
  WEBSITES_ENABLE_APP_SERVICE_STORAGE       = "false"
  SQL_SERVER_FQDN                           = azurerm_mssql_server.sql.fully_qualified_domain_name
  SQL_ADMIN_LOGIN                           = var.sql_admin_login
  # SQL_ADMIN_PASSWORD                        = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.sql_password.versionless_id})"
  SQL_ADMIN_PASSWORD                        = var.sql_admin_password  # ТИМЧАСОВО напряму
  APPLICATIONINSIGHTS_CONNECTION_STRING     = azurerm_application_insights.appi.connection_string
  ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
}
```

**Видалити з depends_on:**

```hcl
depends_on = [
  azurerm_role_assignment.acr_pull,
  azurerm_role_assignment.kv_secrets_user,
  # azurerm_key_vault_secret.sql_password,  # Закоментувати
]
```

### Після успішного deploy:

1. Розкоментувати секрет
2. Применити знову
3. Секрет створився з правильними permissions

---

### Варіант Б: Створити секрет вручну

```bash
# Після успішного terraform apply
az keyvault secret set \
  --vault-name bestrongkvqi77nn \
  --name sql-admin-password \
  --value "YOUR_SQL_PASSWORD"

# Оновити App Service app settings
az webapp config appsettings set \
  --name bestrong-api-qi77nn \
  --resource-group bestrong-rg \
  --settings SQL_ADMIN_PASSWORD="@Microsoft.KeyVault(SecretUri=https://bestrongkvqi77nn.vault.azure.net/secrets/sql-admin-password)"
```

---

## Рекомендація

**Спочатку дочекайтесь результату поточного workflow run.**

Якщо все ще падає - використайте **Варіант А** (тимчасово закоментувати).

Це дозволить задеплоїти інфраструктуру, а секрет додамо потім.
