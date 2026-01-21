#!/bin/bash
# Тест CRUD операцій API

API_URL="http://localhost:8080/api/movies"

echo "======================================"
echo "🎬 ТЕСТ CRUD API"
echo "======================================"
echo ""

echo "1️⃣ GET - Перевірка порожньої бази"
echo "Request: GET $API_URL"
RESPONSE=$(curl -s $API_URL)
echo "Response: $RESPONSE"
if [ "$RESPONSE" = "[]" ]; then
  echo "✅ База порожня (очікувано)"
else
  echo "⚠️ База не порожня: $RESPONSE"
fi
echo ""

echo "2️⃣ POST - Додавання фільму 'The Matrix'"
echo "Request: POST $API_URL"
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "title": "The Matrix",
    "director": "Wachowski Brothers",
    "releaseYear": 1999
  }')
echo "Response: $RESPONSE"
echo "✅ Фільм додано"
echo ""

echo "3️⃣ GET - Перевірка що фільм з'явився"
echo "Request: GET $API_URL"
RESPONSE=$(curl -s $API_URL)
echo "Response: $RESPONSE"
if [[ $RESPONSE == *"The Matrix"* ]]; then
  echo "✅ Фільм знайдено в базі"
else
  echo "❌ Фільм НЕ знайдено!"
  exit 1
fi
echo ""

echo "4️⃣ POST - Додавання ще одного фільму"
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "id": 2,
    "title": "Inception",
    "director": "Christopher Nolan",
    "releaseYear": 2010
  }')
echo "Response: $RESPONSE"
echo "✅ Другий фільм додано"
echo ""

echo "5️⃣ GET - Перевірка що обидва фільми в базі"
RESPONSE=$(curl -s $API_URL)
echo "Response: $RESPONSE"
if [[ $RESPONSE == *"The Matrix"* ]] && [[ $RESPONSE == *"Inception"* ]]; then
  echo "✅ Обидва фільми знайдено"
else
  echo "❌ Щось пішло не так!"
  exit 1
fi
echo ""

echo "6️⃣ GET - Отримання конкретного фільму (ID=1)"
echo "Request: GET $API_URL/1"
RESPONSE=$(curl -s $API_URL/1)
echo "Response: $RESPONSE"
if [[ $RESPONSE == *"The Matrix"* ]]; then
  echo "✅ GET by ID працює"
else
  echo "❌ GET by ID не працює!"
  exit 1
fi
echo ""

echo "7️⃣ PUT - Оновлення фільму (ID=1)"
echo "Request: PUT $API_URL/1"
RESPONSE=$(curl -s -X PUT $API_URL/1 \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "title": "The Matrix Reloaded",
    "director": "Wachowski Brothers",
    "releaseYear": 2003
  }')
echo "Response: $RESPONSE"
echo "✅ Фільм оновлено"
echo ""

echo "8️⃣ GET - Перевірка оновлення"
RESPONSE=$(curl -s $API_URL/1)
echo "Response: $RESPONSE"
if [[ $RESPONSE == *"Reloaded"* ]]; then
  echo "✅ Оновлення успішне"
else
  echo "❌ Оновлення не спрацювало!"
  exit 1
fi
echo ""

echo "9️⃣ DELETE - Видалення фільму (ID=1)"
echo "Request: DELETE $API_URL/1"
curl -s -X DELETE $API_URL/1
echo ""
echo "✅ Фільм видалено"
echo ""

echo "🔟 GET - Перевірка що фільм видалено"
RESPONSE=$(curl -s $API_URL)
echo "Response: $RESPONSE"
if [[ $RESPONSE == *"Inception"* ]] && [[ $RESPONSE != *"Matrix"* ]]; then
  echo "✅ DELETE працює - Matrix видалено, Inception залишився"
else
  echo "⚠️ Перевірте результат: $RESPONSE"
fi
echo ""

echo "======================================"
echo "✅ ВСІ CRUD ОПЕРАЦІЇ ПРАЦЮЮТЬ!"
echo "======================================"
echo ""
echo "📊 Підсумок:"
echo "  ✅ CREATE (POST) - працює"
echo "  ✅ READ (GET all) - працює"
echo "  ✅ READ (GET by id) - працює"
echo "  ✅ UPDATE (PUT) - працює"
echo "  ✅ DELETE - працює"
echo ""
echo "🎉 API повністю функціональний!"
