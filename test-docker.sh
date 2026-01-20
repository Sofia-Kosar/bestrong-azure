#!/bin/bash
# Скрипт для тестування Docker та CI/CD

set -e  # Вийти при помилці

echo "======================================"
echo "🐳 ТЕСТ 1: Перевірка Docker"
echo "======================================"
docker --version
docker-compose --version
echo "✅ Docker встановлено"
echo ""

echo "======================================"
echo "🔨 ТЕСТ 2: Збірка Docker образу"
echo "======================================"
docker build -t bestrong-test:local .
echo "✅ Образ зібрано успішно"
echo ""

echo "======================================"
echo "📦 ТЕСТ 3: Перевірка розміру образу"
echo "======================================"
docker images bestrong-test:local
echo ""

echo "======================================"
echo "🚀 ТЕСТ 4: Запуск контейнера"
echo "======================================"
docker run -d --name bestrong-test-container \
  -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Development \
  -e "ConnectionStrings__MovieContext=Data Source=/tmp/app.db" \
  bestrong-test:local

echo "⏳ Чекаємо 10 секунд поки app стартує..."
sleep 10

echo ""
echo "======================================"
echo "📊 ТЕСТ 5: Перевірка логів"
echo "======================================"
docker logs bestrong-test-container

echo ""
echo "======================================"
echo "🌐 ТЕСТ 6: Перевірка HTTP endpoint"
echo "======================================"
echo "Пробуємо з'єднатися з API..."

# Retry logic для API
for i in {1..30}; do
  if curl -f -s http://localhost:8080/api/movies > /dev/null; then
    echo "✅ API відповідає!"
    curl -s http://localhost:8080/api/movies | head -20
    break
  else
    if [ $i -eq 30 ]; then
      echo "❌ API не відповідає після 30 спроб"
      docker logs bestrong-test-container --tail 50
      exit 1
    fi
    echo "Спроба $i/30..."
    sleep 2
  fi
done

echo ""
echo "======================================"
echo "🧹 ТЕСТ 7: Очистка"
echo "======================================"
docker stop bestrong-test-container
docker rm bestrong-test-container
docker rmi bestrong-test:local

echo ""
echo "======================================"
echo "✅ ВСІ ТЕСТИ ПРОЙДЕНО УСПІШНО!"
echo "======================================"
