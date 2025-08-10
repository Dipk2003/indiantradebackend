# AWS Elastic Beanstalk Deployment Guide
## iTech Backend Spring Boot Application

This guide provides step-by-step instructions for deploying your iTech Backend application to AWS Elastic Beanstalk.

## 📋 Prerequisites

### 1. AWS Account Setup
- AWS account with appropriate permissions
- AWS CLI installed and configured
- EB CLI installed (`pip install awsebcli`)

### 2. Required AWS Services
- **RDS (PostgreSQL)** - Database
- **S3** - File storage
- **Elastic Beanstalk** - Application hosting
- **IAM** - Permissions management

## 🚀 Deployment Steps

### Step 1: Prepare Your Application
```bash
# Build the JAR file
mvn clean package -DskipTests

# Verify JAR file exists
ls -la target/itech-backend-0.0.1-SNAPSHOT.jar
```

### Step 2: Set Up AWS Resources

#### A. Create RDS Database
1. Go to AWS RDS Console
2. Create PostgreSQL database:
   - **Engine**: PostgreSQL 15+
   - **Instance Class**: db.t3.micro (for testing) or db.t3.small (for production)
   - **Storage**: 20 GB minimum
   - **Database Name**: `itech_db`
   - **Master Username**: `postgres`
   - **Master Password**: Create a secure password
   - **VPC**: Default VPC (or your custom VPC)
   - **Security Group**: Allow inbound connections on port 5432

#### B. Create S3 Bucket
1. Go to AWS S3 Console
2. Create bucket:
   - **Bucket Name**: `your-app-name-files` (must be globally unique)
   - **Region**: Same as your EB environment
   - **Block Public Access**: Configure based on your needs
   - **Versioning**: Enable (recommended)

#### C. Set Up IAM Roles
1. **EC2 Instance Profile** (for your EB instances):
   - Role Name: `aws-elasticbeanstalk-ec2-role`
   - Attach policies:
     - `AWSElasticBeanstalkWebTier`
     - `AWSElasticBeanstalkMulticontainerDocker`
     - Custom S3 policy for your bucket
     - Custom RDS policy for database access

2. **Elastic Beanstalk Service Role**:
   - Role Name: `aws-elasticbeanstalk-service-role`
   - Attach policy: `AWSElasticBeanstalkService`

### Step 3: Deploy to Elastic Beanstalk

#### Option A: Using EB CLI (Recommended)
```bash
# Make the deployment script executable
chmod +x deploy-to-aws-eb.sh

# Run the deployment script
./deploy-to-aws-eb.sh
```

#### Option B: Manual Deployment
```bash
# Initialize EB application
eb init itech-backend --region us-east-1 --platform "java-21-amazon-linux-2023"

# Create environment
eb create itech-backend-prod \
    --instance-type t3.medium \
    --min-instances 1 \
    --max-instances 4 \
    --envvars SPRING_PROFILES_ACTIVE=production

# Deploy the application
eb deploy
```

### Step 4: Configure Environment Variables

#### Using EB CLI:
```bash
eb setenv \
    DATABASE_URL=jdbc:postgresql://your-rds-endpoint:5432/itech_db \
    JDBC_DATABASE_USERNAME=postgres \
    JDBC_DATABASE_PASSWORD=your-secure-password \
    JWT_SECRET=your-very-long-secure-jwt-secret \
    ALLOWED_ORIGINS=https://your-frontend-domain.com \
    AWS_S3_BUCKET_NAME=your-s3-bucket-name
```

#### Using AWS Console:
1. Go to Elastic Beanstalk Console
2. Select your application and environment
3. Go to Configuration → Software
4. Add environment variables from `aws-eb-environment-variables.env`

## 🔒 Security Configuration

### Database Security
```bash
# Update RDS security group
aws ec2 authorize-security-group-ingress \
    --group-id sg-your-rds-security-group \
    --protocol tcp \
    --port 5432 \
    --source-group sg-your-eb-security-group
```

### S3 Bucket Policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::ACCOUNT-ID:role/aws-elasticbeanstalk-ec2-role"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::your-s3-bucket-name/*"
        }
    ]
}
```

## 📊 Monitoring and Health Checks

### Health Check Endpoint
Your application exposes health check at:
```
http://your-app.region.elasticbeanstalk.com/actuator/health
```

### Key Metrics to Monitor
- Application health status
- Database connection pool
- Memory usage
- Response times
- Error rates

### CloudWatch Logs
```bash
# View application logs
eb logs

