# Indian Trade Mart - Backend API

## 🚀 Project Overview

**Indian Trade Mart Backend** is a comprehensive B2B marketplace API built with Spring Boot 3.5.3 and Java 21. This RESTful API powers a complete trading ecosystem with multi-role authentication, product management, order processing, payment integration, and real-time communication features.

### 🏗️ Technology Stack

- **Framework**: Spring Boot 3.5.3
- **Language**: Java 21
- **Database**: MySQL 8.0 (Primary), PostgreSQL (Cloud deployment)
- **Security**: Spring Security with JWT Authentication
- **ORM**: Spring Data JPA with Hibernate
- **Build Tool**: Maven
- **Cache**: Redis (AWS ElastiCache)
- **File Storage**: AWS S3
- **Payment**: Razorpay Integration
- **Email**: Spring Mail with AWS SES
- **Documentation**: OpenAPI/Swagger
- **Testing**: JUnit 5, H2 (test database)

### 🎯 Key Features

- **Multi-Role Authentication**: Admin, Vendor, Buyer, Support roles
- **Product Management**: Complete product catalog with categories and variants
- **Order Processing**: End-to-end order management with status tracking
- **Payment Integration**: Razorpay payment gateway with webhooks
- **File Management**: AWS S3 integration for image and document uploads
- **Real-time Communication**: WebSocket support for chat and notifications
- **KYC Verification**: Document verification and compliance management
- **Analytics & Reporting**: Business intelligence and dashboard metrics
- **Email Notifications**: Automated email system with templates
- **Caching**: Redis-based caching for performance optimization

## 📁 Project Structure

```
src/
├── main/
│   ├── java/com/itech/itech_backend/
│   │   ├── config/              # Configuration classes
│   │   ├── enums/               # Enumeration types
│   │   ├── exception/           # Global exception handling
│   │   ├── filter/              # Security filters
│   │   ├── modules/             # Feature modules
│   │   │   ├── admin/           # Admin management
│   │   │   ├── analytics/       # Analytics and reporting
│   │   │   ├── buyer/           # Buyer functionality
│   │   │   ├── company/         # Company management
│   │   │   ├── core/            # Core functionality (auth, users)
│   │   │   ├── order/           # Order management
│   │   │   ├── payment/         # Payment processing
│   │   │   ├── product/         # Product management
│   │   │   ├── shared/          # Shared components
│   │   │   ├── support/         # Customer support
│   │   │   └── vendor/          # Vendor functionality
│   │   └── util/                # Utility classes
│   └── resources/
│       ├── application.properties           # Main configuration
│       ├── application-local.properties     # Local development
│       ├── application-production.properties # Production config
│       └── application-aws-prod.properties  # AWS production
└── test/                        # Test classes
```

## ⚙️ Configuration

### Environment Configurations

#### 1. Local Development (`application-local.properties`)
```properties
# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/itm_local_db
spring.datasource.username=root
spring.datasource.password=password

# JPA Settings
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# JWT Configuration
jwt.secret=your-local-jwt-secret-key
jwt.expiration=86400000

# File Upload
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB

# Email Configuration (Local - Use Gmail SMTP for testing)
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password

# Payment Gateway (Test Mode)
razorpay.key.id=your_test_key_id
razorpay.key.secret=your_test_key_secret

# Debug Settings
logging.level.com.itech=DEBUG
logging.level.org.springframework.web=DEBUG
```

#### 2. AWS Production (`application-aws-prod.properties`)
```properties
# Database Configuration (RDS)
spring.datasource.url=jdbc:mysql://${RDS_HOSTNAME}:${RDS_PORT}/${RDS_DB_NAME}
spring.datasource.username=${RDS_USERNAME}
spring.datasource.password=${RDS_PASSWORD}

# Connection Pool Settings
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.idle-timeout=300000

# JPA Settings (Production)
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.jdbc.batch_size=20

# JWT Configuration
jwt.secret=${JWT_SECRET}
jwt.expiration=86400000

# AWS S3 Configuration
aws.s3.bucket=${AWS_S3_BUCKET}
aws.s3.region=${AWS_S3_REGION}

# Email Configuration (SES)
spring.mail.host=${SES_SMTP_HOST}
spring.mail.port=587
spring.mail.username=${SES_SMTP_USERNAME}
spring.mail.password=${SES_SMTP_PASSWORD}

# Redis Configuration (ElastiCache)
spring.redis.host=${REDIS_HOST}
spring.redis.port=${REDIS_PORT}
spring.redis.password=${REDIS_PASSWORD}

# Payment Gateway (Production)
razorpay.key.id=${RAZORPAY_KEY_ID}
razorpay.key.secret=${RAZORPAY_KEY_SECRET}

# Production Settings
server.port=8080
logging.level.com.itech=INFO
logging.level.org.springframework.web=WARN
```

