# План Б: Якщо RBAC все ще не працює

## Проблема
Terraform намагається прочитати існуючий секрет під час refresh, але Service Principal GitHub Actions не має дозволу.

## Рішення 1: Skip Refresh в PR (найпростіше)

Оновити `.github/workflows/terraform-pr.yml`:

```yaml
- name: Terraform plan
  working-directory: infra
  env:
    ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
    ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
    ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
    ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}

    TF_VAR_prefix: ${{ secrets.TF_VAR_prefix }}
    TF_VAR_location: ${{ secrets.TF_VAR_location }}
    TF_VAR_sql_admin_password: ${{ secrets.TF_VAR_sql_admin_password }}
    TF_VAR_container_image: ${{ secrets.ACR_LOGIN_SERVER }}/dotnetcrudwebapi:latest
  run: terraform plan -input=false -refresh=false  # <-- Додати -refresh=false
```

## Рішення 2: Видалити секрет з Azure вручну

```bash
# Видалити існуючий секрет
az keyvault secret delete \
  --vault-name bestrongkvqi77nn \
  --name sql-admin-password

# Terraform створить його знову з правильними permissions
```

## Рішення 3: Надати permissions Service Principal вручну

```bash
# Отримати object ID Service Principal
echo "949b97f9-37aa-4bde-8b55-410510cb35fc"

# Надати role вручну
az role assignment create \
  --role "Key Vault Secrets Officer" \
  --assignee 949b97f9-37aa-4bde-8b55-410510cb35fc \
  --scope /subscriptions/***/resourceGroups/***/providers/Microsoft.KeyVault/vaults/***kvqi77nn

# Почекати 1-2 хвилини для RBAC propagation
# Потім перезапустити workflow
```

## Рішення 4: Не керувати секретом через Terraform

Закоментувати створення секрету в `infra/keyvault.tf`:

```hcl
# Тимчасово закоментовано - створюємо вручну
# resource "azurerm_key_vault_secret" "sql_password" {
#   name         = "sql-admin-password"
#   value        = var.sql_admin_password
#   key_vault_id = azurerm_key_vault.kv.id
#   ...
# }
```

Створити секрет вручну:
```bash
az keyvault secret set \
  --vault-name bestrongkvqi77nn \
  --name sql-admin-password \
  --value "YOUR_SQL_PASSWORD"
```

---

## Що спробувати по черзі:

1. ✅ Спочатку чекаємо - може поточне виправлення (time_sleep + create_before_destroy) спрацює
2. Якщо ні - додати `-refresh=false` в terraform plan (PR workflow)
3. Якщо треба deploy - використати Рішення 2 або 3 вище

**Зачекайте результати поточного PR - можливо вже спрацює!** 🤞