# Stream logs in real-time
eb logs --stream
```

## 🔧 Environment Configuration Files

### 1. `.ebextensions/01-environment.config`
- JVM settings optimized for your application
- Health check configuration
- Auto-scaling settings
- Load balancer configuration

### 2. `aws-eb-environment-variables.env`
- Complete list of all required environment variables
- Security recommendations
- Configuration guidelines

## 📝 Environment Variables Reference

### Critical Variables (Must Set)
```bash
DATABASE_URL=jdbc:postgresql://your-rds-endpoint:5432/itech_db
JDBC_DATABASE_USERNAME=postgres
JDBC_DATABASE_PASSWORD=your-secure-password
JWT_SECRET=your-very-long-secure-jwt-secret
ALLOWED_ORIGINS=https://your-frontend-domain.com
```

### API Integration Variables
```bash
RAZORPAY_KEY_ID=your-razorpay-key-id
RAZORPAY_KEY_SECRET=your-razorpay-key-secret
TWILIO_ACCOUNT_SID=your-twilio-account-sid
TWILIO_AUTH_TOKEN=your-twilio-auth-token
OPENAI_API_KEY=your-openai-api-key
```

### Email Configuration
```bash
SPRING_MAIL_USERNAME=your-email@domain.com
SPRING_MAIL_PASSWORD=your-app-specific-password
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Database Connection Failed
- Check RDS security group allows connections from EB security group
- Verify DATABASE_URL format
- Ensure database credentials are correct

#### 2. Application Won't Start
```bash
# Check application logs
eb logs

# Check environment health
eb health

# Verify environment variables
eb printenv
```

#### 3. Health Check Failing
- Ensure `/actuator/health` endpoint is accessible
- Check application startup time (may need to increase timeout)
- Verify Spring Boot Actuator is configured correctly

#### 4. File Upload Issues
- Verify S3 bucket permissions
- Check IAM role has S3 access
- Confirm bucket name in environment variables

### Debugging Commands
```bash
# SSH into EB instance
eb ssh

# Check Java processes
eb ssh -c "ps aux | grep java"

# Check application logs on instance
eb ssh -c "tail -f /var/log/eb-docker/containers/eb-current-app/eb-stdouterr.log"
```

## 🔄 Updates and Maintenance

### Deploying Updates
```bash
# Build new JAR
mvn clean package -DskipTests

# Deploy update
eb deploy

# Monitor deployment
eb health --refresh
```

### Blue-Green Deployment
```bash
# Create new environment
eb create itech-backend-staging

# Test on staging environment
# If successful, swap environments
eb swap itech-backend-prod --destination-name itech-backend-staging
```

## 💰 Cost Optimization

### Recommended Instance Types
- **Development**: t3.micro
- **Testing**: t3.small
- **Production**: t3.medium or larger

### Auto-Scaling Configuration
- **Min Instances**: 1
- **Max Instances**: 4-6 (adjust based on traffic)
- **Scaling Triggers**: CPU > 70% or < 20%

## 📞 Support

### AWS Support Resources
- AWS Documentation: https://docs.aws.amazon.com/elasticbeanstalk/
- AWS Support Center: https://console.aws.amazon.com/support/
- Community Forums: https://forums.aws.amazon.com/

### Application Specific
- Application logs via `eb logs`
- Health dashboard in EB Console
- CloudWatch metrics and alarms

---

## ✅ Post-Deployment Checklist

- [ ] Application successfully deployed and running
- [ ] Health check endpoint responding
- [ ] Database connection established
- [ ] File upload/download working (S3 integration)
- [ ] Email sending functionality tested
- [ ] API integrations working (Razorpay, Twilio, etc.)
- [ ] CORS configured for frontend domains
- [ ] Environment variables properly set
- [ ] Security groups configured correctly
- [ ] SSL certificate configured (if using custom domain)
- [ ] Monitoring and alerts set up
- [ ] Backup strategy in place for RDS

Remember to never commit actual secrets to version control and use AWS Secrets Manager or Parameter Store for sensitive data in production environments.