## 🚀 Getting Started

### Prerequisites
- Java 21
- Maven 3.8+
- MySQL 8.0 (for local development)
- Redis (optional for local development)
- AWS Account (for production deployment)

### Local Development Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd itech-backend
```

2. **Set up MySQL Database**
```sql
CREATE DATABASE itm_local_db;
CREATE USER 'itm_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON itm_local_db.* TO 'itm_user'@'localhost';
FLUSH PRIVILEGES;
```

3. **Configure Application Properties**
```bash
# Copy and modify local configuration
cp src/main/resources/application-local.properties.example src/main/resources/application-local.properties
# Edit the file with your local settings
```

4. **Build the Project**
```bash
mvn clean compile
```

5. **Run Database Migrations (if using Flyway)**
```bash
mvn flyway:migrate
```

6. **Start the Application**
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

7. **Verify Installation**
```bash
# Check health endpoint
curl http://localhost:8080/actuator/health

# Check API documentation
# Open http://localhost:8080/swagger-ui.html
```

### Production Deployment (AWS Elastic Beanstalk)

1. **Build Production JAR**
```bash
mvn clean package -DskipTests -Dspring.profiles.active=aws-prod
```

2. **Configure Environment Variables in AWS EB**
```bash
# Database
RDS_HOSTNAME=your-rds-endpoint.amazonaws.com
RDS_PORT=3306
RDS_DB_NAME=itm_production
RDS_USERNAME=admin
RDS_PASSWORD=your-secure-password

# Security
JWT_SECRET=your-production-jwt-secret-key

# AWS Services
AWS_S3_BUCKET=itm-production-files
AWS_S3_REGION=us-east-1
SES_SMTP_HOST=email-smtp.us-east-1.amazonaws.com
SES_SMTP_USERNAME=your-ses-username
SES_SMTP_PASSWORD=your-ses-password

# Redis (ElastiCache)
REDIS_HOST=your-elasticache-endpoint.amazonaws.com
REDIS_PORT=6379
REDIS_PASSWORD=your-redis-password

# Payment Gateway
RAZORPAY_KEY_ID=your-production-key-id
RAZORPAY_KEY_SECRET=your-production-key-secret
```

3. **Deploy to Elastic Beanstalk**
- Upload the JAR file to AWS Elastic Beanstalk
- Configure the environment variables
- Deploy and monitor the application

## 🔐 Authentication & Authorization

### User Roles
- **ADMIN**: Complete system access and user management
- **VENDOR**: Product management and order fulfillment
- **BUYER**: Product browsing and order placement
- **SUPPORT**: Customer service and ticket management

### JWT Token Structure
```json
{
  "sub": "user@example.com",
  "roles": ["ROLE_BUYER"],
  "iat": 1641024000,
  "exp": 1641110400,
  "userId": "12345"
}
```

### Security Configuration
- JWT-based stateless authentication
- Role-based access control (RBAC)
- CORS configuration for frontend integration
- HTTPS enforcement in production
- Rate limiting for API endpoints

## 📊 Database Schema

### Core Tables
- `users` - User authentication and basic profile
- `buyers` - Buyer-specific information
- `vendors` - Vendor profiles and business details
- `products` - Product catalog
- `categories` - Product categorization
- `orders` - Order management
- `payments` - Payment transactions
- `inquiries` - Customer inquiries
- `support_tickets` - Customer support system

### Relationships
- One-to-Many: User → Orders, Vendor → Products
- Many-to-Many: Orders → Products (through order_items)
- Self-referencing: Categories (parent-child relationship)

## 🔧 Available Scripts

### Development
```bash
# Start development server
mvn spring-boot:run -Dspring-boot.run.profiles=local

# Run tests
mvn test

# Build without tests
mvn clean package -DskipTests

