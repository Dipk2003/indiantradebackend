# 🚀 ITech B2B Marketplace - Complete AWS Deployment Guide

## 📋 **Overview**
This guide will help you deploy your complete B2B marketplace (backend + frontend) to AWS with proper domain setup, SSL certificates, and production-ready configuration.

## 🏗️ **Architecture Overview**
- **Frontend**: Next.js 15 app deployed on AWS Amplify/S3+CloudFront
- **Backend**: Spring Boot app on AWS Elastic Beanstalk/ECS
- **Database**: AWS RDS (MySQL)
- **Cache**: AWS ElastiCache (Redis)
- **Storage**: AWS S3 for file uploads
- **Domain**: Route 53 for DNS management
- **SSL**: AWS Certificate Manager

## 📝 **Prerequisites**
- AWS Account with billing enabled
- Domain name (purchased from any registrar)
- AWS CLI installed and configured
- Docker installed locally
- Git repository access

---

## 🗄️ **Step 1: Setup AWS RDS Database**

### 1.1 Create RDS MySQL Instance
```bash
# Create DB subnet group
aws rds create-db-subnet-group \
    --db-subnet-group-name itech-db-subnet-group \
    --db-subnet-group-description "ITech DB Subnet Group" \
    --subnet-ids subnet-12345678 subnet-87654321 \
    --region ap-south-1

# Create RDS instance
aws rds create-db-instance \
    --db-instance-identifier itech-db \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.0.35 \
    --master-username itechadmin \
    --master-user-password "YourSecurePassword123!" \
    --allocated-storage 20 \
    --db-name itech_db \
    --vpc-security-group-ids sg-your-security-group \
    --db-subnet-group-name itech-db-subnet-group \
    --backup-retention-period 7 \
    --multi-az false \
    --publicly-accessible true \
    --region ap-south-1
```

### 1.2 Configure Security Group
```bash
# Allow MySQL access from your application
aws ec2 authorize-security-group-ingress \
    --group-id sg-your-security-group \
    --protocol tcp \
    --port 3306 \
    --cidr 0.0.0.0/0
```

### 1.3 Get RDS Endpoint
```bash
aws rds describe-db-instances --db-instance-identifier itech-db
# Note down the endpoint URL (e.g., itech-db.xyz.ap-south-1.rds.amazonaws.com)
```

---

## 💾 **Step 2: Setup Redis Cache (ElastiCache)**

### 2.1 Create Redis Cluster
```bash
# Create cache subnet group
aws elasticache create-cache-subnet-group \
    --cache-subnet-group-name itech-redis-subnet-group \
    --cache-subnet-group-description "ITech Redis Subnet Group" \
    --subnet-ids subnet-12345678 subnet-87654321

# Create Redis cluster
aws elasticache create-cache-cluster \
    --cache-cluster-id itech-redis \
    --cache-node-type cache.t3.micro \
    --engine redis \
    --num-cache-nodes 1 \
    --cache-subnet-group-name itech-redis-subnet-group \
    --security-group-ids sg-your-security-group
```

---

## 🏭 **Step 3: Deploy Backend to AWS**

### Option A: Using AWS Elastic Beanstalk (Recommended)

#### 3.1 Create Elastic Beanstalk Application
```bash
# Initialize EB in your backend directory
cd D:\itech-backend\itech-backend

# Install EB CLI
pip install awsebcli

# Initialize application
eb init itech-backend --platform java-17 --region ap-south-1

# Create environment
eb create itech-prod --instance-type t3.small --database
```

