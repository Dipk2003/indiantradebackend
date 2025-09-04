# 🚀 iTech Backend - AWS Deployment Instructions

## Prerequisites
- AWS CLI installed and configured
- EB CLI installed (`pip install awsebcli`)
- Docker installed locally

## Step 1: Prepare Application
```bash
# Navigate to backend directory
cd D:\itech-backend\itech-backend

# Make script executable (if on Linux/Mac)
chmod +x deploy-backend-aws.sh

# Run deployment preparation
./deploy-backend-aws.sh
```

## Step 2: Initialize Elastic Beanstalk
```bash
# Initialize EB application
eb init -p docker itech-backend

# Create environment
eb create itech-backend-prod \
  --instance-type t3.medium \
  --min-instances 1 \
  --max-instances 5 \
  --envvars-file backend-env-variables.txt
```

## Step 3: Configure Environment Variables
Go to AWS Console → Elastic Beanstalk → itech-backend-prod → Configuration → Environment Properties

Add all variables from `backend-env-variables.txt`

## Step 4: Deploy Application
```bash
# Deploy to Elastic Beanstalk
eb deploy itech-backend-prod

# Check deployment status
eb status itech-backend-prod

# View logs
eb logs itech-backend-prod
```

## Step 5: Configure Database Connection
Update these environment variables with actual RDS endpoint:
```
SPRING_DATASOURCE_URL=jdbc:mysql://itech-mysql-prod.xyz.rds.amazonaws.com:3306/itech_db
SPRING_DATASOURCE_USERNAME=admin
SPRING_DATASOURCE_PASSWORD=YourActualPassword
```

## Step 6: Configure Load Balancer & Auto Scaling
```bash
# Configure load balancer
eb config itech-backend-prod
# Set Application Load Balancer, Health check path: /actuator/health
```

## Step 7: Setup Domain & SSL
```bash
# Configure custom domain (optional)
# Go to AWS Route 53 or your domain provider
# Point your domain to EB environment URL
```

## Verification Commands
```bash
# Check application health
curl https://your-eb-url.elasticbeanstalk.com/actuator/health

# Test API endpoint
curl https://your-eb-url.elasticbeanstalk.com/api/v1/health
```

## Troubleshooting
- Check logs: `eb logs itech-backend-prod --all`
- SSH to instance: `eb ssh itech-backend-prod`
- Restart application: `eb deploy itech-backend-prod --staged`
