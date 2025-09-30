# 🚀 UPDATED RENDER ENVIRONMENT VARIABLES FOR AWS INTEGRATION

Copy these **UPDATED** environment variables to your Render service:

## Core Settings:
```
SPRING_PROFILES_ACTIVE=minimal
PORT=10000
```

## Database (PostgreSQL):
```
JDBC_DATABASE_USERNAME=helloji_mufl_user
JDBC_DATABASE_PASSWORD=oaTUsJ3My5m0PGJxpfVpGtm77OiSUqDq
```

## 🔄 **UPDATED CORS - AWS Subdomains Support:**
```
ALLOWED_ORIGINS=https://indiantrademart.com,https://dir.indiantrademart.com,https://vendor.indiantrademart.com,https://admin.indiantrademart.com,https://support.indiantrademart.com,https://customer.indiantrademart.com
```

## JWT:
```
JWT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5j6k7l8m9n0
```

## Email (Gmail SMTP):
```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=ultimate.itech4@gmail.com
SMTP_PASSWORD=tqvipqgkpnxyuef
```

## Email Control:
```
EMAIL_SIMULATION_ENABLED=false
email.simulation.enabled=false
```

## JVM Memory (Critical for 512MB):
```
JAVA_OPTS=-Xmx280m -Xms100m -XX:+UseSerialGC -XX:MaxDirectMemorySize=32m -XX:MaxMetaspaceSize=128m -XX:CompressedClassSpaceSize=32m -XX:ReservedCodeCacheSize=32m -XX:+UseCompressedOops -XX:+UseCompressedClassPointers -Djava.awt.headless=true -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Dspring.jmx.enabled=false -Dfile.encoding=UTF-8 -Djava.security.egd=file:/dev/./urandom -XX:+UnlockExperimentalVMOPtions -XX:+UseContainerSupport
```

---

## 🚨 **IMPORTANT CHANGES:**

### **Main Change - CORS Origins:**
**OLD**: `https://indiantrademar.netlify.app` 
**NEW**: `https://indiantrademart.com,https://dir.indiantrademart.com,https://vendor.indiantrademart.com,https://admin.indiantrademart.com,https://support.indiantrademart.com,https://customer.indiantrademart.com`

### **What this enables:**
✅ Main domain: `indiantrademart.com`
✅ Directory: `dir.indiantrademart.com` 
✅ Vendor: `vendor.indiantrademart.com`
✅ Admin: `admin.indiantrademart.com` 
✅ Support: `support.indiantrademart.com`
✅ Customer: `customer.indiantrademart.com`

---

## 📋 **How to Update:**

1. Go to **Render Dashboard**
2. Click on your **itech-backend service**
3. Go to **Settings** → **Environment** 
4. **UPDATE** the `ALLOWED_ORIGINS` variable with the new value above
5. Click **Save Changes**
6. Service will **automatically redeploy** ✅

## ✅ **Backend Ready for AWS Frontend!**