#### 3.2 Configure Environment Variables with Subdomain Support
Create `.ebextensions/01-environment.config`:
```yaml
option_settings:
  aws:elasticbeanstalk:application:environment:
    # Database Configuration
    DATABASE_URL: jdbc:mysql://your-rds-endpoint:3306/itech_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata
    JDBC_DATABASE_USERNAME: itechadmin
    JDBC_DATABASE_PASSWORD: YourSecurePassword123!
    
    # Cache Configuration
    REDIS_HOST: your-redis-endpoint
    REDIS_PORT: 6379
    
    # Security Configuration
    JWT_SECRET: YourSuperSecretJWTKeyForProductionThatIsAtLeast64CharactersLong
    
    # Payment Gateway
    RAZORPAY_KEY_ID: your_razorpay_key_id
    RAZORPAY_KEY_SECRET: your_razorpay_key_secret
    
    # File Storage
    AWS_S3_BUCKET: your-s3-bucket-name
    AWS_S3_REGION: ap-south-1
    
    # Email Configuration
    EMAIL_HOST: smtp.gmail.com
    EMAIL_USERNAME: your-email@gmail.com
    EMAIL_PASSWORD: your-app-password
    
    # CORS Configuration for All Subdomains
    CORS_ALLOWED_ORIGINS: https://indiantrademart.com,https://www.indiantrademart.com,https://vendor.indiantrademart.com,https://admin.indiantrademart.com,https://support.indiantrademart.com,https://directory.indiantrademart.com
    
    # Subdomain Configuration
    APP_SUBDOMAIN_ENABLED: true
    APP_SUBDOMAIN_BASE_DOMAIN: indiantrademart.com
    APP_SUBDOMAIN_DEFAULT_SUBDOMAIN: www
    
    # Application Profile
    SPRING_PROFILES_ACTIVE: production
```

#### 3.2.1 Configure Subdomain Properties
Create `.ebextensions/02-subdomain-config.config`:
```yaml
option_settings:
  aws:elasticbeanstalk:application:environment:
    # Subdomain Routing Configuration
    APP_SUBDOMAIN_VENDOR_NAME: vendor
    APP_SUBDOMAIN_VENDOR_DESCRIPTION: "Vendor Dashboard"
    APP_SUBDOMAIN_VENDOR_ENABLED: true
    
    APP_SUBDOMAIN_ADMIN_NAME: admin
    APP_SUBDOMAIN_ADMIN_DESCRIPTION: "Admin Panel"
    APP_SUBDOMAIN_ADMIN_ENABLED: true
    
    APP_SUBDOMAIN_SUPPORT_NAME: support
    APP_SUBDOMAIN_SUPPORT_DESCRIPTION: "Support Center"
    APP_SUBDOMAIN_SUPPORT_ENABLED: true
    
    APP_SUBDOMAIN_DIRECTORY_NAME: directory
    APP_SUBDOMAIN_DIRECTORY_DESCRIPTION: "Business Directory"
    APP_SUBDOMAIN_DIRECTORY_ENABLED: true
    
    # Reserved Subdomains (comma-separated)
    APP_SUBDOMAIN_RESERVED: "api,mail,ftp,cpanel,webmail,www,admin,support,help,blog,shop,store,news,cdn,media,static,assets,images,css,js,fonts,video,audio,download,upload,backup,test,staging,dev,beta,alpha,demo,sandbox"
    
    # CORS Configuration for Subdomains
    APP_SUBDOMAIN_CORS_ALLOWED_METHODS: "GET,POST,PUT,DELETE,PATCH,OPTIONS"
    APP_SUBDOMAIN_CORS_ALLOWED_HEADERS: "Authorization,Content-Type,X-Requested-With,X-Subdomain,Accept,Origin,Access-Control-Request-Method,Access-Control-Request-Headers"
    APP_SUBDOMAIN_CORS_ALLOW_CREDENTIALS: true
    APP_SUBDOMAIN_CORS_MAX_AGE: 3600
```

#### 3.3 Test Subdomain Configuration Locally

Before deploying to AWS, test subdomain routing locally:

1. **Update local hosts file** (for testing):
```bash
# Add to /etc/hosts (Linux/Mac) or C:\Windows\System32\drivers\etc\hosts (Windows)
127.0.0.1 localhost.com
127.0.0.1 vendor.localhost.com
127.0.0.1 admin.localhost.com
127.0.0.1 support.localhost.com
127.0.0.1 directory.localhost.com
```

2. **Run application with subdomain profile**:
```bash
java -jar target/itech-backend-0.0.1-SNAPSHOT.jar --spring.profiles.active=local,subdomain
```

3. **Test subdomain endpoints**:
```bash
# Test subdomain extraction
curl -H "Host: vendor.localhost.com" http://localhost:8080/api/subdomain/info
curl -H "Host: admin.localhost.com" http://localhost:8080/api/subdomain/info

# Test subdomain-aware authentication
curl -H "Host: vendor.localhost.com" -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"vendor@test.com","password":"password"}'
```

#### 3.4 Build and Deploy
```bash
# Build the application
mvn clean package -DskipTests

# Deploy to Elastic Beanstalk
eb deploy
```

### Option B: Using Docker on ECS

