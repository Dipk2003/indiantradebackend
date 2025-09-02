# ITech B2B Platform API Documentation

## Overview

This document provides comprehensive documentation for the ITech B2B Platform API, including authentication, endpoints, WebSocket integration, and best practices.

## Authentication

### JWT Authentication

The platform uses JWT (JSON Web Tokens) for authentication. All authenticated endpoints require a valid JWT token in the Authorization header.

```http
Authorization: Bearer <jwt_token>
```

### Two-Factor Authentication (2FA)

Two-factor authentication is available and recommended for enhanced security. 2FA can be enabled through the following endpoints:

- `POST /api/auth/2fa/enable`
- `POST /api/auth/2fa/verify`
- `POST /api/auth/2fa/disable`

## Core APIs

### User Management

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword",
  "userType": "BUYER|VENDOR"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword"
}
```

### Product Management

#### Create Product
```http
POST /api/products
Content-Type: application/json
Authorization: Bearer <jwt_token>

{
  "name": "Product Name",
  "description": "Product Description",
  "category": "category_id",
  "price": 99.99
}
```

#### Search Products
```http
GET /api/products/search?q=keyword&category=category_id&page=0&size=20
Authorization: Bearer <jwt_token>
```

## WebSocket Integration

### Connection Setup

WebSocket connections are established through:
```
ws://api.example.com/ws
```

Required headers:
```
Authorization: Bearer <jwt_token>
```

### Message Formats

#### Chat Message
```json
{
  "type": "CHAT",
  "payload": {
    "recipientId": "user_id",
    "message": "Hello",
    "timestamp": "2024-08-30T10:00:00Z"
  }
}
```

#### Real-time Updates
```json
{
  "type": "UPDATE",
  "payload": {
    "entityType": "ORDER|PRODUCT|INQUIRY",
    "action": "CREATE|UPDATE|DELETE",
    "data": {}
  }
}
```

### Reconnection Strategy

The WebSocket implementation includes automatic reconnection with exponential backoff:
1. Initial attempt: Immediate
2. Second attempt: 1 second delay
3. Subsequent attempts: Exponential increase up to 30 seconds
4. Maximum retry attempts: 5

## Performance Optimization

### Caching

The API implements multiple caching layers:

1. Redis Cache
   - Product data: 10 minutes TTL
   - Category data: 15 minutes TTL
   - User profiles: 1 hour TTL
   - Static data: 24 hours TTL

2. Response Caching
   - GET requests are cached by default
   - Cache-Control headers are respected
   - ETag support for conditional requests

### Rate Limiting

Rate limits are enforced per API key:

- Authentication endpoints: 5 requests per minute
- Standard endpoints: 60 requests per minute
- Bulk operations: 10 requests per minute

### Pagination

All list endpoints support pagination with the following parameters:

```http
GET /api/resource?page=0&size=20&sort=field,direction
```

## Error Handling

### Error Response Format

```json
{
  "status": 400,
  "code": "VALIDATION_ERROR",
  "message": "Invalid input provided",
  "details": {
    "field": "Error description"
  },
  "timestamp": "2024-08-30T10:00:00Z"
}
```

### Common Error Codes

- `AUTHENTICATION_ERROR`: Authentication failed
- `AUTHORIZATION_ERROR`: Insufficient permissions
- `VALIDATION_ERROR`: Invalid input data
- `RESOURCE_NOT_FOUND`: Requested resource doesn't exist
- `RATE_LIMIT_EXCEEDED`: Too many requests
- `INTERNAL_ERROR`: Server error

## Security Guidelines

### Input Validation

All endpoints implement strict input validation:

1. Data type validation
2. Size limits
3. Format validation
4. XSS prevention
5. SQL injection prevention

### Security Headers

The API implements the following security headers:

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
```

## Deployment

### Environment Variables

Required environment variables:

```
DATABASE_URL=jdbc:postgresql://localhost:5432/itech
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-jwt-secret
AWS_ACCESS_KEY=your-aws-access-key
AWS_SECRET_KEY=your-aws-secret-key
```

### Health Checks

Health check endpoint:
```http
GET /api/health
```

Response:
```json
{
  "status": "UP",
  "components": {
    "db": "UP",
    "redis": "UP",
    "elasticsearch": "UP"
  }
}
```

## Monitoring

### Metrics

The following metrics are collected:

1. Request metrics
   - Total requests
   - Success rate
   - Response time
   - Error rate

2. Business metrics
   - Active users
   - Order volume
   - Product listings
   - User registrations

3. System metrics
   - CPU usage
   - Memory usage
   - Disk I/O
   - Network I/O

### Logging

Log format:
```json
{
  "timestamp": "2024-08-30T10:00:00Z",
  "level": "INFO",
  "thread": "http-nio-8080-exec-1",
  "logger": "com.itech.Controller",
  "message": "Request processed",
  "context": {
    "userId": "user123",
    "action": "CREATE_ORDER",
    "duration": 150
  }
}
```

## Best Practices

1. Use appropriate HTTP methods
2. Implement proper error handling
3. Validate all inputs
4. Use pagination for large datasets
5. Implement rate limiting
6. Use caching effectively
7. Monitor performance metrics
8. Keep documentation updated
9. Follow security guidelines
10. Implement proper logging

## API Versioning

The API uses URL versioning:

```
/api/v1/resource
/api/v2/resource
```

Changes between versions are documented in the changelog.
