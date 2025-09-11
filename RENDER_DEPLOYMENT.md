# Indian Trade Mart Backend - Render Deployment Guide

## 🚀 Quick Render Deployment

### Prerequisites
- GitHub repository: `https://github.com/Dipk2003/indiantradebackend.git`
- Render account (free tier available)
- Environment variables ready

### Step 1: Create Web Service on Render

1. **Go to Render Dashboard**: https://render.com/
2. **Click "New +"** → **"Web Service"**
3. **Connect GitHub repository**: `Dipk2003/indiantradebackend`
4. **Configure the service**:
   - **Name**: `itech-backend`
   - **Runtime**: `Docker`
   - **Branch**: `main`
   - **Root Directory**: `.` (leave empty)
   - **Dockerfile Path**: `./Dockerfile`

### Step 2: Configure Environment Variables

In the Render dashboard, add these environment variables:

#### Required Variables:
```
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080
JAVA_OPTS=-Xmx1g -Xms512m -XX:+UseG1GC
```

#### Database Configuration:
```
DATABASE_URL=your-database-url
JDBC_DATABASE_USERNAME=your-db-username
JDBC_DATABASE_PASSWORD=your-db-password
```

#### Security:
```
JWT_SECRET=your-256-bit-jwt-secret-key
```

#### Payment Gateway (Optional):
```
RAZORPAY_KEY_ID=your-razorpay-key-id
RAZORPAY_KEY_SECRET=your-razorpay-secret
```

#### Email Service (Optional):
```
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USERNAME=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
```

#### AWS S3 (Optional):
```
AWS_S3_BUCKET=your-s3-bucket
AWS_S3_REGION=us-west-2
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
```

### Step 3: Deploy

1. **Click "Create Web Service"**
2. **Wait for deployment** (5-10 minutes)
3. **Monitor logs** in Render dashboard
4. **Test the application** using the provided URL

## 🗄️ Database Setup Options

### Option 1: Render PostgreSQL (Recommended)
1. **Create PostgreSQL database** in Render
2. **Get connection details** from dashboard
3. **Set DATABASE_URL** environment variable

### Option 2: External Database
- Use any external PostgreSQL service
- Set the DATABASE_URL accordingly

## 🔧 Troubleshooting Common Issues

### Issue 1: Docker Build Fails
**Problem**: Missing files or build errors
**Solution**: 
- Check Dockerfile path is correct
- Ensure all referenced files exist in repository
- Review build logs in Render dashboard

### Issue 2: Application Won't Start
**Problem**: Java/Spring Boot startup errors
**Solution**:
- Check environment variables are set
- Verify Java version compatibility
- Check application logs for specific errors

### Issue 3: Database Connection Issues
**Problem**: Cannot connect to database
**Solution**:
- Verify DATABASE_URL format: `jdbc:postgresql://host:port/database`
- Check database credentials
- Ensure database is accessible from Render

### Issue 4: Memory Issues
**Problem**: OutOfMemoryError
**Solution**:
- Increase JAVA_OPTS heap size: `-Xmx1.5g -Xms1g`
- Upgrade to higher Render plan
- Optimize application memory usage

### Issue 5: Health Check Failures
**Problem**: Health check endpoint not responding
**Solution**:
- Verify `/actuator/health` endpoint is enabled
- Check Spring Boot Actuator configuration
- Ensure port 8080 is correctly exposed

## 📊 Monitoring and Logs

### Viewing Logs
1. **Go to your service** in Render dashboard
2. **Click "Logs"** tab
3. **Monitor real-time logs** during deployment and runtime

### Key Log Patterns to Look For:
```
✅ Good:
- "Started ItechBackendApplication in X seconds"
- "Tomcat started on port(s): 8080"
- "Indian Trade Mart Backend - Starting Application"

❌ Problems:
- "OutOfMemoryError"
- "ConnectException" (database issues)
- "Port already in use"
- "Failed to start application"
```

### Performance Monitoring
- **Response Times**: Monitor via Render dashboard
- **Memory Usage**: Check application logs
- **Error Rates**: Monitor HTTP error responses

## 🔄 Updates and CI/CD

### Automatic Deployment
- **Auto-deploy enabled**: Pushes to `main` branch trigger deployment
- **Manual deploy**: Use "Manual Deploy" button in dashboard

### Rolling Updates
1. **Push code** to GitHub main branch
2. **Render detects changes** and starts build
3. **Zero-downtime deployment** (on paid plans)

## 💰 Render Plans and Scaling

### Free Plan Limitations:
- **750 hours/month** (sleeps after 15 minutes of inactivity)
- **512MB RAM, 0.1 CPU**
- **No custom domains on HTTP**

### Starter Plan Benefits ($7/month):
- **Always-on service** (no sleeping)
- **512MB RAM, 0.5 CPU**
- **Custom domains with SSL**

### Performance Plan ($25/month):
- **1GB RAM, 1 CPU**
- **Better performance**
- **Priority support**

## 🔐 Security Best Practices

### Environment Variables
- ✅ **Never commit secrets** to repository
- ✅ **Use Render's environment variables** feature
- ✅ **Rotate secrets** regularly

### Database Security
- ✅ **Use SSL connections** for database
- ✅ **Restrict database access** to Render IPs
- ✅ **Use strong passwords**

### Application Security
- ✅ **Enable HTTPS** (automatic on Render)
- ✅ **Configure CORS** properly
- ✅ **Use strong JWT secrets**

## 🆘 Support and Resources

### Render Documentation
- **General Docs**: https://render.com/docs
- **Docker Deployment**: https://render.com/docs/docker
- **Environment Variables**: https://render.com/docs/environment-variables

### Getting Help
1. **Check Render Status**: https://status.render.com/
2. **Community Forum**: https://community.render.com/
3. **Support Tickets**: Available on paid plans

### Common URLs After Deployment
- **Application**: `https://your-service-name.onrender.com`
- **Health Check**: `https://your-service-name.onrender.com/actuator/health`
- **API Docs**: `https://your-service-name.onrender.com/swagger-ui.html`

## 📝 Deployment Checklist

- [ ] Repository connected to Render
- [ ] Dockerfile builds successfully
- [ ] Environment variables configured
- [ ] Database connection established
- [ ] Health check endpoint responding
- [ ] Application starts without errors
- [ ] API endpoints accessible
- [ ] Logs showing normal operation
- [ ] Custom domain configured (if needed)
- [ ] SSL certificate active

---

*For additional support, refer to the main [DEPLOYMENT.md](./DEPLOYMENT.md) file.*
