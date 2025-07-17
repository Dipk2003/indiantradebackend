# 🚀 Render Deployment Guide

## Your Database Information
- **Database Name**: `itech_user`
- **Username**: `itech_user_user`
- **Password**: `uPCQxPFY11O770bGtR9MKDHUOXJ6TqFc`
- **Host**: `dpg-d1sbevrui1rs73a87mhg-a.oregon-postgres.render.com`
- **Port**: `5432`
- **Database URL**: `postgresql://itech_user_user:uPCQxPFY11O770bGtR9MKDHUOXJ6TqFc@dpg-d1sbevrui1rs73a87mhg-a.oregon-postgres.render.com/itech_user`

## 📋 Step-by-Step Deployment

### 1. Create Web Service
1. Go to [Render Dashboard](https://render.com/dashboard)
2. Click **"New"** → **"Web Service"**
3. Connect your GitHub repository: `https://github.com/Dipk2003/indiantradebackend.git`

### 2. Configure Web Service
- **Name**: `itech-backend`
- **Runtime**: `Java`
- **Branch**: `main`
- **Build Command**: `./mvnw clean package -DskipTests`
- **Start Command**: `java -jar target/itech-backend-0.0.1-SNAPSHOT.jar`

### 3. Add Environment Variables
Go to your web service → **Environment** tab and add these variables:

```
SPRING_PROFILES_ACTIVE=production
PORT=8080
JWT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5j6k7l8m9n0
JWT_EXPIRATION=86400000
ALLOWED_ORIGINS=https://your-frontend-domain.com,https://www.your-frontend-domain.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=ultimate.itech4@gmail.com
SMTP_PASSWORD=Uit4@1135##
GST_MANAGEMENT_ENABLED=true
GST_DEFAULT_RATES=0,5,12,18,28
GST_VALIDATION_ENABLED=true
EMAIL_SIMULATION_ENABLED=false
SMS_SIMULATION_ENABLED=true
```

### 4. Connect PostgreSQL Database
1. In your web service settings
2. Go to **"Environment"** tab
3. Click **"Add from Database"**
4. Select your PostgreSQL database (`itech_user`)
5. This will automatically add:
   - `DATABASE_URL`
   - `DB_USERNAME`
   - `DB_PASSWORD`

### 5. Deploy
1. Click **"Deploy Latest Commit"**
2. Monitor the build and deployment logs
3. Your API will be available at: `https://your-service-name.onrender.com`

## 🔧 Manual Database Configuration (if needed)
If automatic database connection doesn't work, manually add these:

```
DATABASE_URL=postgresql://itech_user_user:uPCQxPFY11O770bGtR9MKDHUOXJ6TqFc@dpg-d1sbevrui1rs73a87mhg-a.oregon-postgres.render.com/itech_user
```

## 🔍 Testing Your Deployment
After deployment, test these endpoints:
- Health check: `https://your-service-name.onrender.com/actuator/health`
- API base: `https://your-service-name.onrender.com/api/`

## 📝 Important Notes
1. **Database URL**: Your `DatabaseConfig` class will automatically parse the PostgreSQL URL
2. **Environment Variables**: All required variables are listed above
3. **Security**: Never commit sensitive data to Git
4. **Frontend**: Update `ALLOWED_ORIGINS` with your actual frontend domain
5. **Logs**: Monitor deployment logs for any issues

## 🔒 Security Reminders
- Keep your database credentials secure
- Use environment variables for all sensitive data
- Update JWT secret for production use
- Configure proper CORS origins for your frontend

## 🎉 You're Ready to Deploy!
Your application is now configured with:
- ✅ PostgreSQL database connection
- ✅ Proper environment variables
- ✅ Database URL parsing
- ✅ Production-ready configuration

Happy deploying! 🚀
