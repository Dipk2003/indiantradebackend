@echo off
echo Starting iTech Backend...
cd "D:\itech-backend\itech-backend"
echo Backend directory: %CD%
echo Starting Spring Boot application...
mvn spring-boot:run -Dspring-boot.run.profiles=development
pause
