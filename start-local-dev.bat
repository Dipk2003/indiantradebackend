@echo off
echo ================================================
echo iTech Local Development Startup
echo ================================================
echo.
echo This script will start both frontend and backend for local development
echo.

REM Check if we're in the right directory
if not exist "src\main\java" (
    echo ERROR: Please run this script from the backend root directory
    echo Expected: D:\itech-backend\itech-backend
    pause
    exit /b 1
)

echo Starting local development environment...
echo.

echo 1. Setting up local MySQL database...
echo Please make sure MySQL is running and execute the database_schema_mysql.sql script in MySQL Workbench
echo.

REM Build backend first
echo 2. Building backend (Spring Boot)...
call mvn clean install -DskipTests
if %errorlevel% neq 0 (
    echo ERROR: Backend build failed!
    pause
    exit /b 1
)

echo.
echo 3. Starting backend server on port 8080...
start "Backend Server" cmd /k "mvn spring-boot:run -Dspring-boot.run.profiles=local"

echo.
echo Waiting 10 seconds for backend to start...
timeout /t 10 /nobreak > nul

echo 4. Starting frontend server on port 3000...
cd "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main"
start "Frontend Server" cmd /k "npm run dev"

echo.
echo ================================================
echo LOCAL DEVELOPMENT SERVERS STARTED!
echo ================================================
echo.
echo Backend API: http://localhost:8080
echo Frontend:    http://localhost:3000
echo Health Check: http://localhost:8080/actuator/health
echo.
echo Both servers are running in separate windows.
echo Close those windows to stop the servers.
echo.

pause