#### 3.1 Build and Push Docker Image
```bash
# Build Docker image
cd D:\itech-backend\itech-backend
docker build -t itech-backend:latest .

# Tag for ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin your-account-id.dkr.ecr.ap-south-1.amazonaws.com

# Create ECR repository
aws ecr create-repository --repository-name itech-backend --region ap-south-1

# Tag and push
docker tag itech-backend:latest your-account-id.dkr.ecr.ap-south-1.amazonaws.com/itech-backend:latest
docker push your-account-id.dkr.ecr.ap-south-1.amazonaws.com/itech-backend:latest
```

#### 3.2 Create ECS Task Definition
Create `task-definition.json`:
```json
{
  "family": "itech-backend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::your-account:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "itech-backend",
      "image": "your-account-id.dkr.ecr.ap-south-1.amazonaws.com/itech-backend:latest",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {"name": "DATABASE_URL", "value": "jdbc:mysql://your-rds-endpoint:3306/itech_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata"},
        {"name": "JDBC_DATABASE_USERNAME", "value": "itechadmin"},
        {"name": "JDBC_DATABASE_PASSWORD", "value": "YourSecurePassword123!"},
        {"name": "SPRING_PROFILES_ACTIVE", "value": "production"}
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/itech-backend",
          "awslogs-region": "ap-south-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

---

## 🌐 **Step 4: Deploy Frontend with Subdomain Support**

### 4.1 Frontend Subdomain Architecture
Your Next.js frontend needs to handle different subdomains and show appropriate dashboards:

- **Main Site** (`indiantrademart.com`): Public marketplace
- **Vendor** (`vendor.indiantrademart.com`): Vendor dashboard
- **Admin** (`admin.indiantrademart.com`): Admin panel
- **Support** (`support.indiantrademart.com`): Support center
- **Directory** (`directory.indiantrademart.com`): Business directory

### Option A: Single Amplify App with Subdomain Routing (Recommended)

#### 4.1.1 Setup Amplify with Custom Domain
```bash
# Install Amplify CLI
npm install -g @aws-amplify/cli

# Configure Amplify
amplify configure

# Initialize in frontend directory
cd "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main"
amplify init

# Add hosting
amplify add hosting
# Select: Amazon CloudFront and S3
```

#### 4.1.2 Configure Environment Variables
In AWS Amplify Console, add these environment variables:
```env
NEXT_PUBLIC_API_URL=https://api.indiantrademart.com
NEXT_PUBLIC_RAZORPAY_KEY_ID=your_razorpay_key_id
NEXT_PUBLIC_APP_ENV=production
NEXT_PUBLIC_BASE_DOMAIN=indiantrademart.com
NEXT_PUBLIC_SUBDOMAIN_ROUTING=true
```

#### 4.1.3 Create Subdomain Middleware for Next.js
Create `middleware.ts` in your frontend root:
```typescript
import { NextRequest, NextResponse } from 'next/server'

export function middleware(request: NextRequest) {
  const hostname = request.headers.get('host') || ''
  const url = request.nextUrl.clone()
  
  // Extract subdomain
  const subdomain = hostname.split('.')[0]
  
  // Route based on subdomain
  if (hostname.includes('vendor.indiantrademart.com')) {
    url.pathname = `/dashboard/vendor${url.pathname}`
    return NextResponse.rewrite(url)
  }
  
  if (hostname.includes('admin.indiantrademart.com')) {
    url.pathname = `/dashboard/admin${url.pathname}`
    return NextResponse.rewrite(url)
  }
  
  if (hostname.includes('support.indiantrademart.com')) {
    url.pathname = `/dashboard/support${url.pathname}`
    return NextResponse.rewrite(url)
  }
  
  if (hostname.includes('directory.indiantrademart.com')) {
    url.pathname = `/directory${url.pathname}`
    return NextResponse.rewrite(url)
  }
  
  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
}
```

#### 4.1.4 Deploy with Custom Domains
```bash
# Deploy the application
amplify publish

# Add custom domain (do this in Amplify Console)
# Domain: indiantrademart.com
# Subdomains: 
#   - www.indiantrademart.com
#   - vendor.indiantrademart.com  
#   - admin.indiantrademart.com
#   - support.indiantrademart.com
#   - directory.indiantrademart.com
```

### Option B: Multiple S3 + CloudFront Distributions

#### 4.2.1 Create Separate Builds for Each Subdomain
```bash
cd "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main"

