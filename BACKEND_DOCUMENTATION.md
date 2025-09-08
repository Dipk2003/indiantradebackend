# 📋 iTech B2B Marketplace - Complete Backend Documentation

## 🏗️ System Architecture Overview

Your iTech backend is a comprehensive B2B marketplace system built with Spring Boot, supporting multiple user roles with complex business workflows.

### 🎯 Core Modules
1. **Authentication & Authorization** (Core)
2. **User Management** (Buyers, Vendors, Admins)
3. **Product Management** 
4. **Order Management**
5. **Company Management**
6. **Payment Processing**
7. **Analytics & Reporting**
8. **Support System**

---

## 🔐 Authentication System

### Base URL: `/auth`

#### Registration Endpoints
```
POST /auth/register                    # User registration
POST /auth/vendor/register            # Vendor registration
POST /auth/admin/register             # Admin registration
```

#### Login Endpoints
```
POST /auth/login                      # Generic login
POST /auth/user/login                 # User-specific login
POST /auth/vendor/login               # Vendor-specific login
POST /auth/admin/login                # Admin-specific login
POST /auth/login-otp                  # Request OTP for login
```

#### Verification & Password Management
```
POST /auth/verify                     # Verify OTP
POST /auth/verify-otp                 # Alternative OTP verification
POST /auth/set-password               # Set initial password
POST /auth/forgot-password            # Request password reset
POST /auth/verify-forgot-password-otp # Verify forgot password OTP
POST /auth/change-password            # Change existing password
```

#### Profile Management
```
GET  /auth/profile                    # Get current user profile
PUT  /auth/profile                    # Update user profile
POST /auth/check-email-role           # Check email and role
```

---

## 👥 User Management APIs

### 🛍️ Buyer Management - `/api/buyers`

#### Core Operations
```
POST   /api/buyers                    # Create new buyer
GET    /api/buyers/{id}               # Get buyer by ID
PUT    /api/buyers/{id}               # Update buyer
DELETE /api/buyers/{id}               # Soft delete buyer
DELETE /api/buyers/{id}/hard          # Hard delete buyer
```

#### Authentication & Security
```
POST /api/buyers/authenticate         # Authenticate buyer
PUT  /api/buyers/{id}/password        # Update password
POST /api/buyers/password-reset/token # Generate reset token
POST /api/buyers/password-reset       # Reset password
```

#### Verification System
```
POST /api/buyers/{id}/verify/email/send    # Send email verification
POST /api/buyers/{id}/verify/email         # Verify email
POST /api/buyers/{id}/verify/phone/send    # Send phone verification
POST /api/buyers/{id}/verify/phone         # Verify phone
POST /api/buyers/{id}/verify/kyc           # Initiate KYC
PUT  /api/buyers/{id}/verify/kyc/status    # Update KYC status
GET  /api/buyers/{id}/verification         # Get verification details
```

#### Status Management
```
POST /api/buyers/{id}/activate        # Activate buyer
POST /api/buyers/{id}/deactivate      # Deactivate buyer
POST /api/buyers/{id}/suspend         # Suspend buyer
```

#### Search & Filtering
```
GET /api/buyers                       # Get all buyers (paginated)
GET /api/buyers/search               # Search buyers
GET /api/buyers/filter               # Filter buyers with criteria
GET /api/buyers/status/{status}      # Get buyers by status
GET /api/buyers/type/{type}          # Get buyers by type
```

#### Analytics & Reporting
```
GET /api/buyers/analytics/dashboard   # Dashboard statistics
GET /api/buyers/analytics/count/status # Count by status
GET /api/buyers/analytics/registration # Registration statistics
```

### 🏭 Vendor Management - `/api/v1/vendors`

#### Core CRUD Operations
```
POST   /api/v1/vendors               # Create vendor
GET    /api/v1/vendors/{id}          # Get vendor by ID
PUT    /api/v1/vendors/{id}          # Update vendor
DELETE /api/v1/vendors/{id}          # Delete vendor
```

#### Vendor Listings & Search
```
GET /api/v1/vendors                  # Get all vendors (paginated)
GET /api/v1/vendors/search           # Search vendors
GET /api/v1/vendors/filter           # Advanced filtering
```

#### Verification & KYC
```
POST /api/v1/vendors/verify          # Verify vendor
POST /api/v1/vendors/{id}/kyc        # Submit KYC documents
GET  /api/v1/vendors/kyc/pending     # Get pending KYC vendors
```

#### Status Management
```
PATCH /api/v1/vendors/{id}/status    # Update status
POST  /api/v1/vendors/{id}/activate  # Activate vendor
POST  /api/v1/vendors/{id}/deactivate # Deactivate vendor
POST  /api/v1/vendors/{id}/suspend   # Suspend vendor
```

