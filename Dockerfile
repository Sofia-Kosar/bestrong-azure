# ===== Build sffftage =====
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Копіюємо весь контекст (в CI це буде ./bestrong_azure)
COPY . .

# Переходимо в папку проєкту
WORKDIR /src/DotNet-8-Crud-Web-API-Example/DotNetCrudWebApi

# DEBUG: Перевіряємо що файли скопіювались
RUN ls -la && pwd

# Restore залежностей
RUN dotnet restore DotNetCrudWebApi.csproj

# EF tool (потрібно для migrations bundle)
RUN dotnet tool install --global dotnet-ef --version 8.*
ENV PATH="$PATH:/root/.dotnet/tools"

# Створюємо bundle міграцій у publish папку
RUN dotnet ef migrations bundle \
  --project DotNetCrudWebApi.csproj \
  --startup-project DotNetCrudWebApi.csproj \
  -o /app/publish/migrate

# Publish
RUN dotnet publish DotNetCrudWebApi.csproj -c Release -o /app/publish

# ===== Runtime stage =====
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Копіюємо результати publish
COPY --from=build /app/publish .

# Слухаємо 8080 (під App Service)
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
EXPOSE 8080

# Entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
