# AWS Elastic Beanstalk Environment Variables Configuration

## 📋 Complete Environment Variables List for Production Deployment

### 🗄️ **Database Configuration (Required)**
```
DATABASE_URL=jdbc:postgresql://your-rds-endpoint:5432/your-database-name
JDBC_DATABASE_USERNAME=your_db_username
JDBC_DATABASE_PASSWORD=your_db_password
```

### 🔐 **Security & Authentication (Required)**
```
JWT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5j6k7l8m9n0
JWT_EXPIRATION=86400000
```

### 🌐 **CORS Configuration (Required)**
```
ALLOWED_ORIGINS=https://your-frontend-domain.com,https://www.your-frontend-domain.com
```

### 📧 **Email Configuration (Required)**
```
SPRING_MAIL_HOST=smtp.gmail.com
SPRING_MAIL_PORT=587
SPRING_MAIL_USERNAME=kyc@indiantrademart.com
SPRING_MAIL_PASSWORD=rgkrfwyecsyhttxa
SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_ENABLE=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_REQUIRED=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_SSL_PROTOCOLS=TLSv1.2
EMAIL_SIMULATION_ENABLED=false
```

### 📱 **SMS Configuration (Optional)**
```
SMS_SIMULATION_ENABLED=true
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=+1234567890
TEXTLOCAL_API_KEY=your_textlocal_api_key
MSG91_API_KEY=your_msg91_api_key
MSG91_TEMPLATE_ID=your_template_id
```

### 💳 **Payment Gateway (Required)**
```
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
RAZORPAY_WEBHOOK_SECRET=your_webhook_secret
```

### ☁️ **AWS S3 Configuration (Required)**
```
CLOUD_STORAGE_ENABLED=true
AWS_S3_BUCKET_NAME=your-s3-bucket-name
AWS_S3_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-aws-access-key-id
AWS_SECRET_ACCESS_KEY=your-aws-secret-access-key
```

### 🤖 **OpenAI Configuration (Required)**
```
OPENAI_API_KEY=your-openai-api-key-here
```

### 🏛️ **Government API Verification (Optional)**
```
GST_VERIFICATION_ENABLED=false
GST_API_URL=https://api.gst-verification.com
GST_API_KEY=your-gst-api-key
PAN_VERIFICATION_ENABLED=false
PAN_API_URL=https://api.pan-verification.com
PAN_API_KEY=your-pan-api-key
GST_MANAGEMENT_ENABLED=true
GST_VALIDATION_ENABLED=true
```

### 🧾 **Accounting Integration (Optional)**
```
QUICKO_API_BASE_URL=https://api.quicko.com
QUICKO_API_KEY=your_quicko_api_key
QUICKO_API_ENABLED=true
QUICKO_API_TIMEOUT=30
QUICKO_API_RETRY_ATTEMPTS=3
QUICKO_API_RETRY_DELAY=1000
```

### 📊 **Logging Configuration**
```
LOGGING_LEVEL_COM_ITECH=INFO
LOGGING_LEVEL_SPRING_SECURITY=WARN
LOGGING_LEVEL_ROOT=INFO
MAIL_DEBUG=false
```

### 🎯 **Application Settings**
```
SPRING_PROFILES_ACTIVE=production
PORT=5000
```

## 🚀 **How to Set Environment Variables in Elastic Beanstalk**

### Method 1: AWS Console
1. Go to AWS Elastic Beanstalk Console
2. Select your application
3. Go to Configuration → Software
4. Scroll down to "Environment properties"
5. Add each variable as Key-Value pairs

### Method 2: EB CLI
```bash
eb setenv DATABASE_URL="jdbc:postgresql://your-endpoint:5432/dbname" JWT_SECRET="your-jwt-secret" RAZORPAY_KEY_ID="your-key"
```

### Method 3: .ebextensions Configuration
Create `.ebextensions/environment.config`:
```yaml
option_settings:
  aws:elasticbeanstalk:application:environment:
    SPRING_PROFILES_ACTIVE: production
    DATABASE_URL: "jdbc:postgresql://your-endpoint:5432/dbname"
    JWT_SECRET: "your-jwt-secret"
    # Add other variables here
```

## 🔒 **Security Recommendations**

1. **Database Credentials**: Use AWS RDS and IAM roles when possible
2. **JWT Secret**: Generate a strong, unique secret for production
3. **API Keys**: Store sensitive keys in AWS Systems Manager Parameter Store
4. **Email Password**: Use App Passwords for Gmail
5. **S3 Access**: Use IAM roles instead of access keys when possible

## 📝 **Required AWS Services**

1. **RDS PostgreSQL** - Database
2. **S3 Bucket** - File storage
3. **SES** (Optional) - Email service alternative to Gmail
4. **Systems Manager** (Recommended) - Secure parameter storage

## ⚠️ **Important Notes**

1. Replace all placeholder values with actual credentials
2. Ensure your RDS instance is accessible from Elastic Beanstalk
3. Configure security groups properly
4. Test email configuration in staging first
5. Monitor logs in CloudWatch for any configuration issues

## 🔄 **Deployment Checklist**

- [ ] Database connection tested
- [ ] JWT secret configured
- [ ] Email service working
- [ ] Payment gateway configured
- [ ] S3 bucket accessible
- [ ] OpenAI API key valid
- [ ] CORS origins updated
- [ ] All required environment variables set
- [ ] Health check endpoint responding
- [ ] Application logs monitored
