# Frontend-Backend Integration Reference
## Indian Trade Mart - Quick Setup Guide

---

## 📁 **Directory Structure**
```
Frontend: C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main
Backend:  D:\itech-backend\itech-backend
```

---

## 🔗 **API Integration**

### **Frontend Configuration**
```typescript
// Environment Variables (.env.production)
NEXT_PUBLIC_API_URL=https://indianmart.ap-south-1.elasticbeanstalk.com
NEXT_PUBLIC_WS_URL=wss://indianmart.ap-south-1.elasticbeanstalk.com
```

### **Backend Configuration**
```properties
# CORS Configuration
ALLOWED_ORIGINS=https://indiantrademart.com,https://www.indiantrademart.com,https://itm-main-fronted-c4l8.vercel.app
```

---

## 🗄️ **Database Configuration**

### **RDS PostgreSQL Setup**
```properties
# Production RDS
DATABASE_URL=jdbc:postgresql://your-rds-endpoint.ap-south-1.rds.amazonaws.com:5432/indiantrademart
JDBC_DATABASE_USERNAME=postgres
JDBC_DATABASE_PASSWORD=your-secure-password
```

### **Database Schema**
- Tables auto-created via JPA/Hibernate
- DDL mode: `update` (safe for production)
- Flyway migrations included for version control

---

## 🚀 **Deployment URLs**

### **Production**
- **Backend**: `https://indianmart.ap-south-1.elasticbeanstalk.com`
- **Frontend**: `https://your-domain.com` or Vercel URL
- **Database**: RDS PostgreSQL in `ap-south-1`

### **Health Checks**
- **Backend Health**: `/api/health`
- **Database Status**: Included in health endpoint

---

## 🔑 **Authentication Flow**

### **JWT Configuration**
```properties
JWT_SECRET=ITM_PROD_JWT_SECRET_[long-random-string]
JWT_EXPIRATION=86400000  # 24 hours
```

### **Frontend Auth Integration**
```typescript
// API calls with JWT
const token = localStorage.getItem('jwt_token');
const headers = { 
  'Authorization': `Bearer ${token}`,
  'Content-Type': 'application/json'
};
```

---

## 📄 **API Endpoints Structure**

### **Authentication**
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `POST /auth/refresh` - Token refresh
- `GET /auth/profile` - User profile

### **Core Business**
- `GET /api/products` - Product listings
- `POST /api/orders` - Create orders
- `GET /api/users/{id}` - User details
- `POST /api/files/upload` - File uploads

---

## 🔧 **Development Setup**

### **Local Development**
```bash
# Backend (Port 8080)
cd D:\itech-backend\itech-backend
./mvnw spring-boot:run

# Frontend (Port 3000)  
cd "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main"
npm run dev
```

### **Environment Files**
- **Backend**: `.env` (local), `.env.production` (prod), `.env.elastic-beanstalk` (EB)
- **Frontend**: `.env.local` (local), `.env.production` (prod), `.env.local.rds` (testing)

---

## 📦 **File Upload Integration**

### **S3 Configuration**
```properties
CLOUD_STORAGE_ENABLED=true
AWS_S3_BUCKET_NAME=indiantrademart-storage
AWS_S3_REGION=ap-south-1
```

### **Frontend Upload Component**
```typescript
const uploadFile = async (file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  
  const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/files/upload`, {
    method: 'POST',
    body: formData,
    headers: { 'Authorization': `Bearer ${token}` }
  });
  
  return response.json();
};
```

---

## 💳 **Payment Integration**

### **Razorpay Setup**
```properties
# Backend
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret

# Frontend
NEXT_PUBLIC_RAZORPAY_KEY_ID=your_razorpay_key_id
```

---

## 📧 **Email Service**

### **SMTP Configuration**
```properties
SPRING_MAIL_HOST=smtp.gmail.com
SPRING_MAIL_PORT=587
SPRING_MAIL_USERNAME=kyc@indiantrademart.com
SPRING_MAIL_PASSWORD=your-gmail-app-password
```

---

## 🔍 **Monitoring & Logging**

### **Application Logs**
```bash
# Production logs
eb logs --all

# Local development
tail -f logs/application.log
```

### **Health Monitoring**
- **Endpoint**: `GET /api/health`
- **Response**: Database status, disk space, memory usage
- **EB Health Dashboard**: Auto-monitoring

---

## 🛠️ **Common Commands**

### **Backend Deployment**
```bash
cd D:\itech-backend\itech-backend

# Build application
./mvnw clean package -DskipTests

# Deploy to EB
eb deploy

# View logs
eb logs --all
```

### **Frontend Deployment**
```bash
cd "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main"

# Build for production
npm run build

# Deploy (depends on your hosting)
vercel --prod  # or your deployment command
```

---

## 🚨 **Troubleshooting**

### **CORS Issues**
- Check `ALLOWED_ORIGINS` in backend
- Verify frontend URLs match exactly

### **Database Connection**
- Verify RDS security groups
- Check connection string format
- Test with telnet: `telnet rds-endpoint 5432`

### **Authentication Problems**
- JWT secret mismatch between environments
- Token expiration settings
- CORS preflight requests

### **File Upload Issues**
- S3 bucket permissions
- CORS policy on S3
- File size limits

---

## 📋 **Quick Deployment Checklist**

### **Backend**
- [ ] Application builds successfully
- [ ] Environment variables configured
- [ ] RDS database accessible
- [ ] S3 bucket created and configured
- [ ] Health check endpoint responding
- [ ] CORS configured for frontend domains

### **Frontend**
- [ ] API URLs point to production backend
- [ ] Environment variables set
- [ ] Build process completes
- [ ] Authentication flow working
- [ ] File upload functionality tested

### **Integration**
- [ ] API calls working end-to-end
- [ ] Database operations functioning
- [ ] File uploads to S3 working
- [ ] Email notifications sending
- [ ] Payment processing operational

---

## 🔗 **Useful Links**

- **AWS EB Console**: https://console.aws.amazon.com/elasticbeanstalk/
- **RDS Console**: https://console.aws.amazon.com/rds/
- **S3 Console**: https://console.aws.amazon.com/s3/
- **CloudWatch Logs**: https://console.aws.amazon.com/cloudwatch/

---

**Need Help?** Check the detailed deployment guide in `ELASTIC_BEANSTALK_RDS_DEPLOYMENT.md`