# Create different build configurations
echo "NEXT_PUBLIC_SUBDOMAIN=main" > .env.production
echo "NEXT_PUBLIC_API_URL=https://api.indiantrademart.com" >> .env.production
npm run build
npm run export
mv out main-build

# Vendor build
echo "NEXT_PUBLIC_SUBDOMAIN=vendor" > .env.production
echo "NEXT_PUBLIC_API_URL=https://api.indiantrademart.com" >> .env.production
npm run build
npm run export
mv out vendor-build

# Admin build
echo "NEXT_PUBLIC_SUBDOMAIN=admin" > .env.production
echo "NEXT_PUBLIC_API_URL=https://api.indiantrademart.com" >> .env.production
npm run build
npm run export
mv out admin-build

# Support build
echo "NEXT_PUBLIC_SUBDOMAIN=support" > .env.production
echo "NEXT_PUBLIC_API_URL=https://api.indiantrademart.com" >> .env.production
npm run build
npm run export
mv out support-build

# Directory build
echo "NEXT_PUBLIC_SUBDOMAIN=directory" > .env.production
echo "NEXT_PUBLIC_API_URL=https://api.indiantrademart.com" >> .env.production
npm run build
npm run export
mv out directory-build
```

#### 4.2.2 Create S3 Buckets for Each Subdomain
```bash
# Main site
aws s3 mb s3://indiantrademart-com --region ap-south-1
aws s3 sync main-build/ s3://indiantrademart-com --delete

# Vendor subdomain
aws s3 mb s3://vendor-indiantrademart-com --region ap-south-1
aws s3 sync vendor-build/ s3://vendor-indiantrademart-com --delete

# Admin subdomain
aws s3 mb s3://admin-indiantrademart-com --region ap-south-1
aws s3 sync admin-build/ s3://admin-indiantrademart-com --delete

# Support subdomain
aws s3 mb s3://support-indiantrademart-com --region ap-south-1
aws s3 sync support-build/ s3://support-indiantrademart-com --delete

# Directory subdomain
aws s3 mb s3://directory-indiantrademart-com --region ap-south-1
aws s3 sync directory-build/ s3://directory-indiantrademart-com --delete
```

#### 4.2.3 Create CloudFront Distributions
```bash
# You'll need to create separate CloudFront distributions for each subdomain
# Use the AWS Console or CLI with distribution configs

# Main site distribution
aws cloudfront create-distribution --distribution-config file://main-distribution-config.json

# Vendor distribution  
aws cloudfront create-distribution --distribution-config file://vendor-distribution-config.json

# Admin distribution
aws cloudfront create-distribution --distribution-config file://admin-distribution-config.json

# Support distribution
aws cloudfront create-distribution --distribution-config file://support-distribution-config.json

# Directory distribution
aws cloudfront create-distribution --distribution-config file://directory-distribution-config.json
```

### Option B: Using S3 + CloudFront

#### 4.1 Create S3 Bucket
```bash
# Create bucket for static hosting
aws s3 mb s3://your-domain-com --region ap-south-1

# Enable static website hosting
aws s3 website s3://your-domain-com --index-document index.html --error-document error.html
```

#### 4.2 Build and Upload Frontend
```bash
cd "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main"

# Create production environment file
echo "NEXT_PUBLIC_API_URL=https://api.yourdomain.com" > .env.production
echo "NEXT_PUBLIC_RAZORPAY_KEY_ID=your_razorpay_key_id" >> .env.production

# Build for production
npm run build
npm run export

# Upload to S3
aws s3 sync out/ s3://your-domain-com --delete
```

#### 4.3 Create CloudFront Distribution
```bash
aws cloudfront create-distribution --distribution-config file://distribution-config.json
```

---

## 🌍 **Step 5: Setup Domain and SSL with Subdomains**

### 5.1 Configure Route 53 for Multi-Subdomain Setup
Your platform supports role-based subdomains:
- **Main Site**: `indiantrademart.com`
- **Vendor Dashboard**: `vendor.indiantrademart.com`
- **Admin Panel**: `admin.indiantrademart.com`
- **Support Center**: `support.indiantrademart.com`
- **Directory**: `directory.indiantrademart.com`
- **API Endpoints**: `api.indiantrademart.com`

#### 5.1.1 Create Hosted Zone
```bash
# Create hosted zone (if domain not already in Route 53)
aws route53 create-hosted-zone --name indiantrademart.com --caller-reference $(date +%s)

