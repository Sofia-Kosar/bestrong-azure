# BeStrong — Azure Infrastructure with Terraform + Azure DevOps CI/CD

Цей репозиторій містить Terraform-код для розгортання базової Azure-інфраструктури стартапу **BeStrong** та CI/CD пайплайн (Azure DevOps), який автоматизує перевірку і деплой інфраструктури за trunk-based підходом.

---

## Архітектура (коротко)

Інфраструктура побудована як приватне середовище в Azure з керованими сервісами (без VM):

- **Azure Container Apps (ACA)** — запуск бекенду в контейнері (managed сервіс).  
  Використовується **System Assigned Managed Identity** для доступу до інших ресурсів без паролів.
- **Log Analytics Workspace** — централізовані логи/метрики/діагностика для Container Apps.
- **Azure Container Registry (ACR)** — приватний реєстр Docker-образів. Доступ на pull надається лише застосунку (через роль `AcrPull` для Managed Identity).
- **Azure Key Vault** — зберігання секретів (паролі/токени). Доступ дозволений тільки для Managed Identity застосунку.
- **Virtual Network + Subnets** — “приватна територія” (ізоляція ресурсів у VNet).
- **Azure SQL (SQL Server compatible)** — реляційна база даних для транзакційних даних (планується/використовується приватний доступ через мережу).
- **Azure Storage + Azure Files Share** — сховище для файлів користувачів у форматі “папки”.
- **Terraform remote state** — state зберігається в Azure Storage (не локально).

---

## Структура репозиторію

- `bootstrap-state/` — створює ресурси для remote backend Terraform (Storage Account + container для tfstate).
- `infra/` — основна інфраструктура BeStrong (мережа, ACA, ACR, Key Vault, SQL, storage, monitoring тощо).
- `azure-pipelines.yml` — Azure DevOps pipeline (YAML) для CI/CD.

---

## Remote State (Terraform Backend)

Terraform state зберігається в Azure Storage (remote backend).  
Спочатку створюється backend через `bootstrap-state/`, а далі основна інфраструктура в `infra/` використовує цей backend у `backend.tf`.

---

## CI/CD (Azure DevOps, Trunk Based)

Використано trunk-based flow:
- основна гілка: **`master`**
- робота через короткі гілки `feature/*` → Pull Request → merge в `master`

Пайплайн працює так:
- **PR в `master`**: `terraform init` → `terraform validate` → `terraform plan`
- **merge/push у `master`**: `terraform init` → `terraform validate` → `terraform apply`

Пайплайн запускається на **self-hosted agent** (актуально для private repo без Microsoft-hosted parallel jobs).

---

## Параметри/секрети

Чутливі значення не зберігаються в коді. Використано змінні середовища Terraform через Azure DevOps Variables:

- `TF_VAR_prefix`
- `TF_VAR_location`
- `TF_VAR_container_image`
- `TF_VAR_sql_admin_password` (**secret**)

---

## Демонстрація (відео)

▶️ Відео з демонстрацією роботи Terraform та CI/CD:  
https://drive.google.com/drive/folders/1Nlk66kXhcFD204rej84FNiBFT9DJ4y09?usp=sharing

> Примітка: посилання буде замінено на фінальне після завантаження відео.

---

## Автор

Sofiia Kosar
