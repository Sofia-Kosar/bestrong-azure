# 🔑 GitHub Secrets - Повна інструкція

## ОБОВ'ЯЗКОВІ SECRETS ДЛЯ РОБОТИ CI/CD

Всі ці secrets **КРИТИЧНО ВАЖЛИВІ**! Без них workflow НЕ СПРАЦЮЄ!

---

## 📍 Де додати secrets:

```
https://github.com/Sofia-Kosar/bestrong-azure/settings/secrets/actions
```

1. Натисніть **"New repository secret"**
2. Введіть **Name** (точно як нижче!)
3. Введіть **Value**
4. Натисніть **"Add secret"**
5. Повторіть для кожного secret

---

## 🔐 СПИСОК ВСІХ НЕОБХІДНИХ SECRETS:

### 1. Azure Service Principal (для Terraform)

| Name | Value | Де взяти |
|------|-------|----------|
| `ARM_CLIENT_ID` | `04b07795-8ddb-461a-bbee-02f9e1bf7b46` | Azure AD App Registration |
| `ARM_CLIENT_SECRET` | `<ваш секрет>` | Azure AD App Registration → Certificates & secrets |
| `ARM_TENANT_ID` | `919b3a1c-24ee-4ce9-84cc-fc7813cb864c` | Azure AD |
| `ARM_SUBSCRIPTION_ID` | `d04f9414-d9f2-45a9-921f-3e63632fde59` | Azure Subscription |

### 2. Azure Container Registry (для Docker push)

| Name | Value |
|------|-------|
| `ACR_LOGIN_SERVER` | `bestrongacrqi77nn.azurecr.io` |
| `ACR_USERNAME` | `bestrongacrqi77nn` |
| `ACR_PASSWORD` | `<отримайте через: az acr credential show --name bestrongacrqi77nn>` |

### 3. Terraform Variables

| Name | Value | Пояснення |
|------|-------|-----------|
| `TF_VAR_prefix` | `bestrong` | Префікс для ресурсів |
| `TF_VAR_location` | `francecentral` | Azure region |
| `TF_VAR_sql_admin_password` | `<ваш пароль>` | SQL Server admin password (мінімум 8 символів, має містити цифри, букви, спецсимволи) |

---

## ✅ Як перевірити що все правильно:

### 1. Перейдіть на сторінку secrets:
```
https://github.com/Sofia-Kosar/bestrong-azure/settings/secrets/actions
```

### 2. Має бути 10 secrets:

- [x] ARM_CLIENT_ID
- [x] ARM_CLIENT_SECRET
- [x] ARM_TENANT_ID
- [x] ARM_SUBSCRIPTION_ID
- [ ] ACR_LOGIN_SERVER ⚠️ **ВАЖЛИВО!**
- [ ] ACR_USERNAME ⚠️ **ВАЖЛИВО!**
- [ ] ACR_PASSWORD ⚠️ **ВАЖЛИВО!**
- [x] TF_VAR_prefix
- [x] TF_VAR_location
- [x] TF_VAR_sql_admin_password

### 3. Особлива увага на ACR secrets!

**БЕЗ ЦИХ 3 SECRETS WORKFLOW НЕ СПРАЦЮЄ:**
- `ACR_LOGIN_SERVER` - використовується в Terraform для docker_image
- `ACR_USERNAME` - для Docker login
- `ACR_PASSWORD` - для Docker login

---

## 🚀 Після додавання всіх secrets:

1. **Перезапустіть workflow:**
   - Перейдіть на https://github.com/Sofia-Kosar/bestrong-azure/actions
   - Знайдіть останній failed run
   - Натисніть "Re-run all jobs"

2. **Або зробіть новий push:**
   ```bash
   echo "test" >> test.txt
   git add test.txt
   git commit -m "chore: trigger after adding secrets"
   git push
   ```

---

## 📊 Що станеться після додавання secrets:

```
✅ Terraform отримає container_image = bestrongacrqi77nn.azurecr.io/dotnetcrudwebapi:latest
✅ Docker зможе login до ACR
✅ Docker зможе push образ
✅ Terraform plan пройде успішно
✅ Всі перевірки зелені!
```

---

## ⚠️ Типові помилки:

### ❌ Помилка: "docker_image_name to not be an empty string"
**Причина:** `ACR_LOGIN_SERVER` не встановлено

**Рішення:** Додайте `ACR_LOGIN_SERVER` = `bestrongacrqi77nn.azurecr.io`

### ❌ Помилка: "unauthorized: authentication required"
**Причина:** `ACR_USERNAME` або `ACR_PASSWORD` не встановлено або невірні

**Рішення:** Додайте правильні ACR credentials

### ❌ Помилка: "denied: client with IP is not allowed"
**Причина:** ACR firewall блокує (вже виправлено, але якщо знову виникне)

**Рішення:** Перевірте що `public_network_access_enabled = true` в acr.tf

---

## 🎯 ШВИДКИЙ ЧЕКЛИСТ:

Перед запуском workflow переконайтесь:

- [ ] Відкрили https://github.com/Sofia-Kosar/bestrong-azure/settings/secrets/actions
- [ ] Додали `ACR_LOGIN_SERVER` = `bestrongacrqi77nn.azurecr.io`
- [ ] Додали `ACR_USERNAME` = `bestrongacrqi77nn`
- [ ] Додали `ACR_PASSWORD` (отримайте через `az acr credential show --name bestrongacrqi77nn`)
- [ ] Перевірили що всі інші secrets на місці
- [ ] Перезапустили workflow

**Після цього все 100% спрацює!** 🚀
