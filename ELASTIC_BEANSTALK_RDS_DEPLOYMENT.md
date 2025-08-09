# Elastic Beanstalk + RDS Deployment Guide
## Indian Trade Mart - Complete Setup Instructions

---

## 🎯 **Overview**
This guide will walk you through deploying the ITM backend to AWS Elastic Beanstalk with RDS PostgreSQL database integration.

### **Architecture**
- **Frontend**: Next.js deployed on Vercel/Custom domain
- **Backend**: Spring Boot on Elastic Beanstalk
- **Database**: RDS PostgreSQL
- **Storage**: S3 for file uploads
- **Region**: Asia Pacific (Mumbai) `ap-south-1`

---

## 📋 **Prerequisites**

### **1. AWS Account Setup**
- AWS Account with billing enabled
- AWS CLI installed and configured
- EB CLI installed

### **2. Install Required Tools**
```bash
# Install AWS CLI
# Download from: https://aws.amazon.com/cli/

# Install EB CLI
pip install awsebcli

# Verify installations
aws --version
eb --version
```

---

## 🚀 **Step-by-Step Deployment**

### **Step 1: Prepare the Application**

1. **Navigate to backend directory:**
```bash
cd "D:\itech-backend\itech-backend"
```

2. **Build the application:**
```bash
./mvnw clean package -DskipTests
```

### **Step 2: Initialize Elastic Beanstalk**

1. **Initialize EB application:**
```bash
eb init
```
- Choose region: `ap-south-1` (Asia Pacific Mumbai)
- Application name: `indiantrademart-backend`
- Platform: `Java`
- Platform version: `Java 21 running on 64bit Amazon Linux 2023`
- CodeCommit: `No`
- SSH: `Yes` (recommended)

2. **Create environment:**
```bash
eb create indianmart-prod
```
- Environment name: `indianmart-prod`
- DNS CNAME prefix: `indianmart`
- Load balancer: `Application Load Balancer`

### **Step 3: Set Up RDS Database**

#### **Option A: Through EB Console (Recommended)**
1. Go to AWS Elastic Beanstalk Console
2. Select your application → Environment
3. Configuration → Database
4. Click "Edit"
5. Configure:
   - Engine: `postgres`
   - Engine version: `15.4`
   - Instance class: `db.t3.micro` (free tier)
   - Storage: `20 GB`
   - Username: `postgres`
   - Password: `[secure-password]`
   - Database name: `indiantrademart`

#### **Option B: Separate RDS Instance (Production)**
```bash
# Create RDS instance separately for better control
aws rds create-db-instance \
    --db-instance-identifier indiantrademart-db \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 15.4 \
    --allocated-storage 20 \
    --master-username postgres \
    --master-user-password YOUR_SECURE_PASSWORD \
    --db-name indiantrademart \
    --vpc-security-group-ids sg-xxxxxxxxx \
    --region ap-south-1
```

### **Step 4: Configure Environment Variables**

1. **Set environment variables via EB Console:**
   - Go to Configuration → Software → Environment properties
   - Add variables from `.env.elastic-beanstalk` file

2. **Or use EB CLI:**
```bash
# Basic configuration
eb setenv SPRING_PROFILES_ACTIVE=production \
         PORT=5000 \
         JWT_SECRET="ITM_PROD_JWT_SECRET_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6" \
         ALLOWED_ORIGINS="https://indiantrademart.com,https://www.indiantrademart.com"

# Database (if using separate RDS)
eb setenv DATABASE_URL="jdbc:postgresql://your-rds-endpoint:5432/indiantrademart" \
         JDBC_DATABASE_USERNAME="postgres" \
         JDBC_DATABASE_PASSWORD="your-rds-password"

# Email
eb setenv SPRING_MAIL_HOST="smtp.gmail.com" \
         SPRING_MAIL_PORT="587" \
         SPRING_MAIL_USERNAME="kyc@indiantrademart.com" \
         SPRING_MAIL_PASSWORD="your-gmail-app-password"
```

### **Step 5: Deploy Application**

1. **Deploy to Elastic Beanstalk:**
```bash
eb deploy
```

2. **Monitor deployment:**
```bash
eb logs --all
```

3. **Open application:**
```bash
eb open
```

---

## 🔧 **Database Setup**

### **1. Create Database Schema**
Once deployed, the application will automatically create tables due to `spring.jpa.hibernate.ddl-auto=update`.

