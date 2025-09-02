@echo off
echo ================================================
echo iTech Backend - Database Schema Deployment
echo ================================================
echo.
echo This script will deploy the complete database schema to your AWS PostgreSQL database.
echo.

REM Check if psql is available
psql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: PostgreSQL client (psql) is not installed or not in PATH.
    echo Please install PostgreSQL client tools first.
    echo Download from: https://www.postgresql.org/download/windows/
    pause
    exit /b 1
)

echo Please provide your AWS PostgreSQL database connection details:
echo.

set /p DB_HOST="Enter database host (e.g., your-db.xxxxx.ap-south-1.rds.amazonaws.com): "
set /p DB_PORT="Enter database port [5432]: "
set /p DB_NAME="Enter database name: "
set /p DB_USER="Enter database username: "

if "%DB_PORT%"=="" set DB_PORT=5432

echo.
echo Connecting to database: %DB_HOST%:%DB_PORT%/%DB_NAME%
echo User: %DB_USER%
echo.
echo WARNING: This will create/modify database tables. Make sure you have a backup!
echo.
set /p CONFIRM="Do you want to continue? (y/N): "

if /i not "%CONFIRM%"=="y" (
    echo Deployment cancelled.
    pause
    exit /b 0
)

echo.
echo Deploying database schema...
echo.

psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f database_schema_initialization.sql

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo SUCCESS: Database schema deployed successfully!
    echo ================================================
    echo.
    echo Your Spring Boot application should now start without errors.
    echo.
    echo Next steps:
    echo 1. Restart your AWS Elastic Beanstalk application
    echo 2. Check the application logs to confirm it starts properly
    echo 3. Test your application endpoints
    echo.
) else (
    echo.
    echo ================================================
    echo ERROR: Database schema deployment failed!
    echo ================================================
    echo.
    echo Please check the error messages above and fix any issues.
    echo Common issues:
    echo 1. Incorrect database credentials
    echo 2. Network connectivity issues
    echo 3. Insufficient database permissions
    echo.
)

pause
