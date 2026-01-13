#!/usr/bin/env bash
set -e

mkdir -p /app/data
chmod 777 /app/data || true
touch /app/data/App.db || true
chmod 666 /app/data/App.db || true

if [ -f /app/migrate ]; then
  echo "Running migrations..."
  /app/migrate
fi

exec dotnet DotNetCrudWebApi.dll
