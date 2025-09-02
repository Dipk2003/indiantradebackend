# iTech Backend Setup Guide

This guide helps you set up the complete backend infrastructure for the iTech Employee Module integration.

## 📋 **What We've Built**

### 1. **Import Management System**
- **Excel Import Service** - Import categories and cities from Excel files
- **Import Result Tracking** - Track import progress, errors, and statistics
- **Template Generation** - Download Excel templates for data import

### 2. **City Management System**
- **Complete CRUD Operations** - Create, Read, Update, Delete cities
- **Advanced Filtering** - Search by name, country, state, status
- **Geographic Operations** - Find nearby cities using coordinates
- **Bulk Operations** - Mass update, delete, and reorder cities

### 3. **State Management System**
- **State CRUD Operations** - Manage states/provinces
- **Relationship Management** - City-State relationships
- **Geographic Queries** - Distance calculations and nearby states

### 4. **Employee Profile Management**
- **Complete Employee Profiles** - Personal, contact, employment information
- **Role & Permission Management** - Assign roles and permissions to employees
- **Department & Manager Tracking** - Organizational hierarchy
- **Statistics & Reporting** - Employee analytics and insights

## 🛠️ **Database Setup**

### Prerequisites
1. **MySQL 8.0+** installed and running
2. **Java 17+** (Spring Boot 3.x requirement)
3. **Maven 3.6+** for dependency management

### Step 1: Create Database

```sql
-- Connect to MySQL as root
CREATE DATABASE itech_dev_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create a dedicated user (recommended)
CREATE USER 'itech_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON itech_dev_db.* TO 'itech_user'@'localhost';
FLUSH PRIVILEGES;
```

### Step 2: Configure Database Connection

The database configuration is already set up in:
- `application.properties` (main config)
- `application-dev.properties` (development)
- `application-prod.properties` (production)

**For Development:**
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/itech_dev_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata&createDatabaseIfNotExist=true
spring.datasource.username=root
spring.datasource.password=root
```

**Update these values in `application-dev.properties` to match your MySQL setup.**

## 🚀 **Running the Application**

### Step 1: Set Active Profile
```bash
# For development
export SPRING_PROFILES_ACTIVE=dev

# Or set in your IDE run configuration
```

### Step 2: Start the Application
```bash
# Using Maven
mvn spring-boot:run

# Or run the main class
# ItechBackendApplication.java
```

### Step 3: Verify Setup
- Backend should start on: `http://localhost:8080`
- Health check: `http://localhost:8080/actuator/health`
- H2 Console (if using H2): `http://localhost:8080/h2-console`

## 📡 **API Endpoints Available**

### **Import APIs** (`/api/imports/`)
```
POST   /api/imports/categories        - Import categories from Excel
POST   /api/imports/cities           - Import cities from Excel
GET    /api/imports/results/{id}     - Get import result
GET    /api/imports/history          - Get import history
GET    /api/imports/templates/categories - Download category template
GET    /api/imports/templates/cities - Download city template
GET    /api/imports/statistics       - Get import statistics
```

### **City APIs** (`/api/dataentry/cities/`)
```
GET    /api/dataentry/cities         - List cities (paginated)
GET    /api/dataentry/cities/{id}    - Get city by ID
POST   /api/dataentry/cities         - Create city
PUT    /api/dataentry/cities/{id}    - Update city
DELETE /api/dataentry/cities/{id}    - Delete city
GET    /api/dataentry/cities/search  - Search cities
GET    /api/dataentry/cities/dropdown - Cities for dropdowns
GET    /api/dataentry/cities/countries - Get distinct countries
GET    /api/dataentry/cities/states  - Get states for country
GET    /api/dataentry/cities/nearby  - Get nearby cities
GET    /api/dataentry/cities/statistics - City statistics
```

### **State APIs** (`/api/dataentry/states/`)
```
GET    /api/dataentry/states         - List states (paginated)
GET    /api/dataentry/states/{id}    - Get state by ID
POST   /api/dataentry/states         - Create state
PUT    /api/dataentry/states/{id}    - Update state
DELETE /api/dataentry/states/{id}    - Delete state
GET    /api/dataentry/states/search  - Search states
GET    /api/dataentry/states/dropdown - States for dropdowns
GET    /api/dataentry/states/countries - Get distinct countries
```

