# BeStrong — Azure Infrastructure with Terraform + GitHub Actions CI/CD

Цей репозиторій містить Terraform-код для розгортання базової Azure-інфраструктури стартапу **BeStrong** та CI/CD пайплайн (GitHub Actions), який автоматизує перевірку і деплой інфраструктури за trunk-based підходом.

---

## Архітектура (коротко)

Інфраструктура побудована як приватне середовище в Azure з керованими сервісами (без VM):

- **Azure App Service for Containers** — запуск .NET бекенду в контейнері (managed сервіс).  
  Використовується **User Assigned Managed Identity** для доступу до інших ресурсів без паролів.
- **Application Insights + Log Analytics Workspace** — централізовані логи/метрики/діагностика для додатку.
- **Azure Container Registry (ACR)** — приватний реєстр Docker-образів. Доступ на pull надається лише застосунку (через роль `AcrPull` для Managed Identity). Повністю приватний з Private Endpoint.
- **Azure Key Vault** — зберігання секретів (паролі/токени). Доступ дозволений тільки для Managed Identity застосунку. SQL пароль зберігається в Key Vault і підтягується через Key Vault References.
- **Virtual Network + Subnets** — "приватна територія" (ізоляція ресурсів у VNet):
  - Subnet для VNet Integration (App Service)
  - Subnet для Private Endpoints
- **Azure SQL Database (SQL Server compatible)** — реляційна база даних для транзакційних даних. Повністю приватна з Private Endpoint.
- **Azure Storage + Azure Files Share** — сховище для файлів користувачів, змонтоване до App Service як папка. Повністю приватне з Private Endpoint.
- **Private DNS Zones** — DNS резолюція для всіх приватних ендпоінтів (ACR, Key Vault, SQL, Storage, App Service).
- **Terraform remote state** — state зберігається в Azure Storage (не локально).

---

## Структура репозиторію

- `bootstrape-state/` — створює ресурси для remote backend Terraform (Storage Account + container для tfstate).
- `infra/` — основна інфраструктура BeStrong (мережа, App Service, ACR, Key Vault, SQL, storage, monitoring тощо).
- `.github/workflows/` — GitHub Actions workflows (YAML) для CI/CD:
  - `terraform-apply.yml` — Docker build + push + Terraform deploy при push в master
  - `terraform-pr.yml` — Docker build + Terraform validate/plan для Pull Requests
- `DotNet-8-Crud-Web-API-Example/` — .NET 8 CRUD Web API застосунок
- `Dockerfile` — multi-stage Docker образ з EF migrations bundle
- `docker-compose.yml` — локальне тестування
- `entrypoint.sh` — запуск міграцій при старті контейнера

---

## Remote State (Terraform Backend)

Terraform state зберігається в Azure Storage (remote backend).  
Спочатку створюється backend через `bootstrap-state/`, а далі основна інфраструктура в `infra/` використовує цей backend у `backend.tf`.

---

## CI/CD (GitHub Actions, Trunk Based)

Використано trunk-based flow:
- основна гілка: **`master`**
- робота через короткі гілки `feature/*` → Pull Request → merge в `master`

### Pull Request workflow (`terraform-pr.yml`):
- Docker build + smoke test (перевірка що контейнер стартує)
- `terraform fmt -check` → `terraform init` → `terraform validate` → `terraform plan`

### Main branch workflow (`terraform-apply.yml`):
- Docker build + push до ACR з тегом з Git SHA
- `terraform init` → `terraform validate` → `terraform apply` (з новим образом)

Workflows використовують GitHub-hosted runners (ubuntu-latest).

---

## Параметри/секрети

Чутливі значення не зберігаються в коді. Використано GitHub Secrets:

**Azure credentials:**
- `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` — Service Principal для Terraform
- `ACR_LOGIN_SERVER`, `ACR_USERNAME`, `ACR_PASSWORD` — для Docker push до ACR

**Terraform variables:**
- `TF_VAR_prefix` — префікс для ресурсів
- `TF_VAR_location` — Azure region
- `TF_VAR_sql_admin_password` — SQL пароль (зберігається в Key Vault, підтягується через Key Vault Reference)
- `TF_VAR_container_image` — передається автоматично з build job

---

## Демонстрація (відео)

▶️ Відео з демонстрацією роботи Terraform та CI/CD:  
https://drive.google.com/drive/folders/1Nlk66kXhcFD204rej84FNiBFT9DJ4y09?usp=sharing

> Примітка: посилання буде замінено на фінальне після завантаження відео.

---

## Автор

Sofiia Kosar
