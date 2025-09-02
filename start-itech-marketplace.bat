@echo off
echo Starting iTech B2B Marketplace...
echo.
echo Starting Backend...
start "iTech Backend" cmd /k "cd /d "D:\itech-backend\itech-backend" && mvn spring-boot:run -Dspring-boot.run.profiles=development"

echo Waiting for backend to start...
timeout /t 20 /nobreak > nul

echo Starting Frontend...
start "iTech Frontend" cmd /k "cd /d "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main" && npm run dev"

echo.
echo ================================
echo iTech B2B Marketplace Started!
echo ================================
echo Backend: http://localhost:8080
echo Frontend: http://localhost:3000
echo.
echo Press any key to open the application in browser...
pause > nul
start http://localhost:3000
