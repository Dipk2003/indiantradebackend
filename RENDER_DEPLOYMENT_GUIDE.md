# 🚀 Render Deployment Guide - iTech Backend

## ✅ Current Status
- **Build**: ✅ Fixed (Caffeine cache replaces EhCache)
- **Profile**: ✅ Fixed (`render` profile active)
- **Port**: 🔧 **NEEDS ATTENTION** (Should bind to port 10000)

## 🎯 Critical Fix Required

### Issue
Your app starts on port 8080 but Render expects port 10000. This causes deployment failure.

### Solution
The `render.yaml` has been updated with the correct environment variables. Now you need to:

## 📋 Deployment Steps

### 1. Commit and Push Changes
```bash
git add .
git commit -m "Fix: Update render.yaml with correct PORT and SPRING_PROFILES_ACTIVE"
git push origin main
```

### 2. Configure Environment Variables in Render Dashboard

Go to your Render service dashboard and set these **required** environment variables:

#### **Database Configuration**
```
DATABASE_URL=postgresql://username:password@hostname:port/database_name
JDBC_DATABASE_USERNAME=your_db_username
JDBC_DATABASE_PASSWORD=your_db_password
```

#### **Security**
```
JWT_SECRET=your-super-secure-jwt-secret-key-here
```

#### **Optional Services** (Set if you use them)
```
# Redis (if using Redis)
REDIS_HOST=your-redis-host
REDIS_PASSWORD=your-redis-password

# Email Service
EMAIL_USERNAME=your-email@gmail.com
EMAIL_PASSWORD=your-app-password

# Payment Gateway
RAZORPAY_KEY_ID=your-razorpay-key-id
RAZORPAY_KEY_SECRET=your-razorpay-key-secret

# AWS S3
AWS_S3_BUCKET=your-s3-bucket-name
AWS_ACCESS_KEY_ID=your-aws-access-key-id
AWS_SECRET_ACCESS_KEY=your-aws-secret-access-key
```

### 3. Verify Environment Variables

The following are **automatically set** by `render.yaml`:
- ✅ `PORT=10000` 
- ✅ `SPRING_PROFILES_ACTIVE=render`
- ✅ All static configuration values

## 🔍 Expected Deployment Logs

After the fix, you should see:
```
✅ The following 1 profile is active: "render"
✅ Tomcat started on port(s): 10000 (http)
✅ Started ItechBackendApplication in X.XXX seconds
```

## 🚨 Troubleshooting

### If deployment still fails:

1. **Check Environment Variables**
   - Go to Render Dashboard → Your Service → Environment
   - Verify all required variables are set

2. **Check Database Connection**
   - Ensure `DATABASE_URL` format is correct
   - Verify database credentials

3. **Check Logs**
   - Look for specific error messages
   - Verify the correct profile is active

## 🏗️ Architecture Summary

### Caching Strategy
- **Render/Prod**: Caffeine (in-memory, high-performance)
- **Test**: Caffeine (lightweight, no external dependencies)
- **Redis**: Optional for production scaling

### Database
- **Render**: PostgreSQL (configured via environment variables)
- **Local**: PostgreSQL (localhost)

### Port Configuration
- **Render**: 10000 (Render's standard web service port)
- **Local**: 8080 (Spring Boot default)

## ✅ Next Steps

1. **Deploy**: Commit and push the updated `render.yaml`
2. **Configure**: Set environment variables in Render Dashboard
3. **Monitor**: Watch deployment logs for successful startup
4. **Test**: Verify health endpoint: `https://your-app.onrender.com/actuator/health`

---

**Expected Result**: Your app will start successfully on port 10000 with the `render` profile active, using Caffeine cache and connecting to your PostgreSQL database.
