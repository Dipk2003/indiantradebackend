# iTech B2B Marketplace - AWS Deployment Guide

This comprehensive guide will help you deploy the iTech B2B Marketplace to AWS using Infrastructure as Code (Terraform), automated CI/CD pipelines, and best practices.

## 🏗️ Architecture Overview

The deployment creates the following AWS infrastructure:
- **VPC** with public/private subnets across multiple AZs
- **RDS MySQL** database in private subnets
- **ElastiCache Redis** for caching and sessions
- **Elastic Beanstalk** for backend Spring Boot application
- **AWS Amplify** for frontend Next.js application
- **S3 + CloudFront** for file storage and CDN
- **Application Load Balancer** with auto-scaling
- **CloudWatch** for monitoring and logging

## 🚀 Quick Start

### Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Terraform** (v1.5+) installed
4. **Java 17+** installed
5. **Node.js 18+** and npm installed
6. **Git** for version control

### 1. Clone and Setup

```bash
# Backend
git clone <your-backend-repo>
cd itech-backend

# Frontend (separate repo)
git clone <your-frontend-repo>
cd itm-main-fronted-main
```

### 2. Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region
```

### 3. Quick Deployment

```bash
# Make deployment script executable (Linux/Mac)
chmod +x deploy/deploy.sh
./deploy/deploy.sh

# Windows PowerShell
.\deploy\deploy.ps1
```

## 📋 Detailed Setup Instructions

### Step 1: Infrastructure Planning

1. **Choose AWS Region**: Default is `ap-south-1` (Mumbai)
2. **Domain Setup**: Register or transfer your domain
3. **Cost Planning**: Review `terraform/main.tf` for resource types

### Step 2: Terraform Configuration

1. **Copy variables file**:
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

2. **Edit `terraform/terraform.tfvars`**:
   ```hcl
   aws_region = "ap-south-1"
   environment = "production"
   domain_name = "yourdomain.com"
   db_username = "itech_admin"
   db_password = "YourSecurePassword123!"
   ```

3. **Initialize Terraform**:
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

### Step 3: Backend Deployment

1. **Build Application**:
   ```bash
   ./mvnw clean package -DskipTests
   ```

2. **Configure Environment**:
   - Update `.ebextensions/02-environment-variables.config`
   - Replace placeholder values with actual AWS resource endpoints

3. **Deploy to Elastic Beanstalk**:
   ```bash
   # Manual deployment
   eb init
   eb create production
   eb deploy
   
   # Or use deployment script
   ./deploy/deploy.sh --backend-only
   ```

### Step 4: Frontend Deployment

1. **Configure Environment**:
   - Update `.env.production` with actual backend URLs
   - Configure `amplify.yml` for build settings

2. **Deploy to AWS Amplify**:
   ```bash
   # Using Amplify Console (Recommended)
   # - Connect GitHub repo
   # - Configure build settings
   # - Deploy automatically on push
   
   # Or using Amplify CLI
   amplify init
   amplify add hosting
   amplify publish
   ```

### Step 5: Database Setup

1. **Flyway Migrations**: Automatic on backend startup
2. **Manual Migration** (if needed):
   ```bash
   ./mvnw flyway:migrate -Dspring.profiles.active=aws
   ```

## 🔧 Configuration Files

### Backend Configuration

**`application-aws.properties`**: Production Spring Boot config
- Database connection with RDS
- Redis configuration with ElastiCache  
- S3 file upload settings
- SES email configuration
- JWT and security settings

**`.ebextensions/`**: Elastic Beanstalk configuration
- JVM settings and memory allocation
- Load balancer and auto-scaling
- Environment variables
- CloudWatch monitoring

### Frontend Configuration

**`amplify.yml`**: Build and deployment settings
- Node.js environment setup
- Build commands and caching
- Security headers
- Redirect rules

**`.env.production`**: Production environment variables
- API endpoints
- Feature flags
- Analytics configuration

## 🚦 CI/CD Pipeline

### GitHub Actions Workflow

The `.github/workflows/deploy.yml` provides:

1. **Infrastructure Deployment** (Terraform)
2. **Backend Build & Deploy** (Maven + Elastic Beanstalk)
3. **Frontend Build & Deploy** (Next.js + Amplify)
4. **Database Migrations** (Flyway)
5. **Security Scanning** (Trivy)
6. **Smoke Tests** (API health checks)

### Required GitHub Secrets

```bash
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
DOMAIN_NAME=yourdomain.com
DB_PASSWORD=your_db_password
DB_USERNAME=itech_admin
API_BASE_URL=https://api.yourdomain.com
FRONTEND_URL=https://yourdomain.com
```

## 🔐 Security & Best Practices

### Infrastructure Security

1. **VPC**: Private subnets for database and cache
2. **Security Groups**: Restrictive inbound rules
3. **IAM Roles**: Least privilege access
4. **Encryption**: At-rest and in-transit encryption
5. **SSL/TLS**: HTTPS everywhere with ACM certificates

### Application Security

1. **Environment Variables**: Sensitive data in AWS Parameter Store
2. **CORS**: Configured for specific domains
3. **Authentication**: JWT with secure headers
4. **Rate Limiting**: API throttling enabled
5. **Monitoring**: CloudWatch alerts and logs

## 📊 Monitoring & Logging

### CloudWatch Integration

- **Application Metrics**: Custom metrics from Spring Boot
- **Infrastructure Metrics**: EC2, RDS, ElastiCache
- **Log Aggregation**: Application and system logs
- **Alerts**: Email/SMS notifications for issues

### Health Checks

- **Application Health**: Spring Boot Actuator endpoints
- **Database Health**: Connection pool monitoring  
- **Cache Health**: Redis connectivity checks
- **Load Balancer**: HTTP health checks

## 🛠️ Deployment Options

### 1. Full Automated Deployment
```bash
./deploy/deploy.sh
```

### 2. Infrastructure Only
```bash
./deploy/deploy.sh --infra-only
```

### 3. Backend Only
```bash
./deploy/deploy.sh --backend-only
```

### 4. Frontend Only
```bash
./deploy/deploy.sh --frontend-only
```

### 5. Manual Step-by-Step
```bash
# Infrastructure
cd terraform && terraform apply

