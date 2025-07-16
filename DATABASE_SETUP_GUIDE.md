# Database Setup Guide for Render.com Deployment

## 🚨 URGENT: Fix Database Connection Issue

Your application is failing because the database environment variables are not set in Render.com. Follow these steps to fix it:

## Step 1: Create PostgreSQL Database on Render.com

1. **Go to Render Dashboard** → https://dashboard.render.com/
2. **Click "New +"** → **"PostgreSQL"**
3. **Configure Database:**
   - Name: `itech-backend-db`
   - Database Name: `itech_db_prod`
   - User: `itech_user`
   - Region: **Same as your web service**
   - Plan: **Starter (Free)**
4. **Click "Create Database"**
5. **Wait for deployment to complete**

## Step 2: Get Database Connection Details

After database creation, you'll see:
- **External Database URL**: `postgresql://username:password@host:port/database`
- **Internal Database URL**: `postgresql://username:password@host:port/database`
- **Host**: `hostname.render.com`
- **Port**: `5432`
- **Database**: `itech_db_prod`
- **Username**: `itech_user`
- **Password**: `auto-generated`

## Step 3: Set Environment Variables in Your Web Service

1. **Go to your web service** → **"Environment" tab**
2. **Add these variables ONE by ONE:**

### Required Database Variables:
```bash
DATABASE_URL=postgresql://username:password@host:port/database
DB_USERNAME=itech_user
DB_PASSWORD=your_auto_generated_password
DB_DRIVER=org.postgresql.Driver
DB_DIALECT=org.hibernate.dialect.PostgreSQLDialect
```

### Other Required Variables:
```bash
SPRING_PROFILES_ACTIVE=production
PORT=8080
JWT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5j6k7l8m9n0
JWT_EXPIRATION=86400000
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=ultimate.itech4@gmail.com
SMTP_PASSWORD=Uit4@1135##
```

## Step 4: Copy Database URL from Render

1. **Go to your PostgreSQL database** → **"Connect" tab**
2. **Copy "External Database URL"**
3. **Paste it as DATABASE_URL in your web service environment**

Example:
```bash
DATABASE_URL=postgresql://itech_user:AbCdEfGhIjKlMnOpQrSt@dpg-abc123def456ghi-a.oregon-postgres.render.com:5432/itech_db_prod
```

## Step 5: Extract Individual Components

From the DATABASE_URL, extract:
- **Username**: `itech_user`
- **Password**: `AbCdEfGhIjKlMnOpQrSt`
- **Host**: `dpg-abc123def456ghi-a.oregon-postgres.render.com`
- **Port**: `5432`
- **Database**: `itech_db_prod`

## Step 6: Set All Variables

In your Render web service environment:

```bash
DATABASE_URL=postgresql://itech_user:AbCdEfGhIjKlMnOpQrSt@dpg-abc123def456ghi-a.oregon-postgres.render.com:5432/itech_db_prod
DB_USERNAME=itech_user
DB_PASSWORD=AbCdEfGhIjKlMnOpQrSt
DB_DRIVER=org.postgresql.Driver
DB_DIALECT=org.hibernate.dialect.PostgreSQLDialect
```

## Step 7: Redeploy Your Service

1. **Go to your web service** → **"Manual Deploy"**
2. **Click "Deploy latest commit"**
3. **Wait for deployment to complete**

## Step 8: Check Logs

1. **Go to "Logs" tab**
2. **Look for successful database connection:**
   ```
   HikariPool-1 - Start completed
   Started ItechBackendApplication in X.XXX seconds
   ```

## Alternative: Using MySQL (if you prefer)

If you want to use MySQL instead:

1. **Use a MySQL provider** (like PlanetScale, JawsDB, etc.)
2. **Set these variables instead:**
```bash
DATABASE_URL=mysql://username:password@host:3306/database_name
DB_USERNAME=your_username
DB_PASSWORD=your_password
DB_DRIVER=com.mysql.cj.jdbc.Driver
DB_DIALECT=org.hibernate.dialect.MySQL8Dialect
```

## Common Issues and Solutions

### Issue 1: "Communications link failure"
**Solution**: Database URL is incorrect or database not accessible
- Verify DATABASE_URL format
- Check if database is running
- Ensure same region for database and web service

### Issue 2: "Access denied"
**Solution**: Wrong username/password
- Check DB_USERNAME and DB_PASSWORD
- Verify credentials match database settings

### Issue 3: "Unknown database"
**Solution**: Database name doesn't exist
- Verify database name in DATABASE_URL
- Check if database was created successfully

### Issue 4: "Connection timeout"
**Solution**: Network/region issues
- Ensure database and web service are in same region
- Check firewall settings

## Testing Database Connection

Once deployed, test your endpoints:
- **Health Check**: `https://your-app.onrender.com/actuator/health`
- **API Test**: `https://your-app.onrender.com/api/test`

## Security Best Practices

1. **Never commit database credentials to Git**
2. **Use environment variables for all sensitive data**
3. **Use different databases for dev/prod**
4. **Enable SSL connections (automatically done by Render)**
5. **Regularly rotate database passwords**

## Need Help?

If you're still having issues:
1. Check Render service logs
2. Verify all environment variables are set
3. Test database connection independently
4. Check database service status

---

**Remember**: The key issue was that DATABASE_URL, DB_USERNAME, and DB_PASSWORD were not set in your Render.com environment variables. Once you set these correctly, your application should connect to the database successfully.
