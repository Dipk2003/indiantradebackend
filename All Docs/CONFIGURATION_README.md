# iTech Backend - Configuration Setup Guide

This guide explains the cleaned up configuration setup for the iTech Backend project.

## ⚠️ IMPORTANT SECURITY NOTICE

**NEVER commit files with actual credentials to Git! Use environment variables in production.**

## Configuration Files Overview

The project now has a simplified configuration structure:

### Local Development
- **`.env`** - Local environment variables
- **`application.properties`** - Main Spring configuration (uses .env variables)

### Production Deployment
- **`.env.production`** - Production environment variables template (for Render.com)
- **`application-production.properties`** - Production Spring configuration

## Quick Setup

### For Local Development:
1. The `.env` file is already configured for local MySQL database
2. Update credentials in `.env` file as needed:
   - Database credentials
   - Email credentials
   - API keys
3. Run the application with default profile (uses `application.properties`)

### For Production (Render.com):
1. Copy values from `.env.production` to Render's Environment Variables
2. Set `SPRING_PROFILES_ACTIVE=production` in Render
3. Replace placeholder values with actual credentials

## Required Configuration Values

### Database Configuration
Replace these placeholders with your actual database credentials:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/your_database_name
spring.datasource.username=your_db_username
spring.datasource.password=your_db_password
```

### JWT Configuration
Replace with a strong secret key:
```properties
jwt.secret=your_jwt_secret_key_here
```

### Email Configuration
Replace with your email credentials:
```properties
spring.mail.username=your_email@gmail.com
spring.mail.password=your_app_password
```

### Twilio Configuration (for SMS)
Replace with your Twilio credentials:
```properties
twilio.account.sid=your_twilio_account_sid
twilio.auth.token=your_twilio_auth_token
twilio.phone.number=your_twilio_phone_number
```

## Files in Repository

✅ **Safe to commit:**
- `application.properties` (now uses environment variables)
- `application-production.properties` (now uses environment variables)
- `CONFIGURATION_README.md`
- `.gitignore`

❌ **NEVER commit:**
- `.env` (contains actual local credentials)
- `.env.production` (contains production credential templates)
- Any file with actual API keys or passwords

## Environment Variables Structure

### Local Development (.env)
Contains actual values for local development:
```bash
JWT_SECRET=your_actual_secret
SPRING_MAIL_PASSWORD=your_actual_password
RAZORPAY_KEY_ID=your_actual_key
# ... etc
```

### Production (.env.production)
Template for Render.com environment variables:
```bash
JWT_SECRET=your_production_secret
SPRING_MAIL_PASSWORD=your_production_password
RAZORPAY_KEY_ID=your_production_key
# ... etc
```

## Security Best Practices

1. **Use environment variables** in production
2. **Use strong passwords** and secrets
3. **Rotate secrets** regularly
4. **Restrict file permissions** on production servers
5. **Use different databases** for dev/staging/prod

## Need Help?

If you have issues:
1. Check the logs for error messages
2. Verify database connectivity
3. Ensure all required properties are set
4. Check network/firewall settings