#### Profile Management
```
PATCH /api/v1/vendors/{id}/profile           # Update profile
PATCH /api/v1/vendors/{id}/images            # Update images
PATCH /api/v1/vendors/{id}/business-info     # Update business info
PATCH /api/v1/vendors/{id}/service-areas     # Update service areas
```

#### Performance & Analytics
```
GET /api/v1/vendors/top-performing   # Top performing vendors
GET /api/v1/vendors/statistics       # Vendor statistics
GET /api/v1/vendors/featured         # Featured vendors
```

---

## 🛒 Product Management APIs

### Product Controller - `/api/products` (Inferred from models)

#### Core Operations
```
POST   /api/products                 # Create product
GET    /api/products/{id}            # Get product by ID
PUT    /api/products/{id}            # Update product
DELETE /api/products/{id}            # Delete product
```

#### Product Catalog
```
GET /api/products                    # Get all products
GET /api/products/search             # Search products
GET /api/products/category/{cat}     # Products by category
GET /api/products/featured           # Featured products
```

---

## 📦 Order Management APIs

### Order System - `/api/orders`

#### Order Lifecycle
```
POST   /api/orders                   # Create order
GET    /api/orders/{id}              # Get order details
PUT    /api/orders/{id}              # Update order
DELETE /api/orders/{id}              # Cancel order
```

#### Order Processing
```
PATCH /api/orders/{id}/status        # Update order status
PATCH /api/orders/{id}/payment       # Update payment status
PATCH /api/orders/{id}/shipping      # Update shipping info
```

#### Order Items Management
```
GET    /api/orders/{id}/items        # Get order items
POST   /api/orders/{id}/items        # Add items to order
PUT    /api/orders/{id}/items/{itemId} # Update order item
DELETE /api/orders/{id}/items/{itemId} # Remove order item
```

---

## 🏢 Company Management APIs

### Company Controller - `/api/companies`

```
POST   /api/companies                # Register company
GET    /api/companies/{id}           # Get company details
PUT    /api/companies/{id}           # Update company
GET    /api/companies/search         # Search companies
```

---

## 💳 Payment & Subscription APIs

### Payment Processing - `/api/payments`
```
POST /api/payments/create            # Create payment
POST /api/payments/verify            # Verify payment
GET  /api/payments/{id}/status       # Payment status
```

### Subscription Management - `/api/subscriptions`
```
POST /api/subscriptions/create       # Create subscription
GET  /api/subscriptions/{id}         # Get subscription
PUT  /api/subscriptions/{id}/upgrade # Upgrade subscription
```

---

## 📊 Analytics & Reporting APIs

### Admin Analytics - `/api/admin/analytics`
```
GET /api/admin/analytics/dashboard   # Admin dashboard stats
GET /api/admin/analytics/users       # User analytics
GET /api/admin/analytics/revenue     # Revenue analytics
```

### Vendor Analytics - `/api/vendor/analytics`
```
GET /api/vendor/analytics/dashboard  # Vendor dashboard
GET /api/vendor/analytics/performance # Performance metrics
```

---

## 🎫 Support System APIs

### Support Tickets - `/api/support`
```
POST /api/support/tickets            # Create ticket
GET  /api/support/tickets/{id}       # Get ticket
PUT  /api/support/tickets/{id}       # Update ticket
```

### Chat System - `/api/chat`
```
GET  /api/chat/conversations         # Get conversations
POST /api/chat/send                  # Send message
```

---

## 🗄️ Database Schema & Relationships

### 🔗 Core Entity Relationships

```
USER (Central entity)
├── BUYERS (1:1 with USER)
├── VENDORS (1:1 with USER)
└── ADMINS (1:1 with USER)

COMPANIES (Business entities)
├── Can have multiple BUYERS
├── Can have multiple VENDORS
└── Can have multiple EMPLOYEES

PRODUCTS
├── Belong to VENDORS (Many:1)
├── Have multiple PRODUCT_IMAGES
├── Have PRODUCT_ATTRIBUTES
└── Can be in ORDERS through ORDER_ITEMS

ORDERS (Complex workflow)
├── Placed by BUYERS (Many:1)
├── Can involve multiple VENDORS
├── Contains ORDER_ITEMS (1:Many)
├── Has ORDER_COMMUNICATIONS
└── Connected to PAYMENTS

RFQs (Request for Quotations)
├── Created by BUYERS
├── Responded by VENDORS via RFQ_BIDS
└── Can convert to ORDERS
```

### 📋 Table Categories

#### 🔐 Authentication Tables
- `user` - Core user table
- `otp_verification` - OTP management
- `two_factor_auth` - 2FA settings
- `user_roles` - Role assignments
- `permissions` - Permission definitions

#### 👥 User Profile Tables
- `buyers` - Buyer profiles
- `vendors` - Vendor profiles  
- `admins` - Admin profiles
- `user_addresses` - Address management
- `kyc_documents` - KYC verification

