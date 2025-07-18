# 🚀 iTech Backend - Render.com Deployment Guide

## 🎯 Overview
This guide will help you deploy your iTech backend on Render.com using Docker. Your application is fully configured and ready to deploy!

## 📋 Prerequisites
- ✅ GitHub account with your code repository
- ✅ Render.com account (sign up at [render.com](https://render.com))
- ✅ Your application code (already configured with Dockerfile)

## 🔧 Step-by-Step Deployment

### Step 1: Push Code to GitHub
```bash
# Navigate to your project directory
cd D:\itech-backend\itech-backend

# Add all files
git add .

# Commit changes
git commit -m "Configure for Render deployment"

# Push to GitHub
git push origin main
```

### Step 2: Create PostgreSQL Database on Render

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **"New"** → **"PostgreSQL"**
3. Configure database:
   - **Name**: `itech-database`
   - **Database Name**: `itech_db`
   - **User**: `itech_user`
   - **Region**: `Ohio` (or closest to your location)
   - **PostgreSQL Version**: `15`
   - **Plan**: `Starter` (Free - $0/month)
4. Click **"Create Database"**
5. **Wait for database to be created** (takes 1-2 minutes)
6. **Note the connection details** - you'll need these for the web service

### Step 3: Create Web Service on Render

1. In Render Dashboard, click **"New"** → **"Web Service"**
2. **Connect GitHub Repository**:
   - Click **"Connect account"** if not already connected
   - Select your repository: `itech-backend`
   - Click **"Connect"**
3. **Configure Web Service**:
   - **Name**: `itech-backend`
   - **Environment**: `Docker`
   - **Region**: `Ohio` (same as database)
   - **Branch**: `main`
   - **Build Command**: Leave empty (Docker handles it)
   - **Start Command**: Leave empty (Docker handles it)
   - **Plan**: `Starter` (Free - $0/month)
   - **Auto-Deploy**: `Yes`

### Step 4: Configure Environment Variables

In the web service configuration, scroll down to **"Environment Variables"** and add these:

#### Core Configuration
```
SPRING_PROFILES_ACTIVE=production
PORT=8080
NODE_ENV=production
```

#### Database Configuration
```
# Get these from your database connection info (Step 2)
DATABASE_URL=postgresql://itech_user:your_password@your_hostname:5432/itech_db
JDBC_DATABASE_URL=jdbc:postgresql://your_hostname:5432/itech_db
JDBC_DATABASE_USERNAME=itech_user
JDBC_DATABASE_PASSWORD=your_password
```

#### JWT Configuration
```
JWT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5j6k7l8m9n0
JWT_EXPIRATION=86400000
```

#### CORS Configuration
```
ALLOWED_ORIGINS=http://localhost:3000,https://itm-main-fronted.vercel.app,https://www.itm-main-fronted.vercel.app
```

#### Email Configuration
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=ultimate.itech4@gmail.com
SMTP_PASSWORD=Uit4@1135##
```

#### SMS Configuration (Optional)
```
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=your_twilio_phone_number
```

#### Payment Configuration (Optional)
```
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
RAZORPAY_WEBHOOK_SECRET=your_razorpay_webhook_secret
```

#### External API Configuration
```
QUICKO_API_BASE_URL=https://api.quicko.com
QUICKO_API_KEY=your_quicko_api_key
QUICKO_API_ENABLED=true
QUICKO_API_TIMEOUT=30
QUICKO_API_RETRY_ATTEMPTS=3
QUICKO_API_RETRY_DELAY=1000
```

#### Feature Flags
```
EMAIL_SIMULATION_ENABLED=false
SMS_SIMULATION_ENABLED=true
GST_MANAGEMENT_ENABLED=true
GST_VALIDATION_ENABLED=true
```

### Step 5: Deploy the Service

1. Click **"Create Web Service"**
2. **Monitor Build Process**:
   - Go to **"Logs"** tab to see build progress
   - Build will take 5-10 minutes
   - Look for "Build completed" message
3. **Wait for Deployment**:
   - Service will show **"Live"** when ready
   - You'll get a URL like: `https://itech-backend-abc123.onrender.com`

### Step 6: Test Your Deployment

1. **Health Check**:
   ```bash
   curl https://your-app-name.onrender.com/health
   ```
   Expected response: `{"status":"UP","database":"UP",...}`

2. **Root Endpoint**:
   ```bash
   curl https://your-app-name.onrender.com/
   ```
   Expected response: `{"application":"iTech Backend API","version":"1.0.0",...}`

3. **Actuator Health**:
   ```bash
   curl https://your-app-name.onrender.com/actuator/health
   ```
   Expected response: `{"status":"UP"}`

## 🎉 Success Indicators

✅ **Build Completed Successfully** - Check logs for "Build completed"
✅ **Service Status: Live** - Shows green "Live" badge
✅ **Health Check Returns 200** - `/health` endpoint works
✅ **Database Connection Working** - Database shows "UP" in health check
✅ **All API Endpoints Responding** - Test a few API routes

## 🔄 Update Your Frontend

After successful deployment, update your frontend configuration:

```javascript
// In your frontend environment variables or config file
const API_BASE_URL = 'https://your-app-name.onrender.com';

// Or if using Next.js
NEXT_PUBLIC_API_URL=https://your-app-name.onrender.com

// Or if using React
REACT_APP_API_URL=https://your-app-name.onrender.com
```

## 🐛 Troubleshooting

### Build Fails
**Check**: Build logs in Render dashboard
**Common causes**:
- Missing environment variables
- Docker build issues
- Java version compatibility

**Solutions**:
```bash
# Check logs for specific error
# Usually resolved by ensuring all environment variables are set
```

### Database Connection Issues
**Check**: Database connection details
**Solutions**:
- Verify DATABASE_URL format
- Check database credentials
- Ensure database is running

### Application Won't Start
**Check**: Application logs
**Common causes**:
- Missing JWT_SECRET
- Database connection failure
- Port binding issues

**Solutions**:
- Set all required environment variables
- Check database connectivity
- Verify port configuration

### CORS Errors
**Check**: ALLOWED_ORIGINS setting
**Solution**:
```
ALLOWED_ORIGINS=https://your-actual-frontend-domain.com,http://localhost:3000
```

## 📊 Monitoring and Maintenance

### Real-time Monitoring
1. **Logs**: Available in Render dashboard
2. **Metrics**: CPU, memory, and request metrics
3. **Health Checks**: Automatic health monitoring

### Scaling
- **Free Tier**: 1 instance, 512MB RAM
- **Paid Plans**: Multiple instances, more RAM, faster CPU
- **Auto-scaling**: Available on higher plans

### Custom Domain
1. Go to **"Settings"** → **"Custom Domains"**
2. Add your domain
3. Configure DNS settings
4. Enable SSL (automatic)

## 🔐 Security Best Practices

### Environment Variables
- ✅ Never commit sensitive data to Git
- ✅ Use Render's environment variable system
- ✅ Regularly rotate secrets

### Database Security
- ✅ Use strong passwords
- ✅ Enable SSL connections
- ✅ Regular backups (available in Render)

### Application Security
- ✅ Keep dependencies updated
- ✅ Use HTTPS only
- ✅ Implement rate limiting
- ✅ Validate all inputs

## 🚀 Next Steps

1. **Test All Features**:
   - User authentication
   - Product management
   - Order processing
   - Payment integration
   - Email notifications

2. **Performance Optimization**:
   - Monitor response times
   - Optimize database queries
   - Implement caching if needed

3. **Production Readiness**:
   - Set up monitoring alerts
   - Configure backups
   - Plan for scaling

4. **Frontend Integration**:
   - Update frontend API URLs
   - Test CORS configuration
   - Verify all integrations

## 📞 Support

### Render Support
- **Documentation**: https://render.com/docs
- **Community**: https://community.render.com
- **Status**: https://status.render.com

### Application Support
- **Build Issues**: Check build logs
- **Runtime Issues**: Check application logs
- **Database Issues**: Check database logs

## 🎯 Final Checklist

Before going live:
- [ ] All environment variables configured
- [ ] Database connection working
- [ ] Health checks passing
- [ ] Frontend updated with new API URL
- [ ] All API endpoints tested
- [ ] CORS configured correctly
- [ ] SSL certificate active
- [ ] Monitoring set up
- [ ] Backup strategy in place

## 🌟 Your Application URLs

After deployment, you'll have:
- **API Base URL**: `https://your-app-name.onrender.com`
- **Health Check**: `https://your-app-name.onrender.com/health`
- **API Documentation**: `https://your-app-name.onrender.com/api`

🎉 **Congratulations!** Your iTech backend is now live on Render.com!

---

**Need help?** Check the troubleshooting section above or contact support.
