# ===== Build stage =====
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY . .

WORKDIR /src/DotNet-8-Crud-Web-API-Example/DotNetCrudWebApi
RUN dotnet restore DotNetCrudWebApi.csproj
RUN dotnet tool install --global dotnet-ef --version 8.*
ENV PATH="$PATH:/root/.dotnet/tools"

# створюємо bundle міграцій у publish папку
RUN dotnet ef migrations bundle \
  --project DotNetCrudWebApi.csproj \
  --startup-project DotNetCrudWebApi.csproj \
  -o /app/publish/migrate

RUN dotnet publish DotNetCrudWebApi.csproj -c Release -o /app/publish

# ===== Runtime stage =====
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://0.0.0.0:8080
EXPOSE 8080

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]

