# 🚀 Subdomain System Deployment Guide

Complete guide for deploying the subdomain routing system in production.

## 📋 Prerequisites

- Domain name registered (e.g., example.com)
- DNS control (Cloudflare, AWS Route 53, etc.)
- SSL certificate provider
- Server/hosting platform (AWS, Vercel, etc.)

## 🌐 DNS Configuration

### 1. Wildcard DNS Setup (Recommended)

```bash
# Main domain
example.com         A    123.456.789.123
www.example.com     A    123.456.789.123

# Wildcard subdomain
*.example.com       A    123.456.789.123
```

### 2. Individual Subdomain Setup

```bash
# Core subdomains
api.example.com     A    123.456.789.123
admin.example.com   A    123.456.789.123  
vendor.example.com  A    123.456.789.123
www.example.com     A    123.456.789.123

# Dynamic vendor subdomains (add as needed)
acme.example.com    A    123.456.789.123
techco.example.com  A    123.456.789.123
```

### 3. Cloudflare Configuration

```bash
# DNS Records in Cloudflare
Type  Name    Content           Proxy   TTL
A     @       123.456.789.123   ✓       Auto
A     www     123.456.789.123   ✓       Auto
A     *       123.456.789.123   ✓       Auto
```

**Important Cloudflare Settings:**
- Enable "Proxied" for SSL and performance
- Set SSL/TLS mode to "Full (Strict)"
- Enable "Always Use HTTPS"

## 🔒 SSL Certificate Setup

### Option 1: Wildcard Certificate (Recommended)

```bash
# Let's Encrypt with Certbot
certbot certonly --dns-cloudflare \
  --dns-cloudflare-credentials ~/.secrets/cloudflare.ini \
  -d example.com \
  -d *.example.com

# Certificate files will be at:
# /etc/letsencrypt/live/example.com/fullchain.pem
# /etc/letsencrypt/live/example.com/privkey.pem
```

### Option 2: Individual Certificates

```bash
certbot certonly --nginx \
  -d example.com \
  -d www.example.com \
  -d api.example.com \
  -d admin.example.com \
  -d vendor.example.com
```

## 🐳 Docker Deployment

### docker-compose.yml

```yaml
version: '3.8'

services:
  backend:
    image: itech-backend:latest
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - DATABASE_URL=jdbc:mysql://db:3306/itech_db
      - SUBDOMAIN_ENABLED=true
      - BASE_DOMAIN=example.com
      - CORS_ALLOWED_ORIGINS=https://example.com,https://*.example.com
    networks:
      - app-network

  frontend:
    image: itech-frontend:latest
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=https://api.example.com
      - NEXT_PUBLIC_BASE_DOMAIN=example.com
      - NEXT_PUBLIC_SUBDOMAIN_ENABLED=true
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - /etc/letsencrypt:/etc/letsencrypt:ro
    depends_on:
      - backend
      - frontend
    networks:
      - app-network

  db:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=secure_password
      - MYSQL_DATABASE=itech_db
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  db_data:
```

## 🌐 Nginx Configuration

### nginx.conf