#### 🏢 Business Tables
- `companies` - Company profiles
- `company_certifications` - Business certifications
- `company_industries` - Industry classifications

#### 📦 Product Catalog Tables
- `products` - Main product catalog
- `product_images` - Product images
- `product_attributes` - Product specifications
- `product_categories` - Category hierarchy
- `categories`, `buyer_sub_category`, `buyer_micro_category` - Category structure

#### 🛒 Commerce Tables
- `orders` - Order management
- `order_items` - Order line items
- `cart` - Shopping cart
- `cart_item` - Cart items
- `payments` - Payment processing
- `invoices` - Billing management

#### 💬 Communication Tables
- `chat_conversations` - Chat system
- `chat_messages` - Chat messages
- `support_tickets` - Support system
- `notifications` - System notifications

#### 📊 Analytics Tables
- `analytics` - Analytics data
- `activity_logs` - User activity tracking
- `api_logs` - API usage logs

---

## ⚠️ Unused Tables Identified

Based on analysis, these tables appear to be unused or redundant:

### 🗑️ Tables to Consider Removing

1. **`users`** - Redundant with `user` table
2. **`legacy_vendors`** - Old vendor data (if migration complete)
3. **`extended_vendor_profiles`** - If data merged into main vendor profile
4. **`service_providers`** - Duplicate of vendors functionality
5. **`service_provider_reviews`** - If using unified review system
6. **`buyer_payment_methods`** - If using unified payment system
7. **`product_external_ids`** - If not using external system integration
8. **`system_metrics`** - If using dedicated monitoring solution

### 🧹 Cleanup Recommendations

Run these SQL commands to remove unused tables:

```sql
-- Remove duplicate user table
DROP TABLE IF EXISTS users;

-- Remove legacy data (if migration complete)
DROP TABLE IF EXISTS legacy_vendors;
DROP TABLE IF EXISTS extended_vendor_profiles;

-- Remove service provider tables (if using vendors)
DROP TABLE IF EXISTS service_provider_images;
DROP TABLE IF EXISTS service_provider_reviews;
DROP TABLE IF EXISTS service_providers;

-- Remove redundant payment method table
DROP TABLE IF EXISTS buyer_payment_methods;
```

---

## 🚀 Frontend Integration Guide

### 🔧 API Integration Points

#### Authentication Flow
1. **Registration**: Use role-specific registration endpoints
2. **Login**: Implement OTP-based or direct login
3. **Profile Management**: Use unified profile endpoints

#### User Dashboard
1. **Buyer Dashboard**: Integrate with buyer analytics endpoints
2. **Vendor Dashboard**: Use vendor performance metrics
3. **Admin Dashboard**: Connect to admin analytics

#### Product Catalog
1. **Product Listing**: Use pagination and filtering
2. **Search**: Implement search with faceted navigation
3. **Categories**: Use hierarchical category structure

#### Order Management
1. **Order Placement**: Multi-step checkout process
2. **Order Tracking**: Real-time status updates
3. **Order History**: Paginated order listing

### 📱 Mobile App Considerations

#### API Versioning
- Current API uses `/api/v1/` for vendors
- Consider consistent versioning across all modules

#### Response Format
```json
{
  "success": true,
  "data": {...},
  "message": "Success message",
  "pagination": {
    "page": 0,
    "size": 20,
    "totalElements": 100,
    "totalPages": 5
  }
}
```

#### Error Handling
```json
{
  "success": false,
  "error": "Error code",
  "message": "Human readable message",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

---

## 🔒 Security Considerations

### Authentication
- JWT-based authentication
- Role-based access control (RBAC)
- OTP verification for sensitive operations

### Data Protection
- Encrypted passwords
- PII data protection
- KYC document security

### API Security
- Rate limiting
- Input validation
- SQL injection protection

---

## 📈 Performance Optimizations

### Database Indexing
- Primary keys auto-indexed
- Foreign key indexes present
- Search field indexes implemented

### Caching Strategy
- Redis integration available
- User session caching
- Frequently accessed data caching

### Pagination
- Consistent pagination across endpoints
- Configurable page sizes
- Sort and filter capabilities

---

## 🛠️ Development Workflow

### API Testing
- Use Postman collection
- Implement automated testing
- Mock external services

### Monitoring
- Application health checks
- Error logging and tracking
- Performance monitoring

### Documentation
- API documentation with OpenAPI/Swagger
- Database schema documentation
- Integration guides

---

## 🚀 Deployment Considerations

### Environment Configuration
- Development, staging, production profiles
- Database migration scripts
- External service configurations

### Scalability
- Microservice-ready architecture
- Database connection pooling
- Load balancing support

---

This comprehensive documentation provides a complete overview of your iTech B2B marketplace backend system. The API endpoints are organized by module, database relationships are clearly defined, and unused tables have been identified for cleanup. This should serve as an excellent reference for frontend integration and system maintenance.
