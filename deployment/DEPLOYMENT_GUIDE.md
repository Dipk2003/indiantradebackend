# ITech B2B Platform Deployment Guide

## Overview

This guide provides comprehensive instructions for deploying the ITech B2B Platform, including both frontend and backend components, infrastructure setup, and monitoring configuration.

## System Requirements

### Production Environment
- CPU: 4+ cores
- RAM: 16GB minimum
- Storage: 100GB SSD
- OS: Ubuntu 20.04 LTS or later

### Development Environment
- CPU: 2+ cores
- RAM: 8GB minimum
- Storage: 50GB SSD
- OS: Windows/Linux/macOS

## Prerequisites

### Software Dependencies
- Java 17
- Node.js 18+
- Redis 6+
- PostgreSQL 13+
- Elasticsearch 7.x
- Docker 20+
- Nginx 1.18+

### Cloud Services
- AWS Account with following services:
  - EC2
  - S3
  - RDS
  - ElastiCache
  - CloudWatch
  - Route 53
- CI/CD Pipeline (GitHub Actions/Jenkins)

## Infrastructure Setup

### Database Setup

1. PostgreSQL Installation:
```bash
# Install PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib

# Create database
sudo -u postgres createdb itech_db

# Create user
sudo -u postgres createuser --interactive
```

2. Redis Setup:
```bash
# Install Redis
sudo apt install redis-server

# Configure Redis
sudo nano /etc/redis/redis.conf
# Set supervised to 'systemd'
# Set maxmemory-policy to 'allkeys-lru'

# Start Redis
sudo systemctl restart redis
```

3. Elasticsearch Setup:
```bash
# Install Elasticsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.0-amd64.deb
sudo dpkg -i elasticsearch-7.17.0-amd64.deb

# Configure Elasticsearch
sudo nano /etc/elasticsearch/elasticsearch.yml
# Set network.host: localhost
# Set discovery.type: single-node

# Start Elasticsearch
sudo systemctl start elasticsearch
```

## Backend Deployment

### Configuration

1. Environment Variables:
```properties
# Application
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080

# Database
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/itech_db
SPRING_DATASOURCE_USERNAME=itech_user
SPRING_DATASOURCE_PASSWORD=secure_password

# Redis
SPRING_REDIS_HOST=localhost
SPRING_REDIS_PORT=6379

# Elasticsearch
SPRING_ELASTICSEARCH_REST_URIS=http://localhost:9200

# JWT
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRATION=86400000

# AWS
AWS_ACCESS_KEY=your_aws_access_key
AWS_SECRET_KEY=your_aws_secret_key
AWS_REGION=us-east-1
AWS_S3_BUCKET=itech-uploads
```

2. Application Properties:
```yaml
# application-prod.yml
spring:
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        jdbc:
          batch_size: 50
        order_inserts: true
        order_updates: true
  cache:
    type: redis
    redis:
      time-to-live: 3600000
  servlet:
    multipart:
      max-file-size: 10MB
      max-request-size: 10MB

server:
  compression:
    enabled: true
    mime-types: application/json,application/xml,text/html,text/plain
    min-response-size: 1024

security:
  rate-limit:
    enabled: true
    max-requests: 100
    refresh-period: 60000
```

### Build and Deploy

1. Build JAR:
```bash
./mvnw clean package -DskipTests
```

2. Deploy using Docker:
```dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
```

3. Run Container:
```bash
docker build -t itech-backend .
docker run -d -p 8080:8080 --name itech-backend itech-backend
```

## Frontend Deployment

### Build Configuration

1. Environment Variables:
```env
# .env.production
NEXT_PUBLIC_API_URL=https://api.itech.com
NEXT_PUBLIC_WS_URL=wss://api.itech.com/ws
NEXT_PUBLIC_GOOGLE_ANALYTICS_ID=UA-XXXXXXXXX-X
```

2. Build Setup:
```bash
# Install dependencies
npm install

# Build for production
npm run build

# Start production server
npm start
```

