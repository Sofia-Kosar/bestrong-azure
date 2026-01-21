

# 📋 Чек-лист перевірки CI/CD та Docker

## ✅ Локальні тести Docker

### 1. Швидкий тест збірки
```bash
# Запустити тестовий скрипт
bash test-docker.sh
```

### 2. Тест через Docker Compose
```bash
# Запустити
docker-compose up --build

# В іншому терміналі:
curl http://localhost:8080/api/movies

# Зупинити
docker-compose down
```

### 3. Ручна перевірка Dockerfile
```bash
# Перевірити синтаксис
docker build --no-cache -t test .

# Перевірити layers
docker history test:latest

# Перевірити що міграції включені
docker run --rm test:latest ls -la /app/migrate
```

---

## ✅ Перевірка GitHub Actions Workflows

### 1. Перевірка синтаксису YAML
```bash
# Якщо встановлено yamllint
yamllint .github/workflows/*.yml

# Або онлайн: https://www.yamllint.com/
```

### 2. Локальна перевірка workflows (з act)
```bash
# Встановити act (https://github.com/nektos/act)
# brew install act  # macOS
# choco install act-cli  # Windows

# Запустити PR workflow локально
act pull_request -W .github/workflows/terraform-pr.yml

# Запустити push workflow (dry run)
act push -W .github/workflows/terraform-apply.yml --dry-run
```

### 3. Перевірка GitHub Secrets
Переконайтесь що налаштовані всі секрети в GitHub:

```
Settings → Secrets and variables → Actions → Repository secrets
```

**Необхідні секрети:**
- ✅ `ARM_CLIENT_ID`
- ✅ `ARM_CLIENT_SECRET`
- ✅ `ARM_TENANT_ID`
- ✅ `ARM_SUBSCRIPTION_ID`
- ✅ `ACR_LOGIN_SERVER`
- ✅ `ACR_USERNAME`
- ✅ `ACR_PASSWORD`
- ✅ `TF_VAR_prefix`
- ✅ `TF_VAR_location`
- ✅ `TF_VAR_sql_admin_password`

### 4. Тест Pull Request workflow
```bash
# Створити feature branch
git checkout -b test/ci-cd-verification

# Зробити невеликі зміни
echo "# Test" >> test.txt
git add test.txt
git commit -m "test: verify CI/CD pipeline"

# Push і створити PR
git push origin test/ci-cd-verification
```

**Що перевірити в GitHub:**
1. Перейти на `Actions` tab
2. Знайти workflow run для вашого PR
3. Перевірити що всі jobs зелені:
   - ✅ `docker-build` (Docker build + smoke test)
   - ✅ `terraform-plan` (fmt/validate/plan)

### 5. Тест Main Branch workflow (Deploy)
```bash
# Merge PR в master
# Або push напряму в master

# В GitHub Actions перевірити:
# 1. Build & Push Docker image to ACR ✅
# 2. Terraform apply (deploy image) ✅
```

---

## ✅ Перевірка розгорнутої інфраструктури

### 1. Перевірка через Azure Portal
```
1. Відкрити https://portal.azure.com
2. Знайти Resource Group: bestrong-rg
3. Перевірити ресурси:
   ✅ App Service (bestrong-api-xxx)
   ✅ App Service Plan
   ✅ Container Registry
   ✅ Key Vault
   ✅ SQL Database
   ✅ Storage Account
   ✅ Virtual Network
   ✅ Private Endpoints
   ✅ Log Analytics Workspace
   ✅ Application Insights
```

### 2. Перевірка через Azure CLI
```bash
# Login
az login

# Перевірити Resource Group
az group show --name bestrong-rg

# Перевірити App Service
az webapp show --name bestrong-api-qi77nn --resource-group bestrong-rg

# Перевірити що App Service запущено
az webapp show --name bestrong-api-qi77nn --resource-group bestrong-rg --query "state"

# Перевірити образ в ACR
az acr repository list --name bestrongacrqi77nn

# Перевірити tags
az acr repository show-tags --name bestrongacrqi77nn --repository dotnetcrudwebapi
```

### 3. Перевірка логів App Service
```bash
# Stream логи
az webapp log tail --name bestrong-api-qi77nn --resource-group bestrong-rg

# Або download останні логи
az webapp log download --name bestrong-api-qi77nn --resource-group bestrong-rg --log-file app-logs.zip
```

### 4. Перевірка Application Insights
```bash
# Відкрити в Portal
https://portal.azure.com → Application Insights → bestrong-appi

# Перевірити:
- Live Metrics (реал-тайм метрики)
- Failures (помилки)
- Performance (продуктивність)
- Logs (детальні логи)
```

### 5. Перевірка приватних endpoints
```bash
# Перевірити що ресурси мають private endpoints
az network private-endpoint list --resource-group bestrong-rg --output table

# Перевірити DNS zones
az network private-dns zone list --resource-group bestrong-rg --output table
```

---

## ✅ End-to-End тест

### Сценарій: Зміна коду → Deploy → Перевірка

```bash
# 1. Зробити зміну в коді
echo "// Test change" >> DotNet-8-Crud-Web-API-Example/DotNetCrudWebApi/Program.cs

# 2. Commit і push
git add .
git commit -m "test: end-to-end CI/CD test"
git push origin master

# 3. Спостерігати за GitHub Actions
# https://github.com/YOUR_USERNAME/YOUR_REPO/actions

# 4. Після успішного deploy - перевірити логи
az webapp log tail --name bestrong-api-qi77nn --resource-group bestrong-rg

# 5. Перевірити що новий образ deploy'нувся
az webapp config container show --name bestrong-api-qi77nn --resource-group bestrong-rg
```

---

## 🚨 Troubleshooting

### Якщо Docker не збирається локально:
```bash
# Очистити Docker кеш
docker system prune -a

# Збудувати без кешу
docker build --no-cache -t test .

# Перевірити логи збірки
docker build --progress=plain -t test . 2>&1 | tee build.log
```

### Якщо GitHub Actions падає:
1. Перевірити Secrets налаштовані
2. Перевірити YAML syntax
3. Подивитись детальні логи в Actions tab
4. Перевірити що Service Principal має права

### Якщо App Service не стартує:
```bash
# Перевірити логи
az webapp log tail --name bestrong-api-qi77nn --resource-group bestrong-rg

# Перевірити конфігурацію
az webapp config show --name bestrong-api-qi77nn --resource-group bestrong-rg

# Restart
az webapp restart --name bestrong-api-qi77nn --resource-group bestrong-rg
```

---

## 📊 Metrics to Monitor

### CI/CD Pipeline:
- ⏱️ Build time (має бути < 10 хв)
- ✅ Success rate (має бути > 95%)
- 🔄 Deployment frequency
- ⚡ Time to deploy (commit → production)

### Application:
- 🚀 Startup time
- 💾 Memory usage
- 📈 Request rate
- ❌ Error rate
- ⏲️ Response time

---

## ✅ Фінальний чек-лист

- [ ] Docker образ збирається локально
- [ ] Docker Compose працює
- [ ] API відповідає на localhost:8080
- [ ] GitHub workflows валідні
- [ ] Всі GitHub Secrets налаштовані
- [ ] PR workflow запускається і проходить
- [ ] Master workflow deploy'ить
- [ ] Образ пушиться в ACR
- [ ] Terraform apply проходить
- [ ] App Service запущено
- [ ] Private endpoints працюють
- [ ] Application Insights отримує дані
- [ ] Логи доступні
- [ ] API доступне через App Service

**Якщо всі пункти ✅ - вітаю, CI/CD працює ідеально!** 🎉