### **2. Manual Schema Setup (if needed)**
```sql
-- Connect to your RDS instance
psql -h your-rds-endpoint.ap-south-1.rds.amazonaws.com -U postgres -d indiantrademart

-- Example table creation (adjust based on your entities)
CREATE DATABASE indiantrademart;
```

### **3. Verify Database Connection**
```bash
# Check application logs
eb logs --all | grep -i database
```

---

## 🌐 **Frontend Configuration**

### **1. Update Frontend Environment**
Update your frontend `.env.production` with the EB URL:
```env
NEXT_PUBLIC_API_URL=https://indianmart.ap-south-1.elasticbeanstalk.com
NEXT_PUBLIC_WS_URL=wss://indianmart.ap-south-1.elasticbeanstalk.com
```

### **2. Deploy Frontend**
```bash
cd "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main"
npm run build
npm run deploy  # or your deployment command
```

---

## 🔐 **Security Configuration**

### **1. SSL Certificate**
- Use AWS Certificate Manager for free SSL certificates
- Configure in Load Balancer settings

### **2. Security Groups**
```bash
# Allow inbound traffic on port 80 and 443
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxxxx \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxxxx \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0
```

### **3. RDS Security Group**
- Allow inbound on port 5432 from EB security group
- Restrict access to EB instances only

---

## 📦 **S3 Bucket Setup**

### **1. Create S3 Bucket**
```bash
aws s3 mb s3://indiantrademart-storage --region ap-south-1
```

### **2. Configure CORS**
```json
[
    {
        "AllowedHeaders": ["*"],
        "AllowedMethods": ["GET", "POST", "PUT", "DELETE"],
        "AllowedOrigins": [
            "https://indiantrademart.com",
            "https://www.indiantrademart.com",
            "https://indianmart.ap-south-1.elasticbeanstalk.com"
        ],
        "ExposeHeaders": []
    }
]
```

### **3. Set Environment Variables**
```bash
eb setenv CLOUD_STORAGE_ENABLED=true \
         AWS_S3_BUCKET_NAME=indiantrademart-storage \
         AWS_S3_REGION=ap-south-1
```

---

## 🔍 **Health Checks & Monitoring**

### **1. Application Health Check**
The application includes a health endpoint at `/api/health` which EB uses for monitoring.

### **2. CloudWatch Logs**
```bash
# View logs
eb logs --all

# Stream logs in real-time
eb logs --all --stream
```

### **3. Application Metrics**
- CPU utilization
- Network I/O
- Request count
- Response times

---

## 🚨 **Troubleshooting**

### **Common Issues:**

1. **Database Connection Failed**
   - Check security groups
   - Verify RDS endpoint and credentials
   - Check VPC configuration

2. **Application Not Starting**
   - Review CloudWatch logs
   - Check Java version compatibility
   - Verify environment variables

3. **502 Bad Gateway**
   - Check if application is running on port 5000
   - Review nginx configuration
   - Check application logs

4. **CORS Issues**
   - Update `ALLOWED_ORIGINS` environment variable
   - Check frontend URLs

### **Debug Commands:**
```bash
# SSH into EB instance
eb ssh

# Check application logs
sudo tail -f /var/log/eb-engine.log
sudo tail -f /var/log/nginx/error.log

# Check Java process
sudo ps aux | grep java

# Test database connection
telnet your-rds-endpoint.ap-south-1.rds.amazonaws.com 5432
```

---

## 💰 **Cost Estimation**

### **Monthly AWS Costs (approximate):**
- **EB Environment (t3.small)**: $15-20
- **RDS (db.t3.micro)**: $15-20
- **S3 Storage**: $1-5
- **Data Transfer**: $5-10
- **Total**: ~$35-55/month

---

## 🔄 **Deployment Checklist**

- [ ] AWS CLI and EB CLI installed
- [ ] Application built successfully
- [ ] EB application initialized
- [ ] Environment created
- [ ] RDS database configured
- [ ] Environment variables set
- [ ] Application deployed
- [ ] Database schema created
- [ ] S3 bucket configured
- [ ] SSL certificate configured
- [ ] Health checks passing
- [ ] Frontend updated with backend URL
- [ ] CORS configured properly
- [ ] API endpoints tested
- [ ] File upload functionality tested

---

## 📞 **Support**

For deployment issues:
1. Check AWS CloudWatch logs
2. Review EB console for health status
3. Test individual components
4. Verify environment configuration

**Happy Deploying! 🚀**
