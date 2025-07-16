# iTech Backend - Render.com Deployment

## 🚀 Quick Start

Your backend is now ready for deployment on Render.com! All necessary Docker configuration files have been created.

## 📁 Files Created

- `Dockerfile` - Multi-stage Docker build optimized for production
- `render.yaml` - Render.com deployment configuration
- `start.sh` - Application startup script
- `docker-compose.yml` - Local development setup
- `build-and-test.sh` - Local testing script
- `RENDER_DEPLOYMENT_GUIDE.md` - Detailed deployment guide

## 🛠️ Prerequisites

1. **GitHub Repository**: Push your code to a GitHub repository
2. **Render Account**: Sign up at [render.com](https://render.com)
3. **Environment Variables**: Have your API keys and secrets ready

## 🎯 Deployment Steps

### 1. Push to GitHub
```bash
cd D:\itech-backend\itech-backend
git add .
git commit -m "Add Docker configuration for Render deployment"
git push origin main
```

### 2. Create Database on Render
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click "New" → "PostgreSQL"
3. Configure:
   - **Name**: `itech-mysql`
   - **Database**: `itech_db_prod`
   - **User**: `itech_user`
   - **Region**: Ohio
   - **Plan**: Starter (Free)

### 3. Deploy Web Service
1. Click "New" → "Web Service"
2. Connect GitHub repository
3. Configure:
   - **Name**: `itech-backend`
   - **Environment**: Docker
   - **Branch**: main
   - **Region**: Ohio
   - **Plan**: Starter (Free)

### 4. Set Environment Variables

#### Required Variables:
```
SPRING_PROFILES_ACTIVE=production
JWT_SECRET=your-secure-jwt-secret-key
JWT_EXPIRATION=86400000
ALLOWED_ORIGINS=https://your-frontend-domain.com
```

#### Database (Auto-configured):
```
DATABASE_URL=(from database connection)
DB_USERNAME=(from database connection)
DB_PASSWORD=(from database connection)
```

#### Email Configuration:
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

#### SMS Configuration (Optional):
```
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_PHONE_NUMBER=your-twilio-phone
```

#### Quicko API Configuration:
```
QUICKO_API_BASE_URL=https://api.quicko.com
QUICKO_API_KEY=your-quicko-api-key
QUICKO_API_ENABLED=true
```

### 5. Deploy and Monitor
1. Click "Create Web Service"
2. Monitor build logs
3. Test endpoints once deployed

## 🧪 Local Testing

Before deploying, test locally:

```bash
# Make the script executable
chmod +x build-and-test.sh

# Run the test
./build-and-test.sh
```

Or manually:
```bash
# Build Docker image
docker build -t itech-backend:latest .

# Run with Docker Compose
docker-compose up
```

## 🔗 Post-Deployment

### 1. Update Frontend
Update your frontend API configuration:
```javascript
// In your frontend config
const API_BASE_URL = 'https://your-app-name.onrender.com';
```

### 2. Test Endpoints
- Health: `https://your-app-name.onrender.com/actuator/health`
- API: `https://your-app-name.onrender.com/api/...`

### 3. Update CORS
Add your frontend domain to `ALLOWED_ORIGINS`:
```
ALLOWED_ORIGINS=https://your-frontend-domain.com,https://www.your-frontend-domain.com
```

## 📊 Monitoring

### Health Checks
- Path: `/actuator/health`
- Interval: 30 seconds
- Timeout: 3 seconds

### Logs
Access logs in Render dashboard or use:
```bash
# If using Render CLI
render logs -s your-service-name
```

## 🔧 Configuration

### Database Support
- ✅ PostgreSQL (Render default)
- ✅ MySQL (for local development)
- Auto-detection based on DATABASE_URL

### Memory Settings
- JVM: 512MB max, 256MB initial
- Garbage Collection: G1GC
- String Deduplication: Enabled

### Security
- Non-root user in container
- Secure session cookies
- HTTPS enforced
- CORS properly configured

## 🐛 Troubleshooting

### Common Issues:

1. **Build Fails**
   - Check Java 21 compatibility
   - Verify all dependencies in pom.xml
   - Check Docker build logs

2. **Database Connection**
   - Verify DATABASE_URL format
   - Check database is running
   - Ensure network connectivity

3. **Application Won't Start**
   - Check environment variables
   - Verify JWT_SECRET is set
   - Check application logs

### Debug Commands:
```bash
# View container logs
docker logs container-name

# Test health endpoint
curl https://your-app-name.onrender.com/actuator/health

# Check environment variables
# (In Render dashboard → Environment tab)
```

## 📈 Performance Tips

### For Production:
1. Upgrade to paid plan for:
   - Always-on service
   - More memory (1GB+)
   - Better CPU
   - SSD storage

2. Database optimization:
   - Connection pooling (configured)
   - Index optimization
   - Query optimization

3. Monitoring:
   - Set up alerts
   - Monitor response times
   - Track error rates

## 🔐 Security Checklist

- [ ] JWT secret is secure and unique
- [ ] Database credentials are protected
- [ ] API keys are not exposed
- [ ] CORS is properly configured
- [ ] HTTPS is enabled
- [ ] Input validation is implemented
- [ ] Security headers are set

## 🔄 CI/CD Setup

For automated deployments:
1. Connect GitHub repository
2. Enable auto-deploy on push
3. Set up branch protection
4. Configure environment promotion

## 📞 Support

- **Render Docs**: https://render.com/docs
- **Spring Boot**: https://spring.io/projects/spring-boot
- **Application Issues**: Check logs in Render dashboard

## 🎉 Success!

Your backend is now deployed and ready for production use! 

🌐 **Your API URL**: `https://your-app-name.onrender.com`

Remember to update your frontend configuration with the new API URL.