# Note the hosted zone ID from the output
echo "Save your Hosted Zone ID: Z123456789ABCDEF"
```

#### 5.1.2 Create DNS Records for All Subdomains
Create `subdomain-records.json`:
```json
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "indiantrademart.com",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "your-cloudfront-distribution.cloudfront.net",
          "EvaluateTargetHealth": false,
          "HostedZoneId": "Z2FDTNDATAQYW2"
        }
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "www.indiantrademart.com",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "your-cloudfront-distribution.cloudfront.net",
          "EvaluateTargetHealth": false,
          "HostedZoneId": "Z2FDTNDATAQYW2"
        }
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "vendor.indiantrademart.com",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "your-vendor-cloudfront.cloudfront.net",
          "EvaluateTargetHealth": false,
          "HostedZoneId": "Z2FDTNDATAQYW2"
        }
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "admin.indiantrademart.com",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "your-admin-cloudfront.cloudfront.net",
          "EvaluateTargetHealth": false,
          "HostedZoneId": "Z2FDTNDATAQYW2"
        }
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "support.indiantrademart.com",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "your-support-cloudfront.cloudfront.net",
          "EvaluateTargetHealth": false,
          "HostedZoneId": "Z2FDTNDATAQYW2"
        }
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "directory.indiantrademart.com",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "your-directory-cloudfront.cloudfront.net",
          "EvaluateTargetHealth": false,
          "HostedZoneId": "Z2FDTNDATAQYW2"
        }
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "api.indiantrademart.com",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "your-backend-elb.amazonaws.com",
          "EvaluateTargetHealth": false,
          "HostedZoneId": "Z35SXDOTRQ7X7K"
        }
      }
    }
  ]
}
```

#### 5.1.3 Apply DNS Records
```bash
# Apply all subdomain records
aws route53 change-resource-record-sets \
    --hosted-zone-id Z123456789ABCDEF \
    --change-batch file://subdomain-records.json
```

### 5.2 Request SSL Certificates for All Subdomains
```bash
# Request wildcard certificate for all subdomains
aws acm request-certificate \
    --domain-name indiantrademart.com \
    --subject-alternative-names "*.indiantrademart.com" \
    --validation-method DNS \
    --region us-east-1

# Note: Certificate must be in us-east-1 for CloudFront
# Get the certificate ARN from the output
echo "Save Certificate ARN: arn:aws:acm:us-east-1:123456789:certificate/12345678-1234-1234-1234-123456789012"
```

### 5.2.1 Validate SSL Certificate via DNS
After requesting the certificate, you'll need to add CNAME records for validation:

```bash
# Get certificate details to find validation records
aws acm describe-certificate \
    --certificate-arn arn:aws:acm:us-east-1:123456789:certificate/12345678-1234-1234-1234-123456789012 \
    --region us-east-1

# Add the CNAME validation records to Route 53
# (The exact records will be provided in the certificate details)
```

### 5.3 Configure Custom Domain for Backend
If using Elastic Beanstalk:
```bash
# Add custom domain configuration
eb config
```

---

## 📊 **Step 6: Configure Monitoring and Logging**

### 6.1 Setup CloudWatch Alarms
```bash
# CPU utilization alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "ITech-Backend-CPU-High" \
    --alarm-description "Alert when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold
```

### 6.2 Setup Log Groups
```bash
# Create log groups
aws logs create-log-group --log-group-name /aws/elasticbeanstalk/itech-backend/var/log/eb-docker/containers/eb-current-app
```

---

## 🔐 **Step 7: Security Configuration**

### 7.1 Configure WAF
```bash
# Create WAF web ACL
aws wafv2 create-web-acl \
    --name ITech-Protection \
    --scope CLOUDFRONT \
    --default-action Allow={} \
    --rules file://waf-rules.json \
    --region us-east-1
```

### 7.2 Setup IAM Roles
Create IAM role for EC2 instances:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::your-s3-bucket/*"
    }
  ]
}
```

---

## 🧪 **Step 8: Testing and Validation**

### 8.1 Health Check URLs
- **Backend Health**: `https://api.yourdomain.com/actuator/health`
- **Frontend Health**: `https://yourdomain.com`
- **Database Connection**: Check application logs

