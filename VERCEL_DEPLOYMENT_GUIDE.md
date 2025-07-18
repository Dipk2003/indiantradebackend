# iTech Backend - Vercel Deployment Guide

## 🚨 Important Notice

**Vercel has limited support for Java Spring Boot applications**. For better compatibility, consider using:
- **Render.com** (Recommended for Java) - Your app is already configured for this
- **Railway** - Good Java support
- **Heroku** - Traditional choice for Java apps

However, if you must use Vercel, follow this guide.

## 📋 Prerequisites

1. **Database**: PostgreSQL database (Vercel Postgres, Supabase, or other)
2. **AWS S3**: For file storage (Vercel has limited file system)
3. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
4. **GitHub Repository**: Your code must be in a GitHub repository

## 🔧 Backend Deployment on Vercel

### Step 1: Database Setup

#### Option A: Vercel Postgres (Recommended)
1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Click "Storage" → "Create Database" → "Postgres"
3. Configure:
   - **Name**: `itech-database`
   - **Region**: Choose closest to your users
4. Note the connection details

#### Option B: Supabase (Alternative)
1. Go to [Supabase](https://supabase.com)
2. Create new project
3. Go to Settings → Database
4. Copy connection string

### Step 2: AWS S3 Setup (Required for Vercel)

1. Go to [AWS Console](https://aws.amazon.com/console/)
2. Create S3 bucket:
   - **Name**: `itech-backend-files`
   - **Region**: `us-east-1`
   - **Public access**: Configure as needed
3. Create IAM user with S3 permissions
4. Note access keys

### Step 3: Deploy Backend

1. **Push your code to GitHub**:
   ```bash
   git add .
   git commit -m "Add Vercel configuration"
   git push origin main
   ```

2. **Import project in Vercel**:
   - Go to [Vercel Dashboard](https://vercel.com/dashboard)
   - Click "New Project"
   - Import from GitHub
   - Select your repository

3. **Configure Build Settings**:
   - **Framework Preset**: Other
   - **Build Command**: `./mvnw clean package -DskipTests`
   - **Output Directory**: `target`
   - **Install Command**: `./mvnw dependency:resolve`

4. **Set Environment Variables**:
   Copy values from `.env.vercel.backend` and add to Vercel:

   ```env
   # Core Configuration
   SPRING_PROFILES_ACTIVE=vercel
   PORT=8080
   
   # Database (Replace with your actual values)
   DATABASE_URL=postgresql://username:password@hostname:5432/database_name
   DB_USERNAME=your_db_username
   DB_PASSWORD=your_db_password
   
   # JWT
   JWT_SECRET=your-super-secure-jwt-secret-key-here-make-it-long-and-random
   JWT_EXPIRATION=86400000
   
   # CORS (Replace with your frontend URL)
   ALLOWED_ORIGINS=https://your-frontend-domain.vercel.app,http://localhost:3000
   
   # Email (Gmail)
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USERNAME=your-email@gmail.com
   SMTP_PASSWORD=your-gmail-app-password
   
   # SMS (Twilio)
   TWILIO_ACCOUNT_SID=your_twilio_account_sid
   TWILIO_AUTH_TOKEN=your_twilio_auth_token
   TWILIO_PHONE_NUMBER=your_twilio_phone_number
   
   # Payment (Razorpay)
   RAZORPAY_KEY_ID=your_razorpay_key_id
   RAZORPAY_KEY_SECRET=your_razorpay_key_secret
   RAZORPAY_WEBHOOK_SECRET=your_razorpay_webhook_secret
   
   # Cloud Storage (AWS S3)
   AWS_S3_BUCKET_NAME=your-s3-bucket-name
   AWS_S3_REGION=us-east-1
   AWS_ACCESS_KEY_ID=your_aws_access_key
   AWS_SECRET_ACCESS_KEY=your_aws_secret_key
   ```

5. **Deploy**:
   - Click "Deploy"
   - Monitor build logs
   - Wait for deployment to complete

### Step 4: Test Backend

1. **Health Check**:
   ```bash
   curl https://your-backend-app.vercel.app/actuator/health
   ```

2. **API Test**:
   ```bash
   curl https://your-backend-app.vercel.app/api/test
   ```

## 🌐 Frontend Deployment on Vercel

### Step 1: Prepare Frontend

1. **Update API URL** in your frontend config:
   ```javascript
   // config/api.js or similar
   const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://your-backend-app.vercel.app';
   ```

2. **Environment Variables**:
   Use values from `.env.vercel.frontend`:
   ```env
   NEXT_PUBLIC_API_URL=https://your-backend-app.vercel.app
   NEXT_PUBLIC_RAZORPAY_KEY_ID=your_razorpay_key_id
   NODE_ENV=production
   ```

### Step 2: Deploy Frontend

1. **Import Project**:
   - Go to Vercel Dashboard
   - Click "New Project"
   - Select your frontend repository

2. **Configure Build Settings**:
   - **Framework Preset**: Auto-detect (Next.js/React)
   - **Build Command**: `npm run build` or `yarn build`
   - **Output Directory**: `out` or `build`
   - **Install Command**: `npm install` or `yarn`

3. **Set Environment Variables**:
   Add all variables from `.env.vercel.frontend`

4. **Deploy**:
   - Click "Deploy"
   - Wait for deployment

## 🔄 Update CORS Configuration

After both deployments, update your backend CORS:

1. Go to backend Vercel project settings
2. Update `ALLOWED_ORIGINS` environment variable:
   ```
   ALLOWED_ORIGINS=https://your-frontend-domain.vercel.app,https://www.your-frontend-domain.vercel.app,http://localhost:3000
   ```
3. Redeploy backend

## 🐛 Troubleshooting Common Issues

### 1. "NOT_FOUND" Error
**Cause**: Vercel routing configuration
**Solution**: Check `vercel.json` routes configuration

### 2. "Build Failed" Error
**Cause**: Java version mismatch
**Solution**: 
- Ensure Java 11/17 compatibility
- Check `pom.xml` for Java version
- Verify Maven wrapper permissions

### 3. "Database Connection Failed"
**Cause**: Incorrect database configuration
**Solution**:
- Verify `DATABASE_URL` format
- Check database credentials
- Ensure database allows connections

### 4. "CORS Error"
**Cause**: Missing or incorrect CORS configuration
**Solution**:
- Update `ALLOWED_ORIGINS` with correct frontend URL
- Check WebConfig.java CORS settings
- Verify frontend is making requests to correct backend URL

### 5. "Cold Start Issues"
**Cause**: Vercel serverless functions have cold start delays
**Solution**:
- Implement health check endpoint
- Consider using Vercel Pro for better performance
- Use connection pooling

## 📊 Monitoring and Debugging

### 1. View Logs
- Go to Vercel Dashboard → Project → Functions
- Click on function to view logs

### 2. Performance Monitoring
- Use Vercel Analytics
- Monitor function execution times
- Check memory usage

### 3. Database Monitoring
- Monitor database connection pool
- Check query performance
- Use database provider's monitoring tools

## 🚀 Production Optimizations

### 1. Performance
- Enable compression (already configured)
- Use connection pooling (configured)
- Implement caching where appropriate

### 2. Security
- Use strong JWT secrets
- Enable HTTPS only
- Implement rate limiting
- Validate all inputs

### 3. Monitoring
- Set up alerts for errors
- Monitor API response times
- Track database performance

## 🔐 Security Checklist

- [ ] JWT secret is strong and unique
- [ ] Database credentials are secure
- [ ] API keys are not exposed in frontend
- [ ] CORS is properly configured
- [ ] HTTPS is enforced
- [ ] Input validation is implemented
- [ ] Rate limiting is configured
- [ ] Error messages don't expose sensitive info

## 📞 Support and Alternatives

### If Vercel Doesn't Work:
1. **Render.com** (Recommended):
   - Your app is already configured
   - Better Java support
   - Follow `README_DEPLOYMENT.md`

2. **Railway**:
   - Good Java support
   - Easy deployment
   - Automatic HTTPS

3. **Heroku**:
   - Traditional Java hosting
   - Well-documented
   - Many add-ons available

### Getting Help:
- **Vercel Docs**: https://vercel.com/docs
- **Spring Boot**: https://spring.io/guides
- **Java on Vercel**: https://vercel.com/docs/functions/serverless-functions/runtimes/java

## 📈 Next Steps

1. **Monitor Performance**: Set up monitoring and alerting
2. **Implement CI/CD**: Automate deployments
3. **Scale Database**: Upgrade database plan as needed
4. **Add CDN**: Use Vercel Edge Network for static assets
5. **Implement Caching**: Add Redis or similar for session management

## 🎉 Success Indicators

✅ **Backend Health Check**: `https://your-backend-app.vercel.app/actuator/health` returns 200
✅ **API Endpoints**: All API endpoints respond correctly
✅ **Database Connection**: Application connects to database successfully
✅ **CORS Working**: Frontend can make API calls without CORS errors
✅ **Authentication**: JWT tokens work correctly
✅ **File Upload**: File uploads work (via S3)
✅ **Email/SMS**: Notifications are sent successfully

Your iTech backend should now be successfully deployed on Vercel! 🚀
