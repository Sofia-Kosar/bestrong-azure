# 🔧 Виправлення для GitHub Actions CI/CD

## ❌ Проблеми що були:

### 1. Terraform: Missing `container_image` variable
```
Error: No value for required variable "container_image"
```

### 2. Docker Build: Project file not found  
```
MSBUILD : error MSB1009: Project file does not exist.
```

---

## ✅ Що виправлено:

### 1. Додано `TF_VAR_container_image` в PR workflow
**Файл:** `.github/workflows/terraform-pr.yml`

Додано змінну середовища для terraform plan:
```yaml
TF_VAR_container_image: ${{ secrets.ACR_LOGIN_SERVER }}/dotnetcrudwebapi:latest
```

### 2. Додано діагностику в workflows
**Файли:** 
- `.github/workflows/terraform-apply.yml`
- `.github/workflows/terraform-pr.yml`

Додано крок для перевірки структури файлів перед Docker build:
```yaml
- name: Debug - List files
  run: |
    echo "=== Repository root ==="
    ls -la
    echo "=== DotNet project ==="
    ls -la DotNet-8-Crud-Web-API-Example/DotNetCrudWebApi/
    find . -name "*.csproj" -type f
```

### 3. Додано діагностику в Dockerfile
**Файл:** `Dockerfile`

Додано перевірку файлів перед dotnet restore:
```dockerfile
RUN ls -la && pwd
```

---

## 📝 Наступні кроки:

### 1. Commit і push змін
```bash
git add .
git commit -m "fix: add container_image variable and debug logging for CI/CD"
git push origin feature/ci-cd-docker
```

### 2. Створити Pull Request
- Перейдіть на GitHub
- Створіть PR: `feature/ci-cd-docker` → `master`
- Спостерігайте за GitHub Actions

### 3. Перевірте логи діагностики
У логах GitHub Actions тепер буде розділ "Debug - List files". Перевірте:
- ✅ Чи існує `DotNet-8-Crud-Web-API-Example/DotNetCrudWebApi/`
- ✅ Чи знайдено файл `*.csproj`
- ✅ Чи правильна структура директорій

### 4. Якщо все ще падає
Перевірте логи Dockerfile build step - там буде output від `ls -la && pwd`.

Можливі причини:
1. `.dockerignore` виключає щось важливе
2. GitHub Actions checkout має іншу структуру
3. Потрібно змінити build context або WORKDIR

---

## 🐛 Troubleshooting

### Якщо project file все ще не знайдено:

#### Варіант A: Змінити структуру Dockerfile
```dockerfile
# Замість:
WORKDIR /src/DotNet-8-Crud-Web-API-Example/DotNetCrudWebApi

# Спробувати:
WORKDIR /src
RUN cd DotNet-8-Crud-Web-API-Example/DotNetCrudWebApi && dotnet restore
```

#### Варіант B: Використати повний шлях
```dockerfile
RUN dotnet restore /src/DotNet-8-Crud-Web-API-Example/DotNetCrudWebApi/DotNetCrudWebApi.csproj
```

#### Варіант C: Копіювати тільки потрібну папку
```dockerfile
# Замість COPY . .
COPY DotNet-8-Crud-Web-API-Example ./DotNet-8-Crud-Web-API-Example
```

---

## ✅ Очікуваний результат

Після виправлень:

1. **PR workflow** (`terraform-pr.yml`):
   - ✅ Debug step показує файли
   - ✅ Docker build проходить
   - ✅ Terraform plan виконується (з placeholder image)

2. **Main workflow** (`terraform-apply.yml`):
   - ✅ Debug step показує файли
   - ✅ Docker build і push в ACR
   - ✅ Terraform apply з новим образом

---

## 📊 Перевірка після deploy

```bash
# Перевірити що образ в ACR
az acr repository show-tags \
  --name <your-acr-name> \
  --repository dotnetcrudwebapi

# Перевірити App Service
az webapp show \
  --name bestrong-api-qi77nn \
  --resource-group bestrong-rg \
  --query "state"

# Логи
az webapp log tail \
  --name bestrong-api-qi77nn \
  --resource-group bestrong-rg
```

---

**Commit зміни і створіть PR щоб протестувати виправлення!** 🚀