### 8.2 API Testing
```bash
# Test authentication endpoint
curl -X POST https://api.yourdomain.com/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"test123"}'

# Test product search
curl "https://api.yourdomain.com/api/products/search?query=laptop"
```

---

## 🔄 **Step 9: CI/CD Pipeline Setup**

### 9.1 GitHub Actions for Backend
Create `.github/workflows/deploy-backend.yml`:
```yaml
name: Deploy Backend to AWS

on:
  push:
    branches: [ main ]
    paths: [ 'backend/**' ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Java
        uses: actions/setup-java@v2
        with:
          java-version: '21'
          
      - name: Build with Maven
        run: |
          cd backend
          mvn clean package -DskipTests
          
      - name: Deploy to EB
        uses: einaregilsson/beanstalk-deploy@v20
        with:
          aws_access_key: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws_secret_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          application_name: itech-backend
          environment_name: itech-prod
          region: ap-south-1
          version_label: ${{ github.sha }}
          deployment_package: backend/target/itech-backend-0.0.1-SNAPSHOT.jar
```

### 9.2 GitHub Actions for Frontend
Create `.github/workflows/deploy-frontend.yml`:
```yaml
name: Deploy Frontend to AWS

on:
  push:
    branches: [ main ]
    paths: [ 'frontend/**' ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '18'
          
      - name: Install and Build
        run: |
          cd frontend
          npm install
          npm run build
          
      - name: Deploy to Amplify
        uses: aws-amplify/amplify-cli-action@v0.3.0
        with:
          amplify_command: publish
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

---

## 🏁 **Final Steps**

### 10.1 Domain Configuration
1. Point your domain's nameservers to Route 53
2. Wait for DNS propagation (up to 48 hours)
3. Verify SSL certificates are properly configured

### 10.2 Performance Optimization
```bash
# Enable gzip compression on CloudFront
# Configure cache headers
# Setup auto-scaling groups
```

### 10.3 Backup Strategy
```bash
# Setup automated RDS snapshots
aws rds modify-db-instance \
    --db-instance-identifier itech-db \
    --backup-retention-period 7 \
    --preferred-backup-window "03:00-04:00"

# Setup S3 versioning
aws s3api put-bucket-versioning \
    --bucket your-s3-bucket \
    --versioning-configuration Status=Enabled
```

---

## 📋 **Environment Variables Checklist**

### Backend Environment Variables
- ✅ `DATABASE_URL`
- ✅ `JDBC_DATABASE_USERNAME`
- ✅ `JDBC_DATABASE_PASSWORD`
- ✅ `REDIS_HOST`
- ✅ `REDIS_PORT`
- ✅ `JWT_SECRET`
- ✅ `RAZORPAY_KEY_ID`
- ✅ `RAZORPAY_KEY_SECRET`
- ✅ `AWS_S3_BUCKET`
- ✅ `EMAIL_USERNAME`
- ✅ `EMAIL_PASSWORD`
- ✅ `CORS_ALLOWED_ORIGINS`

### Frontend Environment Variables
- ✅ `NEXT_PUBLIC_API_URL`
- ✅ `NEXT_PUBLIC_RAZORPAY_KEY_ID`
- ✅ `NEXT_PUBLIC_APP_ENV`

---

## 🚀 **Post-Deployment Checklist**

- [ ] Backend health check passes
- [ ] Frontend loads correctly
- [ ] Database connection works
- [ ] Redis cache is connected
- [ ] File upload to S3 works
- [ ] Email service is functional
- [ ] Payment gateway integration works
- [ ] SSL certificates are valid
- [ ] Domain resolves correctly
- [ ] API endpoints respond correctly
- [ ] Authentication flow works
- [ ] Search functionality works
- [ ] Order placement works
- [ ] Monitoring and alerts are set up

---

## 🆘 **Troubleshooting**

### Subdomain-Specific Issues:

**Subdomain detection not working in backend:**
```bash
# Test subdomain middleware
curl -v -H "Host: vendor.indiantrademart.com" https://api.indiantrademart.com/api/subdomain/info

# Check subdomain extraction in logs
eb logs --all | grep -i subdomain

# Verify subdomain configuration
curl https://api.indiantrademart.com/actuator/configprops | grep subdomain
```

**Frontend subdomain routing issues:**
```bash
# Test subdomain-specific builds
curl -H "Host: vendor.indiantrademart.com" https://vendor.indiantrademart.com
curl -H "Host: admin.indiantrademart.com" https://admin.indiantrademart.com

