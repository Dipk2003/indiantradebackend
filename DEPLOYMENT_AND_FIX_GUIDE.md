# iTech Backend - AWS Database Issue Fix & Deployment Guide

## Issue Summary
Your Spring Boot application is failing to start on AWS Elastic Beanstalk with the error:
```
org.postgresql.util.PSQLException: ERROR: relation "buyers" does not exist
```

This happens because the database tables haven't been created in your AWS PostgreSQL database.

## Solution Overview
I've created a complete database schema that matches your Spring Boot application entities. This will create all necessary tables including the missing "buyers" table and all related tables.

## Files Created

1. **`database_schema_initialization.sql`** - Complete database schema with all tables
2. **`deploy_database_schema.bat`** - Windows batch script to deploy the schema  
3. **`deploy_database_schema.ps1`** - PowerShell script (recommended)
4. **`create_buyers_table.sql`** - Quick fix for just the buyers table (if you prefer minimal changes)

## 🚀 STEP-BY-STEP FIX INSTRUCTIONS

### Prerequisites
1. **PostgreSQL Client** - Download and install from: https://www.postgresql.org/download/windows/
2. **Database Connection Details** - Your AWS RDS PostgreSQL connection info
3. **Database Access** - Ensure your IP is whitelisted in RDS security group

### Method 1: Using PowerShell (Recommended)

1. **Open PowerShell as Administrator**
2. **Navigate to your project directory:**
   ```powershell
   cd "D:\itech-backend\itech-backend"
   ```

3. **Run the deployment script:**
   ```powershell
   .\deploy_database_schema.ps1
   ```

4. **Follow the prompts and provide:**
   - Database host (your RDS endpoint)
   - Database port (5432)
   - Database name
   - Database username
   - Database password

### Method 2: Using Command Prompt

1. **Open Command Prompt as Administrator**
2. **Navigate to your project directory:**
   ```cmd
   cd "D:\itech-backend\itech-backend"
   ```

3. **Run the deployment script:**
   ```cmd
   deploy_database_schema.bat
   ```

### Method 3: Manual Deployment

If the scripts don't work, you can run the SQL manually:

```bash
psql -h your-rds-endpoint.region.rds.amazonaws.com -p 5432 -U your-username -d your-database -f database_schema_initialization.sql
```

## 📋 What the Schema Creates

The complete schema includes:

### Core Tables
- `users` - System users
- `companies` - Company information
- `buyers` - **The missing table causing your error**
- `vendors` - Vendor information
- `admins` - Admin users

### Product & Catalog
- `categories`, `sub_categories`, `micro_categories`
- `products`, `product_images`, `product_attributes`
- `product_variants`, `product_attribute_values`

### Commerce
- `carts`, `cart_items`
- `orders`, `order_items`
- `inquiries`, `quotes`
- `reviews`, `wishlists`

### Payment & Subscription
- `subscription_plans`, `subscriptions`
- `payments`, `transactions`
- `refunds`, `invoices`

### Support & Communication
- `support_tickets`
- `chats`, `chat_messages`
- `contact_messages`

### System & Analytics
- `notifications`, `activity_logs`
- `analytics`, `system_metrics`
- `kyc_documents`, `otp_verifications`

### Initial Data
- Default admin user
- Sample subscription plans
- Default product categories
- SLA configurations

## 🔧 After Database Deployment

### 1. Restart Your AWS Application

**Using EB CLI:**
```bash
eb restart
```

**Using AWS Console:**
1. Go to Elastic Beanstalk Console
2. Select your environment
3. Click "Restart App Server"

### 2. Verify Deployment

**Check application logs:**
```bash
eb logs --all
```

**Look for successful startup messages:**
- "Started ItechBackendApplication"
- No more "relation does not exist" errors

### 3. Test Your Application

Try accessing your application endpoints:
- Health check: `http://your-app-url/actuator/health`
- API endpoints: `http://your-app-url/api/...`

## ⚠️ Important Notes

### Database Configuration
Make sure your `aws-eb-environment-variables.env` has the correct values:

```properties
DATABASE_URL=jdbc:postgresql://your-rds-endpoint.region.rds.amazonaws.com:5432/itech_db
JDBC_DATABASE_USERNAME=your-username
JDBC_DATABASE_PASSWORD=your-password
SPRING_PROFILES_ACTIVE=production
```

### Security Group Settings
Ensure your RDS security group allows connections from:
- Your local IP (for running deployment scripts)
- Elastic Beanstalk security group (for application access)

### Connection String Format
Your database URL should follow this format:
```
jdbc:postgresql://hostname:port/database_name
```

Example:
```
jdbc:postgresql://mydb.abc123.ap-south-1.rds.amazonaws.com:5432/itech_db
```

## 🔍 Troubleshooting

### Common Issues

**1. "psql: command not found"**
- Install PostgreSQL client tools
- Add PostgreSQL bin directory to PATH

**2. "Connection refused"**
- Check RDS security group settings
- Verify database endpoint and port
- Check if RDS instance is running

**3. "Authentication failed"**
- Verify username and password
- Check if user has sufficient permissions
- Try connecting with a database client first

**4. "Permission denied"**
- Ensure database user has CREATE TABLE permissions
- Try using the master user for initial setup

**5. "Still getting relation errors after deployment"**
- Restart the application completely
- Check if you're connecting to the right database
- Verify the schema was created in the correct database

### Quick Verification Queries

Connect to your database and run these to verify:

```sql
-- Check if buyers table exists
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'buyers';

-- Count total tables created
SELECT COUNT(*) as total_tables 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- List all tables
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

## 🎯 Expected Results

After successful deployment:

1. **Database**: 50+ tables created with proper relationships
2. **Application**: Starts successfully without database errors  
3. **Logs**: Clean startup logs without PSQLExceptions
4. **Status**: Application shows as "Health: Ok"

## 📞 Next Steps After Fix

1. **Test Core Functionality**
   - User registration/login
   - Product listing
   - Basic API endpoints

2. **Configure Environment Variables**
   - Email settings (SMTP)
   - Payment gateway credentials
   - External API keys

3. **Set up Monitoring**
   - CloudWatch logs
   - Application health monitoring
   - Database performance monitoring

4. **Security Review**
   - Update default passwords
   - Review security group settings
   - Enable SSL/TLS

## ⚡ Quick Fix Option

If you just want to fix the immediate error and create only the buyers table:

```bash
psql -h your-rds-endpoint -p 5432 -U your-username -d your-database -f create_buyers_table.sql
```

But I recommend using the complete schema for a production-ready setup.

---

## 📞 Support

If you encounter any issues during deployment:

1. **Check the error messages carefully**
2. **Verify all connection details**
3. **Ensure network connectivity**
4. **Try connecting with a GUI tool first (pgAdmin, DBeaver)**
5. **Check AWS CloudWatch logs for additional errors**

The scripts include detailed error handling and will guide you through common issues.

---

**🎉 Once deployed successfully, your Spring Boot application should start without any database-related errors!**
