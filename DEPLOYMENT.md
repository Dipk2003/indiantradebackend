# Indian Trade Mart Backend - Production Deployment Guide

## 📋 Pre-Deployment Checklist

### System Requirements
- [ ] Java 21+ installed and configured
- [ ] Maven 3.8+ available
- [ ] PostgreSQL 13+ database server
- [ ] Redis 6+ cache server
- [ ] 4GB+ RAM available
- [ ] 20GB+ disk space

### Security Configuration
- [ ] Strong JWT secret key configured
- [ ] Database credentials secured
- [ ] Redis password set
- [ ] AWS credentials configured
- [ ] Email service credentials verified
- [ ] CORS origins properly configured
- [ ] SSL certificates installed (for HTTPS)

### Third-Party Services
- [ ] Razorpay payment gateway configured
- [ ] AWS S3 bucket created and accessible
- [ ] Email service (SMTP) configured and tested
- [ ] Domain name configured (if applicable)

## 🚀 Deployment Methods

### Method 1: Native Deployment (Recommended for VPS)

#### Step 1: Prepare the Environment
```bash
# Clone or upload the project
git clone <your-repository-url>
cd itech-backend

# Copy and configure environment
cp .env.example .env
# Edit .env with your production values
```

#### Step 2: Build and Deploy
```bash
# Make the deployment script executable
chmod +x deploy.sh

# Build the application
./deploy.sh build

# Start the application in background
./deploy.sh start --profile=prod --background
```

#### Step 3: Verify Deployment
```bash
# Check application status
./deploy.sh status

# View logs
./deploy.sh logs

# Test health endpoint
curl http://localhost:8080/actuator/health
```

### Method 2: Docker Deployment

#### Step 1: Prepare Docker Environment
```bash
# Copy environment configuration
cp .env.example .env
# Edit .env with your production values

# Build the Docker image
docker-compose build
```

#### Step 2: Deploy with Docker Compose
```bash
# Start all services (production profile)
docker-compose --profile production up -d

# Or start minimal services
docker-compose up -d itech-backend postgres redis
```

#### Step 3: Verify Docker Deployment
```bash
# Check running containers
docker-compose ps

# View application logs
docker-compose logs -f itech-backend

# Test the application
curl http://localhost:8080/actuator/health
```

### Method 3: Windows PowerShell Deployment

#### For Windows Environments:
```powershell
# Build the application
.\deploy.ps1 build

# Start in background
.\deploy.ps1 start -Profile prod -Background

# Check status
.\deploy.ps1 status
```

## 🔧 Configuration Management

### Database Setup
```sql
-- Create database and user
CREATE DATABASE itech_db;
CREATE USER itech_user WITH ENCRYPTED PASSWORD 'your-secure-password';
GRANT ALL PRIVILEGES ON DATABASE itech_db TO itech_user;

-- Grant schema permissions
\c itech_db;
GRANT ALL ON SCHEMA public TO itech_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO itech_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO itech_user;
```

### Redis Setup
```bash
# Start Redis with authentication
redis-server --requirepass your-redis-password

# Or edit redis.conf
requirepass your-redis-password
```

### Nginx Configuration (Optional)
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🔍 Monitoring and Maintenance

### Health Checks
```bash
# Application health
curl http://localhost:8080/actuator/health

# Detailed health information
curl http://localhost:8080/actuator/health/db
curl http://localhost:8080/actuator/health/redis
```

### Log Management
```bash
# View application logs
tail -f itech-backend.log

# View specific log levels
grep "ERROR" itech-backend.log
grep "WARN" itech-backend.log

# Rotate logs (setup logrotate)
sudo logrotate -f /etc/logrotate.d/itech-backend
```

### Performance Monitoring
```bash
# JVM metrics
curl http://localhost:8080/actuator/metrics/jvm.memory.used
curl http://localhost:8080/actuator/metrics/http.server.requests

# Custom business metrics
curl http://localhost:8080/actuator/metrics/custom.orders.created
curl http://localhost:8080/actuator/metrics/custom.users.active
```

