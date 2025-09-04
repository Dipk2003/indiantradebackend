# 🚀 iTech Complete AWS Deployment Instructions

## ✅ COMPLETED STEPS

### Backend Preparation ✅
- [x] Spring Boot application built successfully
- [x] JAR file created: `application.jar` (134MB)
- [x] Dockerfile created for AWS Elastic Beanstalk
- [x] Dockerrun.aws.json configured
- [x] All files ready in `deployment-backend/` folder

### Frontend Preparation ✅
- [x] amplify.yml configuration file already exists
- [x] Next.js build scripts configured
- [x] Environment variables template ready

---

## 🔧 NEXT STEPS TO DEPLOY

### Step 1: Install AWS CLI & EB CLI (if not installed)
```powershell
# Install AWS CLI
winget install Amazon.AWSCLI

# Install EB CLI
pip install awsebcli

# Configure AWS credentials
aws configure
```

### Step 2: Deploy Backend to Elastic Beanstalk
```powershell
# Navigate to deployment directory
cd D:\itech-backend\itech-backend\deployment-backend

# Initialize Elastic Beanstalk application
eb init -p docker itech-backend --region ap-south-1

# Create production environment
eb create itech-backend-prod --instance-type t3.medium --region ap-south-1

# Deploy application
eb deploy itech-backend-prod
```

### Step 3: Configure Environment Variables for Backend
Go to AWS Console → Elastic Beanstalk → itech-backend-prod → Configuration → Environment Properties

**Add these variables:**
```
SERVER_PORT=8080
SPRING_PROFILES_ACTIVE=aws-prod
SPRING_DATASOURCE_URL=jdbc:mysql://your-rds-endpoint:3306/itech_db
SPRING_DATASOURCE_USERNAME=admin
SPRING_DATASOURCE_PASSWORD=your-password
JWT_SECRET=YourSecretKey64CharactersLong
CORS_ALLOWED_ORIGINS=https://your-frontend-domain.com
```

### Step 4: Deploy Frontend to AWS Amplify

#### Option A: Via AWS Console (Recommended)
1. Go to AWS Amplify Console
2. Click "New app" → "Host web app"
3. Connect to GitHub repository containing frontend code
4. Repository: Point to your frontend folder
5. Build settings will auto-detect from `amplify.yml`

#### Option B: Via AWS CLI
```powershell
# Navigate to frontend directory
cd "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main"

# Create Amplify app (requires GitHub repository)
aws amplify create-app --name itech-frontend --repository https://github.com/your-username/itech-frontend

# Create branch and deploy
aws amplify create-branch --app-id your-app-id --branch-name main
```

### Step 5: Configure Frontend Environment Variables
In AWS Amplify Console → App settings → Environment variables:

```
NEXT_PUBLIC_API_BASE_URL=https://your-eb-url.elasticbeanstalk.com
NODE_ENV=production
NODE_OPTIONS=--max-old-space-size=8192
NEXT_TELEMETRY_DISABLED=1
```

---

## 🗄️ DATABASE SETUP

### Create RDS MySQL Database
```bash
aws rds create-db-instance \
  --db-instance-identifier itech-mysql-prod \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --engine-version 8.0 \
  --allocated-storage 20 \
  --db-name itech_db \
  --master-username admin \
  --master-user-password YourSecurePassword123 \
  --region ap-south-1
```

---

## 📋 VERIFICATION CHECKLIST

### Backend Verification
- [ ] Elastic Beanstalk application deployed successfully
- [ ] Health check: `https://your-eb-url.elasticbeanstalk.com/actuator/health`
- [ ] API test: `https://your-eb-url.elasticbeanstalk.com/api/v1/health`
- [ ] Database connection working
- [ ] Environment variables configured

### Frontend Verification
- [ ] Amplify application deployed successfully
- [ ] Website accessible: `https://your-app-id.amplifyapp.com`
- [ ] API calls working from frontend
- [ ] Authentication flow working
- [ ] Build logs show no errors

---

## 🔧 TROUBLESHOOTING

### Backend Issues
```powershell
# Check EB logs
eb logs itech-backend-prod --all

# SSH into instance
eb ssh itech-backend-prod

# Redeploy if needed
eb deploy itech-backend-prod
```

### Frontend Issues
- Check Amplify build logs in console
- Verify environment variables
- Check browser developer tools for API errors

---

## 💰 ESTIMATED COSTS (Monthly)
- Elastic Beanstalk (t3.medium): ~$35
- RDS MySQL (db.t3.micro): ~$18
- AWS Amplify: ~$5
- Total: **~$58/month**

---

## 📞 SUPPORT CONTACTS
- Backend URL: Will be provided after EB deployment
- Frontend URL: Will be provided after Amplify deployment
- Database: Will be created during RDS setup

## 🎯 CURRENT STATUS
✅ **Backend files ready for deployment**
✅ **Frontend configuration ready**
⏳ **Waiting for AWS CLI setup and deployment execution**

**Next Action Required:** Install AWS CLI and execute deployment commands above.
