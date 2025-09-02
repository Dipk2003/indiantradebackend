
# iTech B2B Marketplace - Integration Report

## Configuration Summary
- **Backend URL**: http://localhost:8080
- **Frontend URL**: http://localhost:3000
- **Database**: MySQL on localhost:3306
- **Database Name**: itech_db

## Project Paths
- **Backend**: D:\itech-backend\itech-backend
- **Frontend**: C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main

## Key Features Integrated
✅ Authentication System (JWT-based)
✅ CORS Configuration
✅ Database Connectivity (MySQL)
✅ API Endpoints
✅ File Upload System
✅ Multi-role Support (Admin, Vendor, Buyer, Employee)
✅ Real-time Features (WebSocket)
✅ Analytics and Reporting
✅ Payment Integration (Razorpay)
✅ Support System (Chat, Tickets)

## Available Startup Scripts
- **start-backend.bat**: Starts only the backend server
- **start-frontend.bat**: Starts only the frontend application
- **start-itech-marketplace.bat**: Starts both backend and frontend together

## API Endpoints
- Health Check: http://localhost:8080/health
- Authentication: http://localhost:8080/auth/*
- Admin Panel: http://localhost:8080/api/admin/*
- Vendor Portal: http://localhost:8080/api/vendors/*
- Buyer APIs: http://localhost:8080/api/buyers/*

## Database Schema
The application uses Flyway for database migrations. Schema is automatically created on first run.

## Next Steps
1. Run 'start-itech-marketplace.bat' to start the full application
2. Open http://localhost:3000 in your browser
3. Register as a new user or login with existing credentials
4. Explore different modules based on your role

## Troubleshooting
- Ensure MySQL is running on localhost:3306
- Check that ports 3000 and 8080 are available
- Verify Java 21 is installed for backend
- Verify Node.js 18+ is installed for frontend