## 🔄 Update and Maintenance Procedures

### Rolling Updates
```bash
# Method 1: Using deployment script
./deploy.sh stop
git pull origin main
./deploy.sh build
./deploy.sh start --background

# Method 2: Zero-downtime with Docker
docker-compose build itech-backend
docker-compose up -d --no-deps itech-backend
```

### Database Migrations
```bash
# Run Flyway migrations manually
mvn flyway:migrate -Dflyway.configFiles=src/main/resources/db/migration

# Or let Spring Boot handle migrations on startup
# (ensure spring.flyway.enabled=true in application.properties)
```

### Backup Procedures
```bash
# Database backup
pg_dump -h localhost -U itech_user -d itech_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Redis backup
redis-cli --rdb backup_$(date +%Y%m%d_%H%M%S).rdb

# Application files backup
tar -czf app_backup_$(date +%Y%m%d_%H%M%S).tar.gz /path/to/app
```

## 🚨 Troubleshooting

### Common Issues

#### Application Won't Start
1. Check Java version: `java -version`
2. Verify database connectivity: `pg_isready -h localhost -U itech_user`
3. Check Redis connectivity: `redis-cli ping`
4. Review application logs: `tail -100 itech-backend.log`

#### Out of Memory Errors
```bash
# Increase heap size
export JAVA_OPTS="-Xms1g -Xmx4g"
./deploy.sh restart --heap="-Xms1g -Xmx4g"
```

#### Database Connection Issues
```bash
# Test database connection
psql -h localhost -U itech_user -d itech_db -c "SELECT 1;"

# Check connection pool
curl http://localhost:8080/actuator/metrics/hikaricp.connections.active
```

#### Port Already in Use
```bash
# Find process using port 8080
netstat -tulpn | grep 8080
# Or on Windows
netstat -ano | findstr 8080

# Kill the process
kill -9 <PID>
```

## 📊 Performance Optimization

### JVM Tuning
```bash
# Production JVM settings
JAVA_OPTS="-Xms2g -Xmx4g"
JAVA_OPTS="$JAVA_OPTS -XX:+UseG1GC"
JAVA_OPTS="$JAVA_OPTS -XX:MaxGCPauseMillis=200"
JAVA_OPTS="$JAVA_OPTS -XX:+UseStringDeduplication"
JAVA_OPTS="$JAVA_OPTS -XX:+DisableExplicitGC"
```

### Database Optimization
```sql
-- Analyze table statistics
ANALYZE;

-- Create indexes for frequently queried columns
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_orders_status ON orders(status);
CREATE INDEX CONCURRENTLY idx_products_category ON products(category_id);
```

### Redis Optimization
```redis
# Redis configuration
maxmemory 1gb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
```

## 🔐 Security Hardening

### Application Security
- [ ] Change default JWT secret
- [ ] Enable HTTPS in production
- [ ] Configure proper CORS origins
- [ ] Set up rate limiting
- [ ] Enable SQL injection protection
- [ ] Configure XSS protection headers

### Infrastructure Security
- [ ] Use non-root user for application
- [ ] Configure firewall rules
- [ ] Set up regular security updates
- [ ] Enable audit logging
- [ ] Implement intrusion detection

### Monitoring and Alerting
- [ ] Set up application metrics monitoring
- [ ] Configure log aggregation
- [ ] Set up error rate alerting
- [ ] Monitor resource usage
- [ ] Set up uptime monitoring

## 📞 Support and Escalation

### Contact Information
- **Development Team**: dev@itech.com
- **Operations Team**: ops@itech.com
- **Emergency Contact**: +1-xxx-xxx-xxxx

### Escalation Procedures
1. **Level 1**: Application restart, basic troubleshooting
2. **Level 2**: Database/Redis issues, performance problems  
3. **Level 3**: Infrastructure issues, security incidents
4. **Level 4**: Business-critical outages, data loss

---

*Last Updated: $(date)*
*Version: 1.0.0*