```nginx
events {
    worker_connections 1024;
}

http {
    # Upstream backends
    upstream backend {
        server backend:8080;
    }
    
    upstream frontend {
        server frontend:3000;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=subdomain:10m rate=20r/s;

    # Main domain and www redirect
    server {
        listen 80;
        server_name example.com www.example.com;
        return 301 https://www.example.com$request_uri;
    }

    # HTTPS redirect
    server {
        listen 443 ssl http2;
        server_name example.com;
        
        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
        
        return 301 https://www.example.com$request_uri;
    }

    # Main website (www.example.com)
    server {
        listen 443 ssl http2;
        server_name www.example.com;
        
        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
        
        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
        
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        location /api/ {
            limit_req zone=api burst=5 nodelay;
            
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # API subdomain (api.example.com)
    server {
        listen 80;
        server_name api.example.com;
        return 301 https://api.example.com$request_uri;
    }
    
    server {
        listen 443 ssl http2;
        server_name api.example.com;
        
        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
        
        add_header Access-Control-Allow-Origin "https://www.example.com, https://*.example.com" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Subdomain" always;
        
        location / {
            limit_req zone=api burst=10 nodelay;
            
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # Admin subdomain (admin.example.com)
    server {
        listen 80;
        server_name admin.example.com;
        return 301 https://admin.example.com$request_uri;
    }
    
    server {
        listen 443 ssl http2;
        server_name admin.example.com;
        
        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
        
        # Additional security for admin
        add_header X-Frame-Options DENY;
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'";
        
        location / {
            limit_req zone=subdomain burst=5 nodelay;
            
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Subdomain admin;
        }
        
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # Dynamic vendor subdomains (*.example.com)
    server {
        listen 80;
        server_name ~^(?<subdomain>.+)\.example\.com$;
        return 301 https://$subdomain.example.com$request_uri;
    }
    
    server {
        listen 443 ssl http2;
        server_name ~^(?<subdomain>.+)\.example\.com$;
        
        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
        
        # Skip www and reserved subdomains
        if ($subdomain ~ ^(www|api|admin)$) {
            return 444;
        }
        
        location / {
            limit_req zone=subdomain burst=10 nodelay;
            
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Subdomain $subdomain;
            proxy_set_header X-Subdomain-Valid true;
        }
        
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

## ☁️ Cloud Platform Deployment

### AWS (Using ECS + ALB)

#### Application Load Balancer Rules:

```json
{
  "Rules": [
    {
      "Priority": 1,
      "Conditions": [{"Field": "host-header", "Values": ["api.example.com"]}],
      "Actions": [{"Type": "forward", "TargetGroupArn": "backend-tg"}]
    },
    {
      "Priority": 2,
      "Conditions": [{"Field": "host-header", "Values": ["admin.example.com"]}],
      "Actions": [{"Type": "forward", "TargetGroupArn": "frontend-tg"}]
    },
    {
      "Priority": 3,
      "Conditions": [{"Field": "host-header", "Values": ["*.example.com"]}],
      "Actions": [{"Type": "forward", "TargetGroupArn": "frontend-tg"}]
    }
  ]
}
```

### Vercel Deployment

#### vercel.json

```json
{
  "version": 2,
  "domains": ["example.com", "*.example.com"],
  "routes": [
    {
      "src": "^/api/(.*)",
      "dest": "https://api.example.com/api/$1"
    },
    {
      "src": "/(.*)",
      "dest": "/$1"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {"key": "X-Frame-Options", "value": "DENY"},
        {"key": "X-Content-Type-Options", "value": "nosniff"}
      ]
    }
  ]
}
```

## 🔍 Monitoring & Analytics

### Health Checks

```bash
# Backend health check
curl https://api.example.com/actuator/health

# Subdomain validation
curl https://api.example.com/api/subdomain/config

# Frontend health check
curl https://www.example.com/api/health
```

### Monitoring Setup

```yaml
# docker-compose.monitoring.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus
    ports: ["9090:9090"]
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports: ["3000:3000"]
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

## 🚨 Production Checklist

### Pre-deployment

- [ ] DNS records configured
- [ ] SSL certificates obtained
- [ ] Environment variables set
- [ ] Database migrations run
- [ ] Load balancer configured
- [ ] Monitoring setup

### Post-deployment

- [ ] Test main domain (www.example.com)
- [ ] Test API subdomain (api.example.com)  
- [ ] Test admin subdomain (admin.example.com)
- [ ] Test dynamic vendor subdomains
- [ ] Verify SSL certificates
- [ ] Check CORS headers
- [ ] Test subdomain validation API
- [ ] Monitor application logs
- [ ] Set up alerts

### Testing Commands

```bash
# Test subdomain extraction
curl -H "Host: vendor.example.com" https://api.example.com/api/subdomain/info

# Test CORS
curl -H "Origin: https://acme.example.com" \
     -H "Access-Control-Request-Method: GET" \
     -X OPTIONS \
     https://api.example.com/api/products

# Test subdomain validation
curl https://api.example.com/api/subdomain/validate/test-vendor

# Load test
ab -n 1000 -c 10 https://www.example.com/
```

## 🔧 Troubleshooting

### Common Issues

1. **Subdomain not resolving**
   ```bash
   # Check DNS propagation
   dig *.example.com
   nslookup vendor.example.com
   ```

2. **SSL certificate errors**
   ```bash
   # Verify certificate
   openssl s_client -connect vendor.example.com:443 -servername vendor.example.com
   ```

3. **CORS issues**
   - Check backend CORS configuration
   - Verify subdomain in allowed origins
   - Check browser developer tools

4. **Nginx 444 errors**
   - Check if subdomain matches regex patterns
   - Verify server_name configuration

### Log Analysis

```bash
# Backend logs
docker logs itech-backend | grep -i subdomain

# Nginx access logs
tail -f /var/log/nginx/access.log | grep -E "(admin|vendor|api)\.example\.com"

# Application logs
tail -f logs/application.log | grep "SubdomainMiddleware"
```

## 🎯 Performance Optimization

### Caching Strategy

```nginx
# Static asset caching
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# API response caching
location /api/subdomain/config {
    proxy_cache api_cache;
    proxy_cache_valid 200 1h;
}
```

### CDN Configuration

```javascript
// Cloudflare Page Rules
{
  "url": "*.example.com/*",
  "settings": {
    "cache_level": "cache_everything",
    "edge_cache_ttl": 3600,
    "browser_cache_ttl": 7200
  }
}
```

This deployment guide provides everything needed to successfully deploy your subdomain routing system in production! 🚀
