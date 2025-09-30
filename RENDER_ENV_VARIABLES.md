# RENDER ENVIRONMENT VARIABLES FOR ITECH BACKEND

Copy these environment variables to your Render service settings:

## Core Application Settings
```
SPRING_PROFILES_ACTIVE=minimal
PORT=10000
```

## Database Configuration (PostgreSQL on Render)
```
JDBC_DATABASE_USERNAME=helloji_mufl_user
JDBC_DATABASE_PASSWORD=oaTUsJ3My5m0PGJxpfVpGtm77OiSUqDq
```

## CORS Configuration
```
ALLOWED_ORIGINS=https://indiantrademar.netlify.app
```

## JWT Configuration
```
JWT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5j6k7l8m9n0
```

## Email Configuration (Gmail SMTP)
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=ultimate.itech4@gmail.com
SMTP_PASSWORD=tqvipqgkpnxyuef
```

## Email Simulation Control
```
EMAIL_SIMULATION_ENABLED=false
email.simulation.enabled=false
```

## JVM Memory Optimization (Critical for 512MB Render)
```
JAVA_OPTS=-Xmx280m -Xms100m -XX:+UseSerialGC -XX:MaxDirectMemorySize=32m -XX:MaxMetaspaceSize=128m -XX:CompressedClassSpaceSize=32m -XX:ReservedCodeCacheSize=32m -XX:+UseCompressedOops -XX:+UseCompressedClassPointers -Djava.awt.headless=true -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Dspring.jmx.enabled=false -Dfile.encoding=UTF-8 -Djava.security.egd=file:/dev/./urandom -XX:+UnlockExperimentalVMOptions -XX:+UseContainerSupport
```

## Additional Spring Mail Properties (Optional)
```
SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_ENABLE=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_SSL_TRUST=smtp.gmail.com
```

---

## Key Changes Made:

### 1. **Fixed Migration Script Issue**
- **Problem**: MySQL syntax `AUTO_INCREMENT` was failing in PostgreSQL database
- **Solution**: Updated `V001__create_test_table.sql` to use PostgreSQL syntax:
  - `AUTO_INCREMENT` → `BIGSERIAL`
  - `INDEX` → `CREATE INDEX`
  - `ENGINE=InnoDB COMMENT=` → `COMMENT ON TABLE`

### 2. **Updated Properties Files**
- **Minimal Profile**: Optimized for 512MB Render deployment with PostgreSQL
- **Production Profile**: Added server port configuration and email settings
- **Database URL**: Updated to use PostgreSQL with SSL enabled

### 3. **Memory Optimization**
- JVM heap: 280MB max, 100MB initial
- Metaspace: 128MB limit
- Serial garbage collector for minimal memory usage
- Compressed OOPs enabled for 64-bit JVM efficiency

### 4. **CORS Configuration**
- Added Netlify domain: `https://indiantrademar.netlify.app`
- Proper CORS headers for frontend-backend communication

### 5. **Email Configuration**
- Gmail SMTP with app password
- Email simulation disabled for production
- SSL/TLS properly configured

---

## Deployment Steps:

1. **Add these environment variables** to your Render service
2. **Redeploy** your service on Render
3. **Test the registration endpoint** after deployment
4. **Check logs** for successful database migration

The PostgreSQL migration script fix should resolve the `AUTO_INCREMENT` syntax error that was causing the deployment failure.