# Generate test coverage report
mvn jacoco:report
```

### Database Operations
```bash
# Run database migrations
mvn flyway:migrate

# Clean database
mvn flyway:clean

# Create new migration
mvn flyway:info
```

### Code Quality
```bash
# Run static analysis
mvn checkstyle:check

# Format code
mvn spring-javaformat:apply

# Security scan
mvn dependency-check:check
```

## 🌐 API Documentation

The API documentation is available via Swagger UI when the application is running:
- **Local**: http://localhost:8080/swagger-ui.html
- **Production**: https://your-domain.com/swagger-ui.html

### Key API Endpoints

#### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/refresh` - Refresh JWT token
- `POST /api/auth/logout` - User logout

#### Products
- `GET /api/products` - List products with pagination
- `GET /api/products/{id}` - Get product details
- `POST /api/products` - Create product (Vendor only)
- `PUT /api/products/{id}` - Update product (Vendor only)

#### Orders
- `GET /api/orders` - List user orders
- `POST /api/orders` - Create new order
- `GET /api/orders/{id}` - Get order details
- `PUT /api/orders/{id}/status` - Update order status

#### Users
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile
- `POST /api/users/avatar` - Upload profile picture

## 🧪 Testing

### Test Structure
```
src/test/java/
├── unit/              # Unit tests
├── integration/       # Integration tests
├── controller/        # Controller tests
└── service/           # Service layer tests
```

### Running Tests
```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=UserServiceTest

# Run tests with coverage
mvn test jacoco:report

# Integration tests only
mvn test -Dtest=*IT
```

## 📈 Monitoring & Logging

### Health Checks
- `/actuator/health` - Application health status
- `/actuator/metrics` - Application metrics
- `/actuator/info` - Application information

### Logging Configuration
```properties
# Log levels
logging.level.com.itech=INFO
logging.level.org.springframework.security=DEBUG

# Log file
logging.file.name=logs/application.log
logging.pattern.file=%d{ISO8601} [%thread] %-5level %logger{36} - %msg%n
```

### Performance Monitoring
- Database query performance logging
- API response time monitoring
- Memory usage tracking
- Redis cache hit/miss ratios

## 🔒 Security Best Practices

### Implemented Security Measures
- JWT token validation on all protected endpoints
- Password encryption using BCrypt
- SQL injection prevention through JPA/Hibernate
- XSS protection with input validation
- CSRF protection for state-changing operations
- Rate limiting on authentication endpoints
- Secure file upload validation

### Environment-Specific Security
- **Local Development**: Basic security for development ease
- **Production**: Full security with HTTPS, secure headers, and monitoring

## 📦 Deployment

### AWS Infrastructure Requirements
- **Elastic Beanstalk**: Application hosting
- **RDS MySQL**: Primary database
- **ElastiCache Redis**: Caching layer
- **S3**: File and image storage
- **SES**: Email service
- **CloudWatch**: Monitoring and logging
- **IAM**: Access management

### Environment Variables Checklist
- [ ] Database connection settings
- [ ] JWT secret configuration
- [ ] AWS service credentials
- [ ] Payment gateway keys
- [ ] Email service configuration
- [ ] Redis connection settings
- [ ] File storage configuration

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Issues**
   - Verify database server is running
   - Check connection string and credentials
   - Ensure database exists and user has proper permissions

2. **JWT Token Issues**
   - Verify JWT secret is properly configured
   - Check token expiration settings
   - Ensure consistent secret across all instances

3. **File Upload Issues**
   - Check file size limits in configuration
   - Verify AWS S3 credentials and permissions
   - Ensure proper CORS configuration

4. **Email Service Issues**
   - Verify SMTP credentials
   - Check SES configuration in AWS
   - Ensure proper firewall settings for SMTP ports

### Debug Commands
```bash
# Check application logs
tail -f logs/application.log

# Test database connection
mysql -h localhost -u itm_user -p itm_local_db

# Test Redis connection
redis-cli ping

# Check health status
curl http://localhost:8080/actuator/health
```

## 👥 Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Follow code formatting standards
6. Submit a pull request

## 📄 License

This project is proprietary software. All rights reserved.

---

**Last Updated**: January 2025
**Version**: 0.0.1-SNAPSHOT
**Java Version**: 21
**Spring Boot Version**: 3.5.3