### Nginx Configuration

```nginx
# /etc/nginx/sites-available/itech-frontend
server {
    listen 80;
    server_name itech.com www.itech.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /ws {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
}
```

## Monitoring Setup

### Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'spring-actuator'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['localhost:8080']
```

### Grafana Dashboards

1. System Metrics Dashboard:
   - CPU Usage
   - Memory Usage
   - Disk I/O
   - Network Traffic

2. Application Metrics Dashboard:
   - Request Rate
   - Response Times
   - Error Rates
   - Active Users

3. Business Metrics Dashboard:
   - Orders
   - Revenue
   - User Registrations
   - Product Listings

## Security Configuration

### SSL Setup

1. Generate SSL Certificate:
```bash
sudo certbot --nginx -d itech.com -d www.itech.com
```

2. Update Nginx Configuration:
```nginx
server {
    listen 443 ssl;
    server_name itech.com www.itech.com;

    ssl_certificate /etc/letsencrypt/live/itech.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/itech.com/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000" always;
}
```

## Backup Configuration

### Database Backup

1. Automated Backup Script:
```bash
#!/bin/bash
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/backup/postgres"
DB_NAME="itech_db"

# Create backup
pg_dump $DB_NAME | gzip > "$BACKUP_DIR/backup_$TIMESTAMP.sql.gz"

# Upload to S3
aws s3 cp "$BACKUP_DIR/backup_$TIMESTAMP.sql.gz" s3://itech-backups/postgres/

# Clean old backups (keep last 30 days)
find $BACKUP_DIR -type f -mtime +30 -delete
```

2. Schedule with Cron:
```bash
0 2 * * * /path/to/backup-script.sh
```

### File Backup

1. S3 Sync Script:
```bash
#!/bin/bash
aws s3 sync /path/to/uploads s3://itech-uploads/
```

## CI/CD Pipeline

### GitHub Actions Workflow

```yaml
name: ITech CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Set up JDK
      uses: actions/setup-java@v2
      with:
        java-version: '17'

    - name: Build Backend
      run: |
        ./mvnw clean package -DskipTests

    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '18'

    - name: Build Frontend
      run: |
        cd frontend
        npm install
        npm run build

    - name: Run Tests
      run: |
        ./mvnw test
        cd frontend
        npm test

    - name: Deploy
      if: github.ref == 'refs/heads/main'
      run: |
        # Add deployment scripts here
```

## Troubleshooting

### Common Issues

1. Database Connection Issues:
   - Check PostgreSQL logs: `/var/log/postgresql/postgresql-13-main.log`
   - Verify connection string and credentials
   - Check network connectivity

2. Redis Connection Issues:
   - Check Redis logs: `/var/log/redis/redis-server.log`
   - Verify Redis is running: `redis-cli ping`
   - Check memory usage: `redis-cli info memory`

3. Performance Issues:
   - Check JVM heap usage
   - Monitor database query performance
   - Review application logs
   - Check Nginx access logs

### Logging

1. Application Logs:
```bash
# Backend logs
tail -f /var/log/itech/application.log

# Frontend logs
pm2 logs itech-frontend

# Nginx logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

2. Log Aggregation:
   - Configure ELK Stack
   - Set up log rotation
   - Implement log archival

## Maintenance

### Regular Tasks

1. Daily:
   - Monitor system health
   - Review error logs
   - Check backup status

2. Weekly:
   - Review performance metrics
   - Clean temporary files
   - Update documentation

3. Monthly:
   - Security patches
   - SSL certificate check
   - Database optimization

### Scaling

1. Vertical Scaling:
   - Increase server resources
   - Optimize JVM settings
   - Tune database parameters

2. Horizontal Scaling:
   - Add application servers
   - Configure load balancer
   - Implement session replication

## Contact

For deployment support:
- Email: devops@itech.com
- Slack: #devops-support
- Emergency: +1-XXX-XXX-XXXX
