@echo off
REM =============================================================================
REM iTech Backend - Simple Build Script (Batch)
REM =============================================================================

setlocal enabledelayedexpansion

set PROJECT_DIR=D:\itech-backend\itech-backend
set TARGET=%1
set PROFILE=%2

if "%TARGET%"=="" set TARGET=help
if "%PROFILE%"=="" set PROFILE=development

cd /d "%PROJECT_DIR%"

echo.
echo =============================================================================
echo  iTech Backend Build System
echo =============================================================================
echo Target: %TARGET%
echo Profile: %PROFILE%
echo Directory: %CD%
echo.

REM Check if Maven is available
mvn --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Maven not found in PATH
    pause
    exit /b 1
)

goto %TARGET%

:clean
echo → Cleaning project...
mvn clean
if errorlevel 1 (
    echo ERROR: Clean failed
    pause
    exit /b 1
)
echo ✓ SUCCESS: Project cleaned
goto end

:compile
echo → Compiling source code...
mvn compile
if errorlevel 1 (
    echo ERROR: Compilation failed
    pause
    exit /b 1
)
echo ✓ SUCCESS: Compilation completed
goto end

:test
echo → Running tests...
mvn test -Dspring.profiles.active=test
if errorlevel 1 (
    echo ERROR: Tests failed
    pause
    exit /b 1
)
echo ✓ SUCCESS: All tests passed
goto end

:package
echo → Creating JAR package...
mvn package -DskipTests
if errorlevel 1 (
    echo ERROR: Packaging failed
    pause
    exit /b 1
)
echo ✓ SUCCESS: JAR package created
goto end

:run
echo → Starting Spring Boot application...
echo Profile: %PROFILE%
mvn spring-boot:run -Dspring-boot.run.profiles=%PROFILE%
goto end

:docker-run
echo → Starting with Docker Compose...
docker-compose up --build
goto end

:help
echo.
echo Usage: build.bat [target] [profile]
echo.
echo Targets:
echo   clean     - Clean all build artifacts
echo   compile   - Compile source code only  
echo   test      - Run tests only
echo   package   - Create JAR package (skips tests)
echo   run       - Run application locally
echo   docker-run - Run with Docker Compose
echo   help      - Show this help message
echo.
echo Profiles:
echo   development - Development profile (default)
echo   production  - Production profile
echo   test        - Test profile
echo.
echo Examples:
echo   build.bat package
echo   build.bat run development
echo   build.bat docker-run
echo.
goto end

:end
echo.
if not "%TARGET%"=="help" (
    echo Build completed for target: %TARGET%
)
if not "%TARGET%"=="run" if not "%TARGET%"=="docker-run" if not "%TARGET%"=="help" pause