### **Employee Profile APIs** (`/api/employee/profiles/`)
```
GET    /api/employee/profiles        - List employee profiles
GET    /api/employee/profiles/{id}   - Get profile by ID
POST   /api/employee/profiles        - Create profile
PUT    /api/employee/profiles/{id}   - Update profile
DELETE /api/employee/profiles/{id}   - Delete profile
GET    /api/employee/profiles/search - Search profiles
GET    /api/employee/profiles/active - Get active employees
GET    /api/employee/profiles/departments - Get departments
GET    /api/employee/profiles/statistics - Employee statistics
```

### **Category APIs** (Already existing - `/api/categories/`)
```
GET    /api/categories               - List categories
POST   /api/categories               - Create category
GET    /api/categories/active        - Get active categories
GET    /api/categories/root          - Get root categories
```

## 🔧 **Frontend Integration**

### Step 1: Update Frontend API Configuration
In your frontend (`C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main`), update the API base URL:

```typescript
// src/shared/config/api.config.ts
export const API_CONFIG = {
  BASE_URL: 'http://localhost:8080/api',
  TIMEOUT: 10000,
  ENDPOINTS: {
    // Import endpoints
    IMPORT_CATEGORIES: '/imports/categories',
    IMPORT_CITIES: '/imports/cities',
    
    // City endpoints  
    CITIES: '/dataentry/cities',
    CITIES_DROPDOWN: '/dataentry/cities/dropdown',
    CITIES_COUNTRIES: '/dataentry/cities/countries',
    CITIES_STATES: '/dataentry/cities/states',
    
    // State endpoints
    STATES: '/dataentry/states',
    STATES_DROPDOWN: '/dataentry/states/dropdown',
    
    // Employee endpoints
    EMPLOYEE_PROFILES: '/employee/profiles',
    EMPLOYEE_DEPARTMENTS: '/employee/profiles/departments',
    EMPLOYEE_STATISTICS: '/employee/profiles/statistics',
    
    // Category endpoints
    CATEGORIES: '/categories'
  }
};
```

### Step 2: Test API Integration
Start both backend and frontend:

```bash
# Backend (in itech-backend directory)
mvn spring-boot:run

# Frontend (in itm-main-fronted-main directory)  
npm start
```

Visit: `http://localhost:3000` and test the employee module functionality.

## 🗃️ **Database Tables Created**

The application will automatically create these tables:
- `cities` - City information with geographic data
- `states` - State/province information
- `employee_profiles` - Complete employee information
- `employee_roles` - Employee role assignments
- `employee_permissions` - Employee permission assignments
- `categories` - Product/service categories (existing)

## 🔍 **Testing the Setup**

### 1. **Test Database Connection**
```bash
curl http://localhost:8080/actuator/health
```

### 2. **Test City API**
```bash
# Get all cities
curl http://localhost:8080/api/dataentry/cities

# Create a city
curl -X POST http://localhost:8080/api/dataentry/cities \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Mumbai",
    "stateProvince": "Maharashtra", 
    "country": "India",
    "isActive": true,
    "isMajorCity": true
  }'
```

### 3. **Test Employee API**
```bash
# Get employees for dropdown
curl http://localhost:8080/api/employee/profiles/dropdown

# Get employee statistics  
curl http://localhost:8080/api/employee/profiles/statistics
```

## 🎯 **Next Steps**

1. **Import Sample Data** - Use the Excel import APIs to populate initial data
2. **Configure Frontend** - Update your frontend API calls to use the new endpoints
3. **Test Integration** - Ensure frontend employee module works with backend
4. **Add Authentication** - Configure JWT tokens for API security
5. **Deploy** - Use production configuration for deployment

## 🆘 **Troubleshooting**

### Common Issues:

**Database Connection Failed:**
- Verify MySQL is running: `sudo service mysql start`
- Check credentials in `application-dev.properties`
- Ensure database exists: `SHOW DATABASES;`

**Port Already in Use:**
- Change port in `application.properties`: `server.port=8081`

**CORS Issues:**
- Update CORS origins in configuration
- Check frontend is running on allowed origin

**Frontend API Calls Failing:**
- Verify backend is running on `http://localhost:8080`
- Check API endpoint paths match exactly
- Ensure mock mode is disabled in frontend

## 📞 **Support**

Your backend is now fully configured with:
- ✅ Database connection and entity mapping
- ✅ Complete REST APIs for all employee module functions
- ✅ Excel import/export capabilities  
- ✅ Geographic and statistical operations
- ✅ Role and permission management
- ✅ Production-ready configuration

The frontend employee module should now connect seamlessly to these backend APIs!