# Backend
./mvnw clean package
eb deploy

# Frontend  
npm run build:production
amplify publish
```

## 💰 Cost Optimization

### Recommended Instance Types

- **Development**: `t3.micro` (Eligible for free tier)
- **Staging**: `t3.small` 
- **Production**: `t3.medium` or higher

### Cost Monitoring

1. **AWS Cost Explorer**: Monthly cost analysis
2. **Budgets**: Set spending alerts
3. **Resource Tagging**: Track costs by environment
4. **Auto-scaling**: Scale down during low usage

## 🚨 Troubleshooting

### Common Issues

1. **Terraform State Lock**:
   ```bash
   terraform force-unlock <lock-id>
   ```

2. **Elastic Beanstalk Deployment Failed**:
   ```bash
   eb logs
   eb status
   ```

3. **Database Connection Issues**:
   - Check security group rules
   - Verify RDS endpoint in environment variables
   - Confirm database credentials

4. **Frontend Build Errors**:
   - Check Node.js version compatibility
   - Verify environment variables
   - Clear npm cache: `npm cache clean --force`

### Debug Commands

```bash
# Check backend health
curl https://api.yourdomain.com/actuator/health

# Check database connectivity
curl https://api.yourdomain.com/actuator/health/db

# View backend logs
eb logs --all

# Check Terraform state
terraform show
terraform state list
```

## 📚 Additional Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Spring Boot on AWS](https://spring.io/guides/gs/spring-boot-aws/)
- [Next.js Deployment](https://nextjs.org/docs/deployment)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🤝 Support

For deployment issues:
1. Check this README first
2. Review application logs in CloudWatch
3. Create an issue in the repository
4. Contact the development team

## 📄 License

This deployment configuration is proprietary to iTech B2B Marketplace. See LICENSE file for details.

---

**Next Steps After Deployment:**
1. Configure custom domain in Route 53
2. Set up SSL certificates in ACM  
3. Configure monitoring alerts
4. Set up backup strategies
5. Document operational procedures
