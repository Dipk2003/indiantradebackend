# iTech Backend - AWS Elastic Beanstalk Deployment Guide

This guide will help you deploy your iTech Backend to AWS Elastic Beanstalk with RDS MySQL database.

## Prerequisites

### 1. AWS Account Setup
- Create an AWS account if you don't have one
- Install and configure AWS CLI
- Install EB CLI (Elastic Beanstalk CLI)

### 2. Install Required Tools

```bash
# Install AWS CLI (Windows)
# Download from: https://aws.amazon.com/cli/

# Install EB CLI
pip install awsebcli

# Verify installations
aws --version
eb --version
```

### 3. Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key  
# Default region: us-west-2
# Default output format: json
```

## Database Setup (RDS MySQL)

### 1. Create RDS MySQL Instance

1. Go to AWS RDS Console
2. Click "Create database"
3. Choose "MySQL" as engine
4. Select "Free tier" template (for testing)
5. Configure:
   - DB instance identifier: `itechmart-db`
   - Master username: `itechmart_user`
   - Master password: `your-secure-password`
   - DB name: `itechmart`
6. Choose your VPC and security group
7. Create database

### 2. Configure Security Group

1. Go to EC2 Console → Security Groups
2. Find your RDS security group
3. Add inbound rule:
   - Type: MySQL/Aurora
   - Port: 3306
   - Source: Your Elastic Beanstalk security group

## Application Configuration

### 1. Update Environment Variables

Edit `.ebextensions/environment.config` and replace placeholders:

```yaml
# Database Configuration
SPRING_DATASOURCE_URL: jdbc:mysql://your-actual-rds-endpoint:3306/itechmart
SPRING_DATASOURCE_USERNAME: itechmart_user
SPRING_DATASOURCE_PASSWORD: your-actual-password

# JWT Configuration
JWT_SECRET: your-actual-jwt-secret-key-minimum-256-characters

# AWS S3 Configuration (create S3 bucket first)
AWS_S3_BUCKET_NAME: your-s3-bucket-name

# CORS Configuration
CORS_ALLOWED_ORIGINS: https://your-frontend-domain.com
```

### 2. Create S3 Bucket (Optional)

If your application uses file uploads:

1. Go to S3 Console
2. Create bucket with appropriate name
3. Configure bucket policy for public read if needed
4. Update `AWS_S3_BUCKET_NAME` in environment config

### 3. Set up SES for Email (Optional)

If using email features:

1. Go to SES Console
2. Verify your sender email address
3. Get SMTP credentials
4. Update email configuration in environment config

## Deployment Steps

### 1. Build the Application

```bash
# Clean and build
./mvnw clean package -DskipTests
```

### 2. Initialize Elastic Beanstalk

```bash
# Initialize EB application
eb init -p "Corretto 17" itech-backend --region us-west-2
```

### 3. Create Environment

```bash
# Create environment
eb create itech-backend-prod --instance-type t3.medium
```

### 4. Deploy Application

```bash
# Deploy using the provided script
chmod +x deploy-to-aws.sh
./deploy-to-aws.sh
```

Or deploy manually:

```bash
# Manual deployment
eb deploy
```

### 5. Configure Environment Variables

You can set environment variables via AWS Console:

1. Go to Elastic Beanstalk Console
2. Select your application
3. Go to Configuration → Software
4. Add environment properties as needed

## Post-Deployment Configuration

### 1. Health Checks

Verify your application is healthy:

```bash
# Check status
eb status

# View logs
eb logs

# Open application in browser
eb open
```

### 2. Database Migration

Your application will automatically create tables on first run due to `spring.jpa.hibernate.ddl-auto=update`.

### 3. SSL Certificate (Production)

For production, set up SSL:

1. Request SSL certificate via ACM (AWS Certificate Manager)
2. Configure load balancer to use HTTPS
3. Update security settings to require SSL

## Environment Variables Reference

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `SPRING_DATASOURCE_URL` | RDS MySQL connection string | `jdbc:mysql://db.region.rds.amazonaws.com:3306/itechmart` |
| `SPRING_DATASOURCE_USERNAME` | Database username | `itechmart_user` |
| `SPRING_DATASOURCE_PASSWORD` | Database password | `your-secure-password` |
| `JWT_SECRET` | JWT signing secret | `your-256-char-secret` |
| `CORS_ALLOWED_ORIGINS` | Frontend domain | `https://yourapp.com` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AWS_S3_BUCKET_NAME` | S3 bucket for file uploads | - |
| `SPRING_MAIL_HOST` | Email SMTP host | `email-smtp.us-west-2.amazonaws.com` |
| `SPRING_MAIL_USERNAME` | SES SMTP username | - |
| `SPRING_MAIL_PASSWORD` | SES SMTP password | - |
| `RAZORPAY_KEY_ID` | Razorpay payment key | - |
| `RAZORPAY_KEY_SECRET` | Razorpay payment secret | - |

## Monitoring and Troubleshooting

### 1. Application Logs

```bash
# View recent logs
eb logs

# Continuous log streaming
eb logs --all
```

### 2. Health Dashboard

- Go to Elastic Beanstalk Console
- Monitor application health, requests, and response times

### 3. CloudWatch Metrics

- CPU utilization
- Network traffic  
- Request count and latency
- Error rates

### 4. Common Issues

#### Database Connection Issues
- Check security groups allow port 3306
- Verify RDS endpoint and credentials
- Check VPC configuration

#### Application Not Starting
- Check Java version (should be 17)
- Verify JAR file is built correctly
- Check application logs for startup errors

#### CORS Issues
- Update `CORS_ALLOWED_ORIGINS` environment variable
- Check frontend domain configuration

## Scaling and Production Considerations

### 1. Auto Scaling

Configure auto scaling in EB Console:
- Minimum instances: 1
- Maximum instances: 4
- Scaling triggers based on CPU/network

### 2. Load Balancer

- Application Load Balancer is configured automatically
- Configure health check path: `/actuator/health`

### 3. Database Performance

- Monitor RDS performance
- Consider read replicas for high traffic
- Enable automated backups

### 4. Security Best Practices

- Use IAM roles instead of access keys when possible
- Enable VPC for network isolation
- Keep security groups restrictive
- Regular security updates

## Cost Optimization

- Use t3.micro for development/testing
- Enable auto scaling to handle traffic spikes
- Monitor CloudWatch for unused resources
- Consider Reserved Instances for predictable workloads

## Support and Maintenance

### 1. Updates and Deployments

```bash
# Deploy new version
eb deploy

# Rollback if needed
eb abort
```

### 2. Backup Strategy

- RDS automated backups (enabled by default)
- S3 versioning for file uploads
- Application configuration backups

### 3. Monitoring Setup

- CloudWatch alarms for critical metrics
- SNS notifications for alerts
- Regular health check monitoring

---

## Quick Start Checklist

- [ ] AWS account created and configured
- [ ] AWS CLI and EB CLI installed
- [ ] RDS MySQL database created
- [ ] Environment variables configured
- [ ] Application built successfully
- [ ] EB application initialized
- [ ] Environment created and deployed
- [ ] Database connectivity verified
- [ ] Frontend CORS configured
- [ ] SSL certificate configured (production)
- [ ] Monitoring and alerts set up

For additional support, refer to:
- [AWS Elastic Beanstalk Documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- [Spring Boot on AWS](https://spring.io/guides/gs/spring-boot-on-aws/)
- [Your API Documentation](./COMPLETE_API_DOCUMENTATION.md)
