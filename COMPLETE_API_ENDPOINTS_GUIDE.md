# 🚀 Complete API Endpoints Guide - Indian Trade Mart Backend

**Base URL**: `https://indiantradebackend.onrender.com`

---

## 📋 **Table of Contents**
1. [Authentication & Authorization](#authentication--authorization)
2. [User Management](#user-management)
3. [Buyer APIs](#buyer-apis)
4. [Vendor APIs](#vendor-apis)
5. [Product Management](#product-management)
6. [Category Management](#category-management)
7. [Company Management](#company-management)
8. [Admin Panel APIs](#admin-panel-apis)
9. [Payment & Subscription](#payment--subscription)
10. [Analytics & Reports](#analytics--reports)
11. [Support & Communication](#support--communication)
12. [File Management](#file-management)
13. [Import/Export](#importexport)
14. [Location & Directory](#location--directory)
15. [System & Health](#system--health)

---

## 🔐 **Authentication & Authorization**

### **Base Path**: `/auth`

#### **User Registration**
```http
POST /auth/register
```
**Purpose**: Register a new regular user/buyer  
**Request Body**:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "9876543210", 
  "password": "password123"
}
```
**Response**: Registration success message with OTP verification required

---

#### **Vendor Registration**
```http
POST /auth/vendor/register
```
**Purpose**: Register as a vendor/supplier  
**Request Body**: Same as user registration + business details  
**Special**: Sets role as ROLE_VENDOR, requires additional verification

---

#### **Admin Registration**
```http
POST /auth/admin/register
```
**Purpose**: Register admin users (restricted access)  
**Role Required**: Super Admin  
**Special**: Creates admin with elevated permissions

---

#### **Support Staff Registration**
```http
POST /auth/support/register
```
**Purpose**: Register support team members  
**Role**: SUPPORT - can handle customer queries and tickets

---

#### **CTO Registration**
```http
POST /auth/cto/register  
```
**Purpose**: Register CTO level access  
**Role**: CTO - highest technical authority

---

#### **Data Entry Registration**
```http
POST /auth/data-entry/register
```
**Purpose**: Register data entry operators  
**Role**: DATA_ENTRY - can add products, categories, locations

---

#### **Login System**
```http
POST /auth/login
```
**Purpose**: Authenticate user and get JWT token  
**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```
**Response**: JWT token + user details

---

#### **OTP Verification**
```http
POST /auth/verify-otp
POST /auth/resend-otp
```
**Purpose**: Verify email/phone with OTP  
**Flow**: Registration → OTP → Account Activation

---

#### **Password Management**
```http
POST /auth/forgot-password
POST /auth/verify-forgot-password-otp  
POST /auth/reset-password
POST /auth/set-password
```
**Purpose**: Complete password reset flow  
**Security**: OTP-based verification for password changes

---

## 👤 **User Management**

### **Base Path**: `/api/user` | `/api/users`

#### **User Profile**
```http
GET /api/user/profile
PUT /api/user/profile
```
**Purpose**: Get/Update current user's profile  
**Auth Required**: Yes  
**Returns**: Full user profile with preferences

---

```http
GET /api/user/me
```
**Purpose**: Get current authenticated user info  
**Quick Check**: Validate token and get basic user data

---

```http
POST /api/user/update-profile
```
**Purpose**: Update specific profile fields  
**Flexible**: Partial updates supported

---

#### **Account Management**
```http
POST /api/user/change-password
```
**Purpose**: Change user password  
**Security**: Requires current password verification

---

```http
POST /api/user/deactivate
POST /api/user/reactivate
DELETE /api/user/delete
```
**Purpose**: Account lifecycle management  
**Deactivate**: Temporary suspension  
**Delete**: Permanent account removal

---

#### **User Analytics**
```http
GET /api/user/stats
GET /api/user/activity
```
**Purpose**: User activity tracking and statistics  
**Stats**: Order count, wishlist, reviews, etc.  
**Activity**: Recent actions, login history

---

#### **Address Management**
```http
GET /api/user/addresses
POST /api/user/addresses
PUT /api/user/addresses/{id}
DELETE /api/user/addresses/{id}
GET /api/user/addresses/{id}
POST /api/user/addresses/{id}/set-default
```
**Purpose**: Complete address book management  
**Features**: Multiple addresses, default selection, delivery preferences

---

#### **KYC & Document Verification**
```http
POST /api/user/kyc/upload
GET /api/user/kyc/status
```
**Purpose**: Upload and track KYC documents  
**Documents**: Aadhar, PAN, Bank details  
**Status**: Pending, Verified, Rejected

---

```http
POST /api/user/pan/verify
GET /api/user/pan/status/{panNumber}
GET /api/user/pan/details/{panNumber}
```
**Purpose**: PAN card verification system  
**Integration**: Third-party PAN verification API  
**Instant**: Real-time PAN validation

---

## 🛒 **Buyer APIs**

### **Base Path**: `/api/buyer` | `/api/buyers`

#### **Buyer Profile & Dashboard**
```http
GET /api/buyers/profile
PUT /api/buyers/profile
GET /api/buyers/dashboard
GET /api/buyers/stats
POST /api/buyers/preferences
```
**Purpose**: Buyer-specific profile management  
**Dashboard**: Orders, wishlist, recommendations  
**Preferences**: Categories, price range, location preferences

---

#### **Product Discovery**
```http
GET /api/buyer/products
GET /api/buyer/products/{id}
POST /api/buyer/products/search
```
**Purpose**: Product browsing and search  
**Features**: Filters, sorting, recommendations  
**Search**: Advanced search with multiple criteria

---

#### **Categories for Buyers**
```http
GET /api/buyer/categories
GET /api/buyer/categories/{id}
```
**Purpose**: Category navigation  
**Features**: Hierarchical structure, product counts

---

#### **Shopping Cart**
```http
GET /api/buyer/cart
POST /api/buyer/cart/add
PUT /api/buyer/cart/update/{itemId}
DELETE /api/buyer/cart/remove/{itemId}
POST /api/buyer/cart/clear
```
**Purpose**: Complete shopping cart functionality  
**Features**: Quantity management, price calculation, cart persistence

---

#### **Wishlist Management**
```http
GET /api/buyer/wishlist
POST /api/buyer/wishlist/add/{productId}
DELETE /api/buyer/wishlist/remove/{productId}
POST /api/buyer/wishlist/clear
```
**Purpose**: Save products for later  
**Features**: Unlimited wishlist, price alerts, share wishlist

---

#### **Order Management**
```http
GET /api/buyer/orders
GET /api/buyer/orders/{id}
POST /api/buyer/orders/{id}/cancel
POST /api/buyer/orders/{id}/return
```
**Purpose**: Order tracking and management  
**Status**: Placed, Confirmed, Shipped, Delivered, Cancelled  
**Features**: Order history, invoice download, tracking

---

#### **Checkout Process**
```http
POST /api/buyer/checkout
```
**Purpose**: Convert cart to order  
**Process**: Address selection, payment method, final confirmation  
**Integration**: Payment gateway, inventory check

---

#### **Quotes & RFQ System**
```http
GET /api/buyer/quotes
POST /api/buyer/quotes/request
GET /api/buyer/quotes/{id}
POST /api/buyer/quotes/{id}/accept
POST /api/buyer/quotes/{id}/reject
```
**Purpose**: Request for Quotations system  
**Bulk Orders**: Get custom pricing for bulk purchases  
**Negotiation**: Price negotiation platform

---

#### **Inquiry System**
```http
GET /api/buyer/inquiries
POST /api/buyer/inquiries
GET /api/buyer/inquiries/{id}
PUT /api/buyer/inquiries/{id}
```
**Purpose**: Product inquiries to vendors  
**Communication**: Direct communication channel  
**Status Tracking**: Inquiry status management

---

#### **Review & Rating System**
```http
GET /api/buyer/reviews
POST /api/buyer/reviews
GET /api/buyer/reviews/{productId}
PUT /api/buyer/reviews/{id}
DELETE /api/buyer/reviews/{id}
```
**Purpose**: Product review and rating  
**Features**: 5-star rating, photo reviews, verified purchase badge  
**Moderation**: Review approval system

---

#### **Lead Management**
```http
GET /api/buyer/leads
POST /api/buyer/leads
GET /api/buyer/leads/{id}
PUT /api/buyer/leads/{id}
DELETE /api/buyer/leads/{id}
```
**Purpose**: Buyer requirements and leads  
**Features**: Post requirements, get vendor responses  
**Matching**: Automated vendor-buyer matching

---

## 🏭 **Vendor APIs**

### **Base Path**: `/api/vendors` | `/api/vendor`

#### **Vendor Profile & Registration**
```http
GET /api/vendors/profile
PUT /api/vendors/profile
GET /api/vendors/dashboard
GET /api/vendors/stats
GET /api/vendors/verification-status
POST /api/vendors/verify-documents
```
**Purpose**: Vendor profile and verification management  
**Verification**: Business license, GST, bank details  
**Dashboard**: Sales analytics, order management

---

#### **Product Management**
```http
GET /api/vendor/products
POST /api/vendor/products
GET /api/vendor/products/{id}
PUT /api/vendor/products/{id}
DELETE /api/vendor/products/{id}
```
**Purpose**: Vendor's product catalog management  
**Features**: Bulk upload, inventory tracking, pricing  
**SEO**: Product optimization for search

---

#### **Media Management**
```http
POST /api/vendor/products/{id}/upload-image
POST /api/vendor/products/{id}/upload-video
```
**Purpose**: Product media upload  
**Formats**: Images (JPG, PNG), Videos (MP4)  
**Optimization**: Auto-resize, compression

---

#### **Order Processing**
```http
GET /api/vendor/orders
GET /api/vendor/orders/{id}
PUT /api/vendor/orders/{id}/status
```
**Purpose**: Vendor order fulfillment  
**Status Management**: Confirm, Pack, Ship, Deliver  
**Notifications**: Real-time order alerts

---

#### **Quote Management**
```http
GET /api/vendor/quotes
POST /api/vendor/quotes/create
PUT /api/vendor/quotes/{id}
```
**Purpose**: Respond to buyer quotation requests  
**Custom Pricing**: Bulk discounts, negotiated rates  
**Validity**: Quote expiry management

---

#### **Vendor Analytics**
```http
GET /api/vendor/analytics/sales
GET /api/vendor/analytics/products
GET /api/vendor/analytics/customers
```
**Purpose**: Business performance metrics  
**Reports**: Sales trends, top products, customer analysis  
**Insights**: Growth recommendations

---

#### **Package & Subscription**
```http
GET /api/vendor/packages
POST /api/vendor/packages/subscribe
GET /api/vendor/packages/current
PUT /api/vendor/packages/upgrade
```
**Purpose**: Vendor subscription management  
**Plans**: Free, Basic, Premium, Enterprise  
**Features**: Product limits, promotion credits

---

## 📦 **Product Management**

### **Base Path**: `/api/products`

#### **Public Product APIs**
```http
GET /api/products
GET /api/products/{id}
GET /api/products/search
GET /api/products/featured
GET /api/products/trending
```
**Purpose**: Public product catalog  
**No Auth Required**: Open for all users  
**Features**: Pagination, sorting, filtering

---

```http
GET /api/products/by-category/{categoryId}
GET /api/products/by-vendor/{vendorId}
```
**Purpose**: Product filtering by category/vendor  
**SEO Friendly**: Clean URLs for better indexing

---

```http
POST /api/products/bulk-search
```
**Purpose**: Advanced search with multiple criteria  
**Filters**: Price, location, rating, availability  
**Performance**: Optimized for large catalogs

---

#### **Product Videos**
```http
GET /api/products/{productId}/videos
POST /api/products/{productId}/videos/upload
DELETE /api/products/{productId}/videos/{videoId}
```
**Purpose**: Product video management  
**Features**: Multiple videos per product, thumbnail generation  
**Streaming**: CDN-optimized video delivery

---

## 📂 **Category Management**

### **Base Path**: `/api/categories`

#### **Public Category APIs**
```http
GET /api/categories
GET /api/categories/{id}
GET /api/categories/tree
GET /api/categories/popular
```
**Purpose**: Category navigation and hierarchy  
**Tree Structure**: Parent-child relationships  
**Popular**: Most browsed categories

---

#### **Admin Category Management**
```http
POST /api/categories
PUT /api/categories/{id}
DELETE /api/categories/{id}
```
**Purpose**: Category CRUD operations  
**Auth Required**: Admin/Data Entry roles  
**Features**: SEO optimization, image upload

---

```http
GET /api/admin/categories/manage
POST /api/admin/categories/create
PUT /api/admin/categories/{id}/update
DELETE /api/admin/categories/{id}/delete
```
**Purpose**: Advanced category management  
**Features**: Bulk operations, category merging  
**SEO**: Meta tags, descriptions

---

## 🏢 **Company Management**

### **Base Path**: `/api/companies`

#### **Company Profile**
```http
GET /api/companies
POST /api/companies
GET /api/companies/{id}
PUT /api/companies/{id}
DELETE /api/companies/{id}
```
**Purpose**: Company profile management  
**Verification**: Business registration verification  
**Features**: Multiple locations, team management

---

```http
GET /api/companies/my-company
POST /api/companies/verify
GET /api/companies/search
```
**Purpose**: Company-specific operations  
**Search**: Find companies by industry, location  
**Verification**: Document verification process

---

## 🔧 **Admin Panel APIs**

### **Base Path**: `/api/admin`

#### **Dashboard & Analytics**
```http
GET /api/admin/dashboard
GET /api/admin/stats
GET /api/admin/analytics
GET /api/admin/analytics/users
GET /api/admin/analytics/products
GET /api/admin/analytics/orders
GET /api/admin/analytics/revenue
```
**Purpose**: Admin dashboard with key metrics  
**Real-time**: Live statistics and charts  
**Reports**: Daily, weekly, monthly reports

---

#### **User Management**
```http
GET /api/admin/users
GET /api/admin/users/{id}
PUT /api/admin/users/{id}
DELETE /api/admin/users/{id}
POST /api/admin/users/{id}/activate
POST /api/admin/users/{id}/deactivate
```
**Purpose**: User lifecycle management  
**Bulk Operations**: Mass user operations  
**Audit Trail**: All changes logged

---

#### **Vendor Management**
```http
GET /api/admin/vendors
GET /api/admin/vendors/{id}
PUT /api/admin/vendors/{id}/approve
PUT /api/admin/vendors/{id}/reject
```
**Purpose**: Vendor approval and verification  
**KYB Process**: Know Your Business verification  
**Document Review**: Business license validation

---

#### **Product Moderation**
```http
GET /api/admin/products
GET /api/admin/products/{id}
PUT /api/admin/products/{id}/approve
PUT /api/admin/products/{id}/reject
DELETE /api/admin/products/{id}
```
**Purpose**: Product content moderation  
**Quality Control**: Ensure product quality standards  
**Bulk Actions**: Approve/reject multiple products

---

#### **Content Management**
```http
GET /api/admin/content
POST /api/admin/content
PUT /api/admin/content/{id}
DELETE /api/admin/content/{id}
```
**Purpose**: Website content management  
**CMS Features**: Pages, banners, announcements  
**SEO**: Meta tags, structured data

---

#### **Site Configuration**
```http
GET /api/admin/config
PUT /api/admin/config
GET /api/admin/config/email-templates
PUT /api/admin/config/email-templates/{type}
```
**Purpose**: System configuration management  
**Settings**: Site settings, email templates, payment config  
**Templates**: Customizable email templates

---

#### **Lead Management**
```http
GET /api/admin/leads
GET /api/admin/leads/{id}
PUT /api/admin/leads/{id}/assign
PUT /api/admin/leads/{id}/status
```
**Purpose**: Sales lead management  
**Assignment**: Assign leads to sales team  
**Tracking**: Lead conversion funnel

---

## 💳 **Payment & Subscription**

### **Base Path**: `/api/payments` | `/api/subscriptions`

#### **Payment Processing**
```http
GET /api/payments/methods
POST /api/payments/create-order
POST /api/payments/verify
POST /api/payments/webhook
GET /api/payments/history
GET /api/payments/{id}
POST /api/payments/refund/{id}
```
**Purpose**: Complete payment processing system  
**Gateways**: Razorpay, PayU, Paytm integration  
**Security**: PCI DSS compliant

---

#### **Subscription Management**
```http
GET /api/subscriptions
POST /api/subscriptions/create
GET /api/subscriptions/{id}
PUT /api/subscriptions/{id}/cancel
PUT /api/subscriptions/{id}/pause
PUT /api/subscriptions/{id}/resume
```
**Purpose**: Subscription billing system  
**Plans**: Flexible pricing models  
**Auto-billing**: Recurring payment handling

---

#### **Webhook Handling**
```http
POST /api/payments/razorpay/webhook
```
**Purpose**: Payment gateway webhook processing  
**Real-time**: Instant payment status updates  
**Security**: Signature verification

---

## 📊 **Analytics & Reports**

### **Base Path**: `/api/analytics`

#### **General Analytics**
```http
GET /api/analytics/dashboard
GET /api/analytics/user-activity
GET /api/analytics/product-views
GET /api/analytics/conversion-rates
GET /api/analytics/traffic-sources
POST /api/analytics/track-event
```
**Purpose**: Business intelligence and analytics  
**Tracking**: User behavior, conversion funnels  
**Reports**: Custom date ranges, export options

---

#### **Vendor Analytics**
```http
GET /api/vendor/analytics/overview
GET /api/vendor/analytics/sales
GET /api/vendor/analytics/products
GET /api/vendor/analytics/customers
```
**Purpose**: Vendor-specific performance metrics  
**Sales Insights**: Revenue trends, top products  
**Customer Analysis**: Repeat customers, demographics

---

## 💬 **Support & Communication**

### **Base Path**: `/api/support` | `/api/chat`

#### **Support Ticket System**
```http
GET /api/support/tickets
POST /api/support/tickets
GET /api/support/tickets/{id}
PUT /api/support/tickets/{id}
POST /api/support/tickets/{id}/close
POST /api/support/tickets/{id}/reply
```
**Purpose**: Customer support ticketing system  
**Categories**: Technical, Billing, General  
**Priority**: Low, Medium, High, Urgent

---

#### **Live Chat System**
```http
GET /api/chat/rooms
GET /api/chat/rooms/{roomId}/messages
POST /api/chat/rooms/{roomId}/messages
POST /api/chat/initiate
```
**Purpose**: Real-time chat between users  
**Features**: File sharing, read receipts  
**Support**: Agent assignment, chat routing

---

#### **Chatbot Integration**
```http
POST /api/chatbot/message
GET /api/chatbot/suggestions
POST /api/chatbot/feedback
```
**Purpose**: AI-powered customer support  
**Intelligence**: Natural language processing  
**Learning**: Continuous improvement from interactions

---

#### **Contact Messages**
```http
POST /api/contact
GET /api/admin/contact-messages
PUT /api/admin/contact-messages/{id}/reply
```
**Purpose**: Contact form submissions  
**Auto-routing**: Based on inquiry type  
**Response**: Email notifications

---

## 📁 **File Management**

### **Base Path**: `/api/files`

#### **File Upload**
```http
POST /api/files/upload
POST /api/files/upload/image
POST /api/files/upload/document
POST /api/files/upload/video
```
**Purpose**: Unified file upload system  
**Validation**: File type, size validation  
**Storage**: Cloud storage with CDN

---

```http
DELETE /api/files/{fileId}
GET /api/files/{fileId}
```
**Purpose**: File management operations  
**Security**: Access control, virus scanning  
**Optimization**: Auto-resize, compression

---

## 📋 **Import/Export**

### **Base Path**: `/api/imports`

#### **Data Import**
```http
POST /api/imports/products
GET /api/imports/template/products
POST /api/imports/categories
GET /api/imports/status/{importId}
```
**Purpose**: Bulk data import system  
**Formats**: Excel, CSV support  
**Validation**: Data validation and error reporting

---

#### **Data Export**
```http
GET /api/exports/products
GET /api/exports/users
GET /api/exports/orders
```
**Purpose**: Data export functionality  
**Formats**: Excel, CSV, PDF  
**Filters**: Date range, status filters

---

## 🌍 **Location & Directory**

### **Base Path**: `/api/locations` | `/api/directory`

#### **Location Management**
```http
GET /api/states
GET /api/states/{stateId}/cities
GET /api/cities
GET /api/cities/{id}
POST /api/cities
PUT /api/cities/{id}
DELETE /api/cities/{id}
```
**Purpose**: Geographic location management  
**Hierarchy**: State → City → Area  
**Services**: Location-based services

---

#### **Business Directory**
```http
GET /api/directory/companies
GET /api/directory/companies/{id}
POST /api/directory/companies/search
GET /api/directory/categories
GET /api/directory/locations
```
**Purpose**: Business directory listings  
**Search**: Location-based business search  
**Verification**: Verified business listings

---

## 🛠 **System & Health**

### **Base Path**: `/api` | `/actuator`

#### **API Information**
```http
GET /api/
GET /api/status
GET /api/info
```
**Purpose**: API status and information  
**Health**: Service health monitoring  
**Version**: API version information

---

#### **Health Monitoring**
```http
GET /actuator/health
GET /health
GET /health/ready
GET /health/alive
```
**Purpose**: Application health checks  
**Monitoring**: Database, external services  
**Status**: UP, DOWN, DEGRADED

---

#### **Database Migration (Admin Only)**
```http
GET /api/admin/migration/status
POST /api/admin/migration/execute
GET /api/admin/migration/audit
POST /api/admin/migration/emergency-rollback
```
**Purpose**: Database migration management  
**Safety**: Backup before migration  
**Audit**: Complete migration history

---

## 🔑 **Authentication Requirements**

### **Public APIs (No Authentication)**
- `GET /api/products/*`
- `GET /api/categories/*`
- `POST /auth/*`
- `GET /actuator/health`
- `GET /api/search/*`

### **User Authentication Required**
- `GET /api/user/*`
- `GET /api/buyer/*`
- `GET /api/vendor/*`
- `POST /api/orders`

### **Admin Authentication Required**
- `GET /api/admin/*`
- `POST /api/admin/*`
- `PUT /api/admin/*`
- `DELETE /api/admin/*`

---

## 📡 **Request/Response Examples**

### **Authentication Header**
```javascript
headers: {
  'Authorization': 'Bearer <jwt_token>',
  'Content-Type': 'application/json'
}
```

### **Standard Response Format**
```json
{
  "success": true,
  "data": { /* response data */ },
  "message": "Operation completed successfully",
  "timestamp": "2025-01-15T10:30:00Z"
}
```

### **Error Response Format**
```json
{
  "success": false,
  "error": "Validation failed",
  "details": {
    "field": "email",
    "message": "Email is required"
  },
  "code": "VALIDATION_ERROR",
  "timestamp": "2025-01-15T10:30:00Z"
}
```

---

## 🎯 **Integration Examples**

### **User Registration Flow**
```javascript
// 1. Register
const response = await fetch('/auth/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    name: 'John Doe',
    email: 'john@example.com',
    phone: '9876543210',
    password: 'securePassword123'
  })
});

// 2. Verify OTP
await fetch('/auth/verify-otp', {
  method: 'POST',
  body: JSON.stringify({
    email: 'john@example.com',
    otp: '123456'
  })
});

// 3. Login
const loginResponse = await fetch('/auth/login', {
  method: 'POST',
  body: JSON.stringify({
    email: 'john@example.com',
    password: 'securePassword123'
  })
});

const { token } = await loginResponse.json();
```

### **Product Search with Filters**
```javascript
const searchParams = new URLSearchParams({
  q: 'laptop',
  category: 'electronics',
  minPrice: '20000',
  maxPrice: '80000',
  location: 'mumbai',
  sortBy: 'price_low_to_high',
  page: '1',
  limit: '20'
});

const products = await fetch(`/api/products/search?${searchParams}`);
```

---

## 🔧 **Environment Configuration**

### **Development**
```
Base URL: http://localhost:8080
CORS: localhost:3000
```

### **Production**
```
Base URL: https://indiantradebackend.onrender.com
CORS: https://indiantrademart.com
```

---

## 🚨 **Rate Limiting**
- **Authentication**: 5 attempts per minute
- **Public APIs**: 100 requests per minute
- **Authenticated APIs**: 300 requests per minute
- **File Upload**: 10 uploads per minute

---

## 📞 **Support**
For API integration support or custom endpoint requirements:
- **Email**: dev@indiantrademart.com
- **Documentation**: Swagger UI available at `/swagger-ui.html`
- **Postman Collection**: Available on request

---

**🎉 Happy Integration! This comprehensive guide covers all 200+ endpoints available in the Indian Trade Mart Backend system.**
