# iTech B2B Marketplace - Complete Integration Guide

## 🚀 Overview

This guide will help you set up and run the complete iTech B2B Marketplace application with proper integration between:
- **Backend**: Spring Boot application (Java 21 + Maven)
- **Frontend**: Next.js application (React + TypeScript)
- **Database**: MySQL database with complete schema

## 📋 Prerequisites

Before starting, ensure you have the following installed:

### Required Software
- **Java 21 or higher** - [Download from Oracle](https://www.oracle.com/java/technologies/downloads/)
- **Maven 3.6+** - [Download from Apache](https://maven.apache.org/download.cgi)
- **Node.js 18+** - [Download from Node.js](https://nodejs.org/)
- **MySQL 8.0+** - [Download MySQL](https://dev.mysql.com/downloads/)

### Verification Commands
Run these commands to verify installations:
```bash
java -version     # Should show Java 21+
mvn --version     # Should show Maven 3.6+
node --version    # Should show Node 18+
mysql --version   # Should show MySQL 8.0+
```

## 📁 Project Structure

```
iTech B2B Marketplace/
├── Backend/
│   ├── D:\itech-backend\itech-backend\
│   ├── src/main/java/com/itech/itech_backend/
│   ├── src/main/resources/
│   ├── pom.xml
│   └── startup scripts
│
├── Frontend/
│   ├── C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main\
│   ├── src/
│   ├── package.json
│   └── startup scripts
│
└── Database/
    ├── MySQL Server (localhost:3306)
    └── Database: itech_db
```

## 🛠️ Setup Instructions

### Step 1: Database Setup

1. **Start MySQL Server**
   ```bash
   # Windows: Start MySQL from Services or command line
   mysql -u root -p
   ```

2. **Create Database**
   ```sql
   CREATE DATABASE IF NOT EXISTS itech_db;
   USE itech_db;
   ```

3. **Verify Connection**
   ```bash
   mysql -h localhost -P 3306 -u root -p itech_db
   ```

### Step 2: Backend Setup

1. **Navigate to Backend Directory**
   ```bash
   cd "D:\itech-backend\itech-backend"
   ```

2. **Clean and Compile**
   ```bash
   mvn clean compile
   ```

3. **Run Application**
   ```bash
   mvn spring-boot:run -Dspring-boot.run.profiles=development
   ```

### Step 3: Frontend Setup

1. **Navigate to Frontend Directory**
   ```bash
   cd "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main"
   ```

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Start Development Server**
   ```bash
   npm run dev
   ```

## 🚁 Quick Start Scripts

We've created convenient startup scripts for you:

### Option 1: Use Combined Startup Script
```bash
# Start both backend and frontend together
start-itech-marketplace.bat
```

### Option 2: Start Individually
```bash
# Start backend only
start-backend.bat

# Start frontend only (in a separate terminal)
start-frontend.bat
```

## 🔧 Configuration Details

### Backend Configuration
- **Port**: 8080
- **Profile**: development
- **Database URL**: jdbc:mysql://localhost:3306/itech_db
- **CORS Origins**: http://localhost:3000, http://localhost:3001

### Frontend Configuration
- **Port**: 3000
- **API URL**: http://localhost:8080
- **Environment**: development

### Database Configuration
- **Host**: localhost
- **Port**: 3306
- **Database**: itech_db
- **Username**: root
- **Password**: root

## 🌐 Application URLs

Once running, access the application at:

- **Frontend Application**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Health Check**: http://localhost:8080/health
- **API Documentation**: http://localhost:8080/swagger-ui.html (if enabled)
- **Actuator Health**: http://localhost:8080/actuator/health

## 👥 User Roles and Access

The application supports multiple user types:

### 1. Admin Portal
- **URL**: http://localhost:3000/admin
- **Features**: User management, analytics, system configuration
- **Sample Account**: admin@itech.com / admin123

### 2. Vendor Portal
- **URL**: http://localhost:3000/vendor
- **Features**: Product management, order tracking, analytics
- **Sample Account**: vendor@itech.com / vendor123

### 3. Buyer Portal
- **URL**: http://localhost:3000/buyer
- **Features**: Product browsing, ordering, wishlist
- **Sample Account**: buyer@itech.com / buyer123

### 4. Employee Portal
- **URL**: http://localhost:3000/employee
- **Features**: Data entry, category management
- **Sample Account**: employee@itech.com / employee123

## 🧪 Testing Integration

Run the integration test script:
```bash
node test-integration.js
```

This will test:
- Database connectivity
- Backend API endpoints
- Frontend server
- CORS configuration
- Authentication systems
- End-to-end communication

## 🔍 Key Features

### ✅ Authentication & Authorization
- JWT-based authentication
- Role-based access control
- Session management
- Password reset functionality

### ✅ Business Modules
- **User Management**: Registration, profile management
- **Product Catalog**: Categories, subcategories, products
- **Order Management**: Cart, checkout, order tracking
- **Vendor Management**: Registration, verification, analytics
- **Support System**: Chat, tickets, knowledge base
- **Analytics**: Business intelligence, reporting

### ✅ Technical Features
- **API Integration**: RESTful APIs with proper error handling
- **File Upload**: Document and image management
- **Real-time Features**: WebSocket support for chat
- **Payment Integration**: Razorpay integration
- **Email System**: Automated notifications
- **Database Migrations**: Flyway for schema management

## 🚨 Troubleshooting

### Common Issues and Solutions

#### 1. Backend Won't Start
- **Check Java Version**: Ensure Java 21 is installed
- **Verify Database**: Make sure MySQL is running and accessible
- **Port Conflicts**: Ensure port 8080 is not in use
- **Maven Issues**: Run `mvn clean compile` first

#### 2. Frontend Won't Start
- **Check Node Version**: Ensure Node.js 18+ is installed
- **Dependencies**: Run `npm install` to update dependencies
- **Port Conflicts**: Ensure port 3000 is not in use
- **Build Issues**: Clear cache with `npm run clean`

#### 3. Database Connection Issues
- **MySQL Service**: Ensure MySQL service is running
- **Credentials**: Verify username/password in application.properties
- **Firewall**: Check if firewall is blocking port 3306
- **Database Exists**: Ensure `itech_db` database exists

#### 4. CORS Issues
- **Configuration**: Check CORS settings in SecurityConfig
- **Origins**: Verify allowed origins include frontend URL
- **Headers**: Ensure proper headers are configured

#### 5. API Communication Issues
- **URLs**: Verify API URLs in frontend configuration
- **Network**: Check if both services are accessible
- **Authentication**: Ensure JWT tokens are properly handled

### Debug Commands

```bash
# Check running processes
netstat -an | findstr "8080"
netstat -an | findstr "3000"

# Test API endpoints
curl http://localhost:8080/health
curl http://localhost:8080/actuator/health

# Check frontend
curl http://localhost:3000

# Database connectivity
mysql -h localhost -P 3306 -u root -p -e "SELECT 1;"
```

## 📊 Monitoring and Logs

### Backend Logs
- **Location**: Console output or configured log files
- **Log Level**: DEBUG (development), INFO (production)
- **Key Components**: Database, Security, API calls

### Frontend Logs
- **Browser Console**: F12 → Console tab
- **Network Tab**: Monitor API calls and responses
- **Application Tab**: Check localStorage and session data

### Database Monitoring
```sql
-- Check active connections
SHOW PROCESSLIST;

-- Monitor database size
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'itech_db'
GROUP BY table_schema;
```

## 🔧 Development Tips

### Backend Development
- **Hot Reload**: Use Spring Boot DevTools for auto-restart
- **Profiles**: Switch between dev/prod profiles
- **API Testing**: Use Postman or curl for API testing

### Frontend Development
- **Fast Refresh**: Next.js provides hot module replacement
- **Environment Variables**: Use .env.local for development settings
- **Component Development**: Use React DevTools browser extension

### Database Development
- **Migrations**: Use Flyway for version-controlled schema changes
- **Backup**: Regular backup of development database
- **Performance**: Monitor slow queries and optimize as needed

## 📈 Performance Optimization

### Backend
- **Connection Pooling**: HikariCP configured for optimal performance
- **Caching**: Redis integration for session and data caching
- **JVM Tuning**: Optimize memory settings for production

### Frontend
- **Code Splitting**: Automatic with Next.js
- **Image Optimization**: Use Next.js Image component
- **Bundle Analysis**: Use webpack-bundle-analyzer

### Database
- **Indexing**: Proper indexes on frequently queried columns
- **Query Optimization**: Use EXPLAIN to analyze query performance
- **Connection Limits**: Configure appropriate connection pool sizes

## 📱 Production Deployment

### Environment Configuration
1. **Backend**: Use production profile with environment variables
2. **Frontend**: Build with `npm run build` and deploy static files
3. **Database**: Use production-grade MySQL setup with proper security

### Security Considerations
- **HTTPS**: Enable SSL/TLS for all communications
- **Secrets**: Use environment variables for sensitive data
- **CORS**: Restrict allowed origins to production domains
- **Database**: Use encrypted connections and proper user permissions

## 📞 Support and Troubleshooting

### Getting Help
1. **Check Logs**: Review console output for error messages
2. **Run Tests**: Use `node test-integration.js` to identify issues
3. **Documentation**: Refer to this guide and inline code comments
4. **Community**: Check Spring Boot and Next.js documentation

### Reporting Issues
When reporting issues, include:
- Error messages and stack traces
- Configuration files (without sensitive data)
- Steps to reproduce the issue
- System information (OS, Java version, Node version)

## 🎉 Success Verification

Your integration is successful when:
- ✅ Backend starts without errors on port 8080
- ✅ Frontend loads successfully on port 3000
- ✅ Database connection is established
- ✅ API calls work between frontend and backend
- ✅ User authentication functions properly
- ✅ All major features are accessible

## 📚 Additional Resources

- **Spring Boot Documentation**: https://spring.io/projects/spring-boot
- **Next.js Documentation**: https://nextjs.org/docs
- **MySQL Documentation**: https://dev.mysql.com/doc/
- **React Documentation**: https://reactjs.org/docs/getting-started.html

---

## 🏁 Quick Start Summary

1. **Prerequisites**: Install Java 21, Maven, Node.js 18+, MySQL 8+
2. **Database**: Create `itech_db` database in MySQL
3. **Backend**: Run `start-backend.bat` or `mvn spring-boot:run`
4. **Frontend**: Run `start-frontend.bat` or `npm run dev`
5. **Access**: Open http://localhost:3000 in your browser
6. **Test**: Run `node test-integration.js` to verify everything works

**That's it!** Your iTech B2B Marketplace should now be running with full integration between backend, frontend, and database.

For any issues or questions, refer to the troubleshooting section above or check the detailed logs in your terminal windows.
