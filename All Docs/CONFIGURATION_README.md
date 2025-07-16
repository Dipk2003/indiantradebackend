# Configuration Setup Guide

This guide explains how to set up the application configuration files for the ITech Backend project.

## ⚠️ IMPORTANT SECURITY NOTICE

**NEVER commit actual configuration files containing sensitive data to Git!**

## Quick Setup

1. **Copy template files:**
   ```bash
   cp src/main/resources/application.properties.template src/main/resources/application.properties
   ```

2. **Edit the configuration files** with your actual values

3. **The .gitignore file** will prevent accidental commits of sensitive config files

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
- `application.properties.template`
- `CONFIGURATION_README.md`
- `.gitignore`

❌ **NEVER commit:**
- `application.properties`
- `application-production.properties`
- Any file with actual credentials

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
