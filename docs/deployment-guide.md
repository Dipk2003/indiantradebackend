# ITech B2B Platform Deployment Guide

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Environment Setup](#environment-setup)
3. [Database Setup](#database-setup)
4. [Application Deployment](#application-deployment)
5. [Security Configuration](#security-configuration)
6. [Monitoring Setup](#monitoring-setup)
7. [Troubleshooting](#troubleshooting)

## System Requirements

### Hardware Requirements
- CPU: 4+ cores
- RAM: 16GB minimum
- Storage: 100GB SSD minimum

### Software Requirements
- Java 17 or higher
- PostgreSQL 13+
- Redis 6+
- Elasticsearch 7.x
- Node.js 16+ (for frontend)
- NGINX (for reverse proxy)
- Docker & Docker Compose

## Environment Setup

### 1. Backend Environment Variables
```bash
# Application
SPRING_PROFILES_ACTIVE=production
SERVER_PORT=8080
APP_BASE_URL=https://api.yourdomain.com

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=itech_db
DB_USERNAME=your_username
DB_PASSWORD=your_secure_password

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password

# Elasticsearch
ELASTICSEARCH_HOST=localhost
ELASTICSEARCH_PORT=9200

# Security
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRATION=1800000

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_email_password

# Storage
STORAGE_TYPE=s3
AWS_ACCESS_KEY=your_aws_access_key
AWS_SECRET_KEY=your_aws_secret_key
AWS_BUCKET_NAME=your_bucket_name
```

### 2. Frontend Environment Variables
```bash
NEXT_PUBLIC_API_URL=https://api.yourdomain.com
NEXT_PUBLIC_WEBSOCKET_URL=wss://api.yourdomain.com/ws
NEXT_PUBLIC_STORAGE_URL=https://storage.yourdomain.com
```

## Database Setup

### 1. PostgreSQL Setup
```sql
-- Create database
CREATE DATABASE itech_db;

-- Create user
CREATE USER itech_user WITH PASSWORD 'secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE itech_db TO itech_user;

-- Enable extensions
\c itech_db
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
```

### 2. Redis Setup
```bash
# Install Redis
sudo apt-get install redis-server

# Configure Redis
sudo nano /etc/redis/redis.conf

# Set password
requirepass your_redis_password

# Restart Redis
sudo systemctl restart redis
```

## Application Deployment

### 1. Backend Deployment

```bash
# Build application
./mvnw clean package -DskipTests

# Run using Docker
docker-compose up -d

# Or run directly using Java
java -jar target/itech-backend.jar --spring.profiles.active=production
```

### 2. Frontend Deployment

```bash
# Install dependencies
npm install

# Build application
npm run build

# Start production server
npm start
```

### 3. NGINX Configuration

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Security Configuration

### 1. SSL/TLS Setup
```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d yourdomain.com -d api.yourdomain.com
```

### 2. Firewall Configuration
```bash
# Allow necessary ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp
sudo ufw enable
```

### 3. Security Headers
Configure security headers in Spring Security and NGINX.

## Monitoring Setup

### 1. Prometheus & Grafana
```yaml
# docker-compose.monitoring.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=secure_admin_password
```

### 2. Logging
Configure ELK Stack (Elasticsearch, Logstash, Kibana) for log aggregation.

## Troubleshooting

### Common Issues and Solutions

1. Database Connection Issues
```bash
# Check database connection
psql -h localhost -U itech_user -d itech_db

# Check database logs
tail -f /var/log/postgresql/postgresql-13-main.log
```

2. Application Startup Issues
```bash
# Check application logs
tail -f logs/application.log

# Check system logs
journalctl -u itech-backend.service
```

3. Performance Issues
```bash
# Check system resources
htop

# Check disk usage
df -h

# Monitor application metrics
curl http://localhost:8080/actuator/metrics
```
