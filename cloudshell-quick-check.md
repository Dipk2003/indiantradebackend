# 🔍 AWS CloudShell Quick Deployment Status Check

## Step 1: Open AWS CloudShell
1. Login to AWS Console
2. Click on CloudShell icon (shell terminal) in the top navigation bar
3. Wait for CloudShell to initialize

## Step 2: Run These Commands

### 🔧 Check Backend (Elastic Beanstalk)
```bash
# Check if EB application exists
aws elasticbeanstalk describe-applications --application-names itech-backend --region ap-south-1

# Check environment status
aws elasticbeanstalk describe-environments --application-name itech-backend --region ap-south-1

# Get backend URL (if deployed)
aws elasticbeanstalk describe-environments \
    --application-name itech-backend \
    --environment-names itech-backend-prod \
    --query 'Environments[0].CNAME' \
    --output text \
    --region ap-south-1
```

### 🎨 Check Frontend (Amplify)
```bash
# List all Amplify apps
aws amplify list-apps --region ap-south-1

# Check specific Amplify app (if exists)
aws amplify list-apps --query 'apps[?name==`itech-frontend`]' --region ap-south-1
```

### 🗄️ Check Database (RDS)
```bash
# Check RDS instances
aws rds describe-db-instances --region ap-south-1

# Check specific database
aws rds describe-db-instances \
    --db-instance-identifier itech-mysql-prod \
    --region ap-south-1 \
    --query 'DBInstances[0].{Status:DBInstanceStatus,Endpoint:Endpoint.Address}'
```

### ☁️ Check S3 Buckets
```bash
# List all S3 buckets
aws s3 ls

# Check for iTech related buckets
aws s3 ls | grep itech
```

### 📊 Overall Status Summary
```bash
# One-liner to check all services
echo "=== BACKEND ===" && \
aws elasticbeanstalk describe-applications --application-names itech-backend --region ap-south-1 --query 'Applications[0].ApplicationName' --output text 2>/dev/null || echo "NOT DEPLOYED" && \
echo "=== FRONTEND ===" && \
aws amplify list-apps --region ap-south-1 --query 'length(apps)' --output text && \
echo "=== DATABASE ===" && \
aws rds describe-db-instances --db-instance-identifier itech-mysql-prod --region ap-south-1 --query 'DBInstances[0].DBInstanceStatus' --output text 2>/dev/null || echo "NOT CREATED"
```

## Step 3: Interpret Results

### ✅ If Deployed Successfully:
- **Backend**: You'll see application name and environment details
- **Frontend**: You'll see Amplify app ID and domain
- **Database**: You'll see "available" status and endpoint

### ❌ If Not Deployed:
- **Backend**: Error message "No application named 'itech-backend' found"
- **Frontend**: Empty array `[]` or "0" apps
- **Database**: Error message about instance not found

## Step 4: Get URLs (if deployed)

### Backend URL:
```bash
aws elasticbeanstalk describe-environments \
    --application-name itech-backend \
    --environment-names itech-backend-prod \
    --query 'Environments[0].CNAME' \
    --output text \
    --region ap-south-1
```

### Frontend URL:
```bash
aws amplify list-apps \
    --region ap-south-1 \
    --query 'apps[0].defaultDomain' \
    --output text
```

### Database Endpoint:
```bash
aws rds describe-db-instances \
    --db-instance-identifier itech-mysql-prod \
    --region ap-south-1 \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text
```

## Copy-Paste Ready Commands for CloudShell:

```bash
# Quick Status Check
echo "🔍 iTech Deployment Status Check" && \
echo "================================" && \
echo "🔧 Backend:" && \
aws elasticbeanstalk describe-applications --application-names itech-backend --region ap-south-1 --query 'Applications[0].ApplicationName' --output text 2>/dev/null || echo "❌ NOT DEPLOYED" && \
echo "🎨 Frontend:" && \
aws amplify list-apps --region ap-south-1 --query 'length(apps)' --output text 2>/dev/null && echo " Amplify apps found" && \
echo "🗄️ Database:" && \
aws rds describe-db-instances --db-instance-identifier itech-mysql-prod --region ap-south-1 --query 'DBInstances[0].DBInstanceStatus' --output text 2>/dev/null || echo "❌ NOT CREATED"
```
