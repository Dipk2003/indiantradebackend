@echo off
echo ================================================
echo Testing iTech Chatbot Functionality
echo ================================================

echo.
echo 1. Testing NON_LOGGED user greeting:
curl -s -X POST "http://localhost:8080/api/chatbot/support/chat" -H "Content-Type: application/json" -d "{\"message\": \"hello\", \"sessionId\": \"test-1\", \"userRole\": \"NON_LOGGED\"}" | jq -r .response
echo.

echo 2. Testing VENDOR user greeting:
curl -s -X POST "http://localhost:8080/api/chatbot/support/chat" -H "Content-Type: application/json" -d "{\"message\": \"hello\", \"sessionId\": \"test-2\", \"userRole\": \"VENDOR\", \"userId\": 1}" | jq -r .response
echo.

echo 3. Testing BUYER user greeting:
curl -s -X POST "http://localhost:8080/api/chatbot/support/chat" -H "Content-Type: application/json" -d "{\"message\": \"hello\", \"sessionId\": \"test-3\", \"userRole\": \"BUYER\", \"userId\": 2}" | jq -r .response
echo.

echo 4. Testing NON_LOGGED product query:
curl -s -X POST "http://localhost:8080/api/chatbot/support/chat" -H "Content-Type: application/json" -d "{\"message\": \"I need laptops\", \"sessionId\": \"test-4\", \"userRole\": \"NON_LOGGED\"}" | jq -r .response
echo.

echo 5. Testing platform knowledge:
curl -s -X POST "http://localhost:8080/api/chatbot/support/chat" -H "Content-Type: application/json" -d "{\"message\": \"what is iTech?\", \"sessionId\": \"test-5\", \"userRole\": \"NON_LOGGED\"}" | jq -r .response
echo.

echo ================================================
echo Chatbot testing completed!
echo ================================================
