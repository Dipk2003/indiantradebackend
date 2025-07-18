# Deploy iTech Backend on Render.com - Step by Step

## 🎯 Why Render.com?

- ✅ **Native Java Support** - Built for Spring Boot applications
- ✅ **Docker Support** - Your app is already configured with Dockerfile
- ✅ **Free Tier Available** - Good for testing and small applications
- ✅ **Auto-scaling** - Handles traffic automatically
- ✅ **Database Integration** - Easy PostgreSQL setup

## 📋 Prerequisites

1. **GitHub Account** - Your code must be in a GitHub repository
2. **Render Account** - Sign up at [render.com](https://render.com)
3. **Database** - We'll create a PostgreSQL database on Render

## 🔧 Step-by-Step Deployment

### Step 1: Create Database on Render

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **"New"** → **"PostgreSQL"**
3. Configure:
   - **Name**: `itech-database`
   - **Database**: `itech_db`
   - **User**: `itech_user`
   - **Region**: `Ohio` (or closest to your users)
   - **PostgreSQL Version**: `15`
   - **Plan**: `Starter` (Free)
4. Click **"Create Database"**
5. **Note the connection details** - you'll need them for the web service

### Step 2: Push Code to GitHub

```bash
# If not already done
git add .
git commit -m "Configure for Render deployment"
git push origin main
```

### Step 3: Create Web Service on Render

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **"New"** → **"Web Service"**
3. **Connect GitHub Repository**:
   - Select your repository
   - Click **"Connect"**
4. **Configure Service**:
   - **Name**: `itech-backend`
   - **Environment**: `Docker`
   - **Region**: `Ohio` (same as database)
   - **Branch**: `main`
   - **Build Command**: Leave empty (Docker handles it)
   - **Start Command**: Leave empty (Docker handles it)
   - **Plan**: `Starter` (Free)

### Step 4: Set Environment Variables

In the web service settings, add these environment variables:

#### **Core Configuration**
```
SPRING_PROFILES_ACTIVE=production
PORT=8080
```

#### **Database Configuration**
```
# Get these from your database connection info
DATABASE_URL=postgresql://itech_user:password@hostname:5432/itech_db
JDBC_DATABASE_URL=jdbc:postgresql://hostname:5432/itech_db
JDBC_DATABASE_USERNAME=itech_user
JDBC_DATABASE_PASSWORD=your_password
```

#### **JWT Configuration**
```
JWT_SECRET=your-super-secure-jwt-secret-key-here-make-it-long-and-random-123456789
JWT_EXPIRATION=86400000
```

#### **CORS Configuration**
```
ALLOWED_ORIGINS=https://your-frontend-domain.com,http://localhost:3000
```

#### **Email Configuration (Gmail)**
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-gmail-app-password
```

#### **SMS Configuration (Optional)**
```
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=your_twilio_phone_number
```

#### **Payment Configuration (Razorpay)**
```
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
RAZORPAY_WEBHOOK_SECRET=your_razorpay_webhook_secret
```

### Step 5: Deploy

1. Click **"Create Web Service"**
2. **Monitor Build Logs** - The build will take 5-10 minutes
3. **Wait for Deployment** - You'll see "Live" when ready

### Step 6: Test Deployment

1. **Health Check**:
   ```bash
   curl https://your-app-name.onrender.com/health
   ```

2. **Root Endpoint**:
   ```bash
   curl https://your-app-name.onrender.com/
   ```

3. **Actuator Health**:
   ```bash
   curl https://your-app-name.onrender.com/actuator/health
   ```

## 🎉 Success Indicators

✅ **Build Completed Successfully**
✅ **Service Shows "Live" Status**
✅ **Health Check Returns 200**
✅ **Database Connection Working**
✅ **API Endpoints Responding**

## 🔄 Update Frontend

After successful deployment, update your frontend:

```javascript
// In your frontend config
const API_BASE_URL = 'https://your-app-name.onrender.com';
```

## 🐛 Common Issues & Solutions

### Issue 1: Build Fails
**Solution**: Check build logs for specific errors, usually related to dependencies or Java version.

### Issue 2: Database Connection Fails
**Solution**: Verify environment variables match your database connection details exactly.

### Issue 3: Application Won't Start
**Solution**: Check that all required environment variables are set, especially JWT_SECRET.

### Issue 4: CORS Errors
**Solution**: Update ALLOWED_ORIGINS with your actual frontend domain.

## 📞 Getting Help

- **Build Logs**: Check in Render dashboard → Service → Logs
- **Application Logs**: Available in real-time in the dashboard
- **Database Logs**: Check database service logs
- **Render Docs**: https://render.com/docs

## 🚀 Next Steps

1. **Test All Endpoints** - Make sure all API routes work
2. **Update Frontend** - Point to new backend URL
3. **Configure Domain** - Add custom domain if needed
4. **Monitor Performance** - Check logs and metrics
5. **Scale if Needed** - Upgrade plan for production use

Your iTech backend will be live at: `https://your-app-name.onrender.com`