# Check Next.js middleware logs in browser console
# Navigate to: vendor.indiantrademart.com
# Open browser dev tools → Console
# Look for middleware execution logs
```

**SSL certificate issues for subdomains:**
```bash
# Verify wildcard certificate covers all subdomains
openssl s_client -connect vendor.indiantrademart.com:443 -servername vendor.indiantrademart.com
openssl s_client -connect admin.indiantrademart.com:443 -servername admin.indiantrademart.com

# Check certificate in browser
# Visit each subdomain and check SSL certificate details
```

**CORS issues with subdomains:**
```bash
# Test CORS preflight for each subdomain
curl -X OPTIONS -H "Origin: https://vendor.indiantrademart.com" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type,Authorization" \
  https://api.indiantrademart.com/api/auth/login

# Verify CORS_ALLOWED_ORIGINS includes all subdomains
eb config | grep CORS_ALLOWED_ORIGINS
```

**DNS propagation issues:**
```bash
# Check DNS records for all subdomains
nslookup vendor.indiantrademart.com
nslookup admin.indiantrademart.com
nslookup support.indiantrademart.com
nslookup directory.indiantrademart.com

# Test from different DNS servers
nslookup vendor.indiantrademart.com 8.8.8.8
nslookup vendor.indiantrademart.com 1.1.1.1

# Check DNS propagation globally
# Use online tools like whatsmydns.net
```

### Common Issues:

**Backend not starting:**
```bash
# Check EB logs
eb logs

# Check environment variables
eb config
```

**Database connection issues:**
```bash
# Test database connectivity
telnet your-rds-endpoint 3306
```

**CORS errors:**
- Verify `CORS_ALLOWED_ORIGINS` includes your frontend domain
- Check security groups allow traffic

**SSL certificate issues:**
- Verify DNS validation records are correctly set
- Wait for certificate validation (can take up to 30 minutes)

---

## 💰 **Cost Estimation**
- **RDS (t3.micro)**: ~$15/month
- **ElastiCache (t3.micro)**: ~$15/month
- **Elastic Beanstalk (t3.small)**: ~$25/month
- **S3 Storage**: ~$5/month
- **CloudFront**: ~$10/month
- **Route 53**: ~$1/month
- **Total**: ~$71/month

---

## 🎯 **Success Criteria**
Your deployment is successful when:
1. ✅ https://indiantrademart.com loads your React frontend
2. ✅ https://api.indiantrademart.com/actuator/health returns 200 OK
3. ✅ https://vendor.indiantrademart.com loads vendor dashboard
4. ✅ https://admin.indiantrademart.com loads admin panel
5. ✅ https://support.indiantrademart.com loads support center
6. ✅ https://directory.indiantrademart.com loads business directory
7. ✅ Users can register, login, and place orders on appropriate subdomains
8. ✅ Subdomain detection works in backend (returns correct subdomain info)
9. ✅ CORS allows requests from all configured subdomains
10. ✅ All critical APIs are responsive
11. ✅ SSL certificates are valid and green lock shows for all subdomains
12. ✅ DNS resolves correctly for all subdomains

### Subdomain-Specific Validation:
```bash
# Test all subdomains are accessible
curl -I https://indiantrademart.com
curl -I https://vendor.indiantrademart.com
curl -I https://admin.indiantrademart.com
curl -I https://support.indiantrademart.com
curl -I https://directory.indiantrademart.com
curl -I https://api.indiantrademart.com/actuator/health

# Test subdomain detection
curl -H "Host: vendor.indiantrademart.com" https://api.indiantrademart.com/api/subdomain/info

# Verify role-based access
# Login as vendor at vendor.indiantrademart.com
# Login as admin at admin.indiantrademart.com
```

**Your multi-subdomain B2B marketplace is now live on AWS! 🚀**

### Next Steps After Deployment:
1. 📊 **Monitor performance** using CloudWatch dashboards
2. 📝 **Review logs** regularly for any subdomain-related issues
3. 🔄 **Test failover scenarios** to ensure high availability
4. 💰 **Monitor costs** and optimize resource usage
5. 🔒 **Regular security updates** for all components
6. 📨 **Set up alerts** for subdomain-specific errors
7. 🚀 **Performance optimization** based on real user traffic
8. 📈 **Analytics setup** to track usage across different subdomains
