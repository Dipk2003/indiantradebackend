# Render.com Deployment Guide for itech-backend

## Overview
This guide will walk you through deploying your Spring Boot backend to Render.com using Docker.

## Prerequisites
1. GitHub repository with your backend code
2. Render.com account (free tier available)
3. Your database and API credentials ready

## Step-by-Step Deployment

### 1. Prepare Your Repository
Ensure your repository contains:
- `Dockerfile` (optimized for production)
- `render.yaml` (deployment configuration)
- `start.sh` (startup script)
- All source code in `src/` directory
- `pom.xml` with all dependencies

### 2. Database Setup on Render

1. **Create MySQL Database:**
   - Go to your Render dashboard
   - Click "New" → "PostgreSQL" (Note: Render uses PostgreSQL, not MySQL)
   - Database name: `itech_db_prod`
   - Region: Ohio (or your preferred region)
   - Plan: Starter (free tier)

2. **Update Application Properties:**
   Since Render uses PostgreSQL, you'll need to update your `application-production.properties`:

```properties
# Database Configuration (PostgreSQL for Render)
spring.datasource.url=${DATABASE_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA Settings for PostgreSQL
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
```

### 3. Update Dependencies
Add PostgreSQL driver to your `pom.xml`:

```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

### 4. Deploy Web Service

1. **Create Web Service:**
   - Go to Render dashboard
   - Click "New" → "Web Service"
   - Connect your GitHub repository
   - Select the repository: `itech-backend`

2. **Configure Service:**
   - **Name:** `itech-backend`
   - **Environment:** `Docker`
   - **Region:** Ohio
   - **Branch:** `main`
   - **Dockerfile Path:** `./Dockerfile`
   - **Docker Context:** `./`

3. **Environment Variables:**
   Add these environment variables in Render dashboard:

   **Database:**
   - `DATABASE_URL`: (automatically provided by Render database)
   - `DB_USERNAME`: (automatically provided by Render database)
   - `DB_PASSWORD`: (automatically provided by Render database)

   **Application:**
   - `SPRING_PROFILES_ACTIVE`: `production`
   - `JWT_SECRET`: (generate a secure random string)
   - `JWT_EXPIRATION`: `86400000`
   - `ALLOWED_ORIGINS`: `https://your-frontend-domain.com`

   **Email (Gmail):**
   - `SMTP_HOST`: `smtp.gmail.com`
   - `SMTP_PORT`: `587`
   - `SMTP_USERNAME`: `your-email@gmail.com`
   - `SMTP_PASSWORD`: `your-app-password`

   **SMS (Twilio):**
   - `TWILIO_ACCOUNT_SID`: `your-account-sid`
   - `TWILIO_AUTH_TOKEN`: `your-auth-token`
   - `TWILIO_PHONE_NUMBER`: `your-phone-number`

   **Quicko API:**
   - `QUICKO_API_BASE_URL`: `https://api.quicko.com`
   - `QUICKO_API_KEY`: `your-api-key`
   - `QUICKO_API_ENABLED`: `true`

### 5. Health Check Configuration
- **Health Check Path:** `/actuator/health`
- **Port:** `8080`

### 6. Deploy
1. Click "Create Web Service"
2. Render will automatically build and deploy your application
3. Monitor the logs for any issues

## Post-Deployment

### 1. Test Your API
Once deployed, test your endpoints:
- Health check: `https://your-app-name.onrender.com/actuator/health`
- API endpoints: `https://your-app-name.onrender.com/api/...`

### 2. Update Frontend Configuration
Update your frontend to point to the new backend URL:
```javascript
const API_BASE_URL = 'https://your-app-name.onrender.com';
```

### 3. Configure CORS
Update the `ALLOWED_ORIGINS` environment variable with your frontend domain:
```
ALLOWED_ORIGINS=https://your-frontend-domain.com,https://www.your-frontend-domain.com
```

## Important Notes

### Database Migration
Since Render uses PostgreSQL instead of MySQL, you'll need to:
1. Export your MySQL data
2. Convert it to PostgreSQL format
3. Import it to your new Render database

### Free Tier Limitations
- Services sleep after 15 minutes of inactivity
- Limited to 750 hours per month
- 512MB RAM limit

### Scaling
For production, consider upgrading to paid plans for:
- Always-on services
- More memory and CPU
- Better performance

## Troubleshooting

### Common Issues:

1. **Build Failures:**
   - Check if all dependencies are in `pom.xml`
   - Ensure Java 21 compatibility

2. **Database Connection:**
   - Verify environment variables are set
   - Check if database is running
   - Ensure correct PostgreSQL dialect

3. **Application Startup:**
   - Check logs for specific error messages
   - Verify all required environment variables are set

### Logs Access:
- View logs in Render dashboard
- Use `kubectl logs` if needed

## Security Checklist

- [ ] JWT secret is properly set
- [ ] Database credentials are secure
- [ ] API keys are not exposed in logs
- [ ] HTTPS is enabled
- [ ] CORS is properly configured
- [ ] Input validation is implemented

## Monitoring

Set up monitoring for:
- Application health (`/actuator/health`)
- Database connectivity
- API response times
- Error rates

## Backup Strategy

1. **Database Backups:**
   - Render provides automated backups
   - Consider additional backup strategies for production

2. **File Uploads:**
   - Use cloud storage (AWS S3) for persistent file storage
   - Local storage in containers is ephemeral

## Support

If you encounter issues:
1. Check Render documentation
2. Review application logs
3. Verify environment variables
4. Test locally with Docker

## Next Steps

1. Set up CI/CD pipeline for automated deployments
2. Configure monitoring and alerting
3. Implement proper logging strategy
4. Set up staging environment
5. Configure SSL certificates (automatic with Render)

---

**Note:** This deployment uses the free tier of Render. For production workloads, consider upgrading to paid plans for better performance and reliability.
