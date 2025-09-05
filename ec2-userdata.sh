#!/bin/bash
# EC2 User Data script for Indian Trade Mart Backend

# Update system
yum update -y

# Install Java 17
yum install -y java-17-amazon-corretto

# Create application directory
mkdir -p /opt/indiantrademart
cd /opt/indiantrademart

# Download the JAR file from S3
aws s3 cp s3://indiantrademart-storage/backend-deployments/itech-backend-v1.0.jar ./app.jar

# Create environment file
cat > /opt/indiantrademart/app.env << 'EOF'
SPRING_PROFILES_ACTIVE=production
DATABASE_URL=jdbc:mysql://indiantrademart-db.czswk0o224zf.ap-south-1.rds.amazonaws.com:3306/itech_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata
JDBC_DATABASE_USERNAME=itechadmin
JDBC_DATABASE_PASSWORD=ITechMart2025!
JWT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5j6k7l8m9n0p1q2r3s4t5u6v7w8x9y0z1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w4x5y6z7a8b9c0d1e2f3g4h5i6j7k8l9m0n1o2p3q4r5s6t7u8v9w0x1y2z3a4b5c6d7e8f9g0h1i2j3k4l5m6n7o8p9q0r1s2t3u4v5w6x7y8z9a0
AWS_S3_BUCKET_NAME=indiantrademart-storage
AWS_S3_REGION=ap-south-1
REDIS_HOST=indiantrademart-redis.2otwg1.0001.aps1.cache.amazonaws.com
REDIS_PORT=6379
EMAIL_SIMULATION_ENABLED=true
SMS_SIMULATION_ENABLED=true
EOF

# Create systemd service
cat > /etc/systemd/system/indiantrademart.service << 'EOF'
[Unit]
Description=Indian Trade Mart Backend
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/indiantrademart
EnvironmentFile=/opt/indiantrademart/app.env
ExecStart=/usr/bin/java -Xmx1g -Xms512m -jar /opt/indiantrademart/app.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
chown -R ec2-user:ec2-user /opt/indiantrademart

# Enable and start the service
systemctl daemon-reload
systemctl enable indiantrademart
systemctl start indiantrademart

# Install and configure nginx as reverse proxy
yum install -y nginx

cat > /etc/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Backend API proxy
    upstream backend {
        server 127.0.0.1:8080;
    }

    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;

        # API routes
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Health check
        location /actuator/health {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # Default response for other requests
        location / {
            return 200 'Indian Trade Mart Backend API is running!';
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Start nginx
systemctl enable nginx
systemctl start nginx

# Open firewall for HTTP
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 8080 -j ACCEPT

echo "Indian Trade Mart Backend deployment completed!"
