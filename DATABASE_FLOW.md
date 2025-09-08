# 🗄️ iTech B2B Database Flow & Entity Relationships

## 📊 Database Entity Relationship Diagram

```
                    ┌─────────────┐
                    │    USER     │ ◄─── Core authentication table
                    │             │
                    │ - id (PK)   │
                    │ - name      │
                    │ - email     │
                    │ - phone     │
                    │ - password  │
                    │ - role      │
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    │             │
         ┌──────────▼──┐      ┌───▼──────┐      ┌─────────▼──┐
         │   BUYERS    │      │ VENDORS  │      │   ADMINS   │
         │             │      │          │      │            │
         │ - user_id   │      │- user_id │      │ - user_id  │
         │ - buyer_type│      │- business│      │ - role     │
         │ - kyc_ver   │      │- kyc_ver │      │ - perms    │
         └──────┬──────┘      └────┬─────┘      └────────────┘
                │                  │
                │            ┌─────▼─────┐
                │            │ PRODUCTS  │
                │            │           │
                │            │- vendor_id│
                │            │- name     │
                │            │- price    │
                │            │- category │
                │            └─────┬─────┘
                │                  │
          ┌─────▼─────┐            │
          │  ORDERS   │◄───────────┘
          │           │
          │- buyer_id │
          │- total    │
          │- status   │
          └─────┬─────┘
                │
         ┌──────▼──────┐
         │ ORDER_ITEMS │
         │             │
         │- order_id   │
         │- product_id │
         │- quantity   │
         │- price      │
         └─────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                     SUPPORTING MODULES                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │ COMPANIES   │    │  PAYMENTS   │    │    CART     │         │
│  │             │    │             │    │             │         │
│  │- comp_name  │    │- order_id   │    │- buyer_id   │         │
│  │- gst_num    │    │- amount     │    │- product_id │         │
│  │- industry   │    │- status     │    │- quantity   │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │    RFQS     │    │ QUOTATIONS  │    │ ANALYTICS   │         │
│  │             │    │             │    │             │         │
│  │- buyer_id   │    │- rfq_id     │    │- user_id    │         │
│  │- title      │    │- vendor_id  │    │- event      │         │
│  │- specs      │    │- price      │    │- timestamp  │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

## 🔗 Primary Entity Relationships

### Core User Flow
```
1. USER Registration
   ├── Creates profile in BUYERS or VENDORS
   ├── Links to COMPANY (optional)
   └── Gets role-based permissions

2. Business Operations
   ├── VENDORS create PRODUCTS
   ├── BUYERS browse and add to CART
   ├── BUYERS create RFQs
   ├── VENDORS respond with QUOTATIONS
   └── Successful negotiations become ORDERS

3. Order Lifecycle  
   ├── ORDER created from CART or RFQ
   ├── Contains multiple ORDER_ITEMS
   ├── Triggers PAYMENT processing
   ├── Updates ANALYTICS data
   └── May generate SUPPORT_TICKETS
```

## 📋 Table Categorization by Function

### 🔐 Authentication & Security (8 tables)
- **user** - Core user authentication
- **otp_verification** - OTP management
- **two_factor_auth** - 2FA settings
- **user_roles** - Role assignments
- **permissions** - Permission definitions
- **roles** - Role management
- **role_permissions** - Role-permission mapping
- **kyc_documents** - KYC verification files

### 👥 User Profiles (12 tables)
- **buyers** - Buyer profiles
- **vendors** - Vendor profiles
- **admins** - Admin profiles
- **user_addresses** - Address management
- **buyer_documents** - Buyer verification docs
- **vendor_documents** - Vendor verification docs
- **vendor_profiles** - Extended vendor profiles
- **employee_profiles** - Employee management
- **employee_roles** - Employee role assignments
- **employee_permissions** - Employee permissions
- **user_address** - User address linkage
- **verification_documents** - Generic verification docs

### 🏢 Business Management (8 tables)
- **companies** - Company profiles
- **company_certifications** - Business certifications
- **company_industries** - Industry classifications
- **company_images** - Company media
- **vendor_certifications** - Vendor certifications
- **vendor_categories** - Vendor categorization
- **vendor_specializations** - Vendor expertise areas
- **vendor_service_areas** - Service coverage areas

### 📦 Product Catalog (20 tables)
- **products** - Main product catalog
- **product_images** - Product photos
- **product_videos** - Product videos
- **product_attributes** - Product specifications
- **product_attribute_values** - Attribute values
- **product_categories** - Product categorization
- **product_variants** - Product variations
- **product_tags** - Product tagging
- **product_documents** - Product documentation
- **product_certifications** - Product certifications
- **product_custom_attributes** - Custom attributes
- **product_quantity_breaks** - Bulk pricing
- **product_shipping_regions** - Shipping info
- **product_cross_sells** - Cross-selling
- **product_upsells** - Up-selling
- **product_related** - Related products
- **categories** - Main categories
- **buyer_category** - Buyer categories
- **buyer_sub_category** - Sub-categories
- **buyer_micro_category** - Micro-categories

### 🛒 Commerce & Orders (15 tables)
- **orders** - Order management
- **order_items** - Order line items
- **order_communications** - Order messaging
- **buyer_orders** - Buyer order history
- **buyer_order_items** - Buyer order items
- **cart** - Shopping cart
- **cart_item** - Cart items
- **payments** - Payment processing
- **payment_refunds** - Refund management
- **invoices** - Billing
- **transactions** - Financial transactions
- **refunds** - Refund tracking
- **coupons** - Discount management
- **wishlist** - User wishlists
- **reviews** - Product/vendor reviews

### 💬 Communication (12 tables)
- **chat_conversations** - Chat system
- **chat_messages** - Chat messages
- **chat_attachments** - Chat file attachments
- **chats** - Chat sessions
- **chatbot_message** - Chatbot interactions
- **support_tickets** - Support system
- **notifications** - System notifications
- **contact_message** - Contact form messages
- **contact_inquiries** - General inquiries
- **rfqs** - Request for quotations
- **rfq_bids** - RFQ responses
- **rfq_attachments** - RFQ file attachments

### 📊 Analytics & Reporting (7 tables)
- **analytics** - Analytics data
- **analytics_metadata** - Analytics metadata
- **analytics_tags** - Analytics tagging
- **activity_logs** - User activity tracking
- **api_logs** - API usage logs
- **error_logs** - Error tracking
- **system_metrics** - System performance

### 🎯 Marketing & Content (8 tables)
- **banners** - Marketing banners
- **campaigns** - Marketing campaigns
- **seo_keywords** - SEO optimization
- **buyer_preferred_categories** - User preferences
- **buyer_leads** - Lead management
- **leads** - General leads
- **buyer_inquiries** - Buyer inquiries
- **inquiries** - General inquiries

### 💰 Subscription & Packages (6 tables)
- **subscription** - Subscription management
- **subscription_plans** - Available plans
- **vendor_packages** - Vendor packages
- **vendor_package_features** - Package features
- **vendor_package_transactions** - Package transactions
- **vendor_ranking** - Vendor performance ranking

### 📍 Location & Utilities (6 tables)
- **cities** - City master data
- **states** - State master data
- **buyer_industries** - Buyer industry classification
- **vendor_payment_methods** - Vendor payment options
- **vendor_gst_selection** - GST preferences
- **vendor_tax_profile** - Tax configurations

## 🔄 Data Flow Patterns

### User Registration Flow
```
1. POST /auth/register
   ├── Creates entry in 'user' table
   ├── Sends OTP via 'otp_verification'
   ├── Creates profile in 'buyers' or 'vendors'
   └── Links to 'companies' if business user

2. Profile Setup
   ├── Updates profile tables
   ├── Uploads documents to 'kyc_documents'
   ├── Sets preferences and categories
   └── Configures payment methods
```

### Product Catalog Flow
```
1. Vendor adds product
   ├── Creates entry in 'products'
   ├── Adds images to 'product_images'
   ├── Sets attributes in 'product_attributes'
   ├── Links to categories
   └── Updates search indexes

2. Buyer browsing
   ├── Searches 'products' with filters
   ├── Views product details and images
   ├── Adds to 'cart' or 'wishlist'
   └── Tracks activity in 'analytics'
```

### Order Processing Flow
```
1. Order Placement
   ├── Converts 'cart' to 'orders'
   ├── Creates 'order_items' for each product
   ├── Initiates 'payments' processing
   └── Sends notifications to vendor

2. Order Fulfillment
   ├── Vendor updates order status
   ├── Tracks shipping information
   ├── Handles communications
   ├── Processes payments and invoices
   └── Updates analytics data
```

## 🗃️ Database Optimization Insights

### High-Traffic Tables
- **products** - Heavily queried for search
- **orders** - Core business transactions
- **analytics** - Continuous data insertion
- **notifications** - Real-time messaging

### Index Optimization
- Product search indexes on name, category, price
- Order indexes on buyer_id, status, created_at
- User indexes on email, phone, role
- Analytics indexes on timestamp, user_id

### Archival Considerations
- **activity_logs** - Consider rotating old data
- **api_logs** - Archive logs older than 6 months
- **error_logs** - Keep recent logs for debugging
- **order_communications** - Archive completed orders

## 🧹 Database Cleanup Completed

### ✅ Removed Tables (Previously Unused)
- **users** - Duplicate of 'user' table
- **legacy_vendors** - Old vendor migration data
- **service_providers** - Replaced by vendors
- **service_provider_images** - Replaced by vendor images
- **service_provider_reviews** - Replaced by unified reviews

### 📈 Current Database Status
- **Total Active Tables**: 95+ tables
- **Core Entities**: 4 (user, buyers, vendors, admins)
- **Business Objects**: 15+ (orders, products, companies, etc.)
- **Supporting Systems**: 75+ tables
- **Database Size**: Optimized after cleanup

---

## 🚀 Frontend Integration Recommendations

### 📱 API Endpoint Patterns
```javascript
// User Management
GET /api/buyers/{id}
PUT /api/buyers/{id}/profile
POST /api/buyers/{id}/verify/kyc

// Product Catalog
GET /api/products?category={cat}&page={p}
GET /api/products/search?q={query}
POST /api/products (vendor only)

// Order Management
POST /api/orders
GET /api/orders/{id}/status
PATCH /api/orders/{id}/payment
```

### 🔄 Real-time Updates
- WebSocket for order status updates
- Server-sent events for notifications
- Real-time chat messaging
- Live inventory updates

### 📊 Dashboard Data Flow
```javascript
// Buyer Dashboard
- Recent orders from 'orders' table
- Wishlist items from 'wishlist'
- Notifications from 'notifications'
- RFQ status from 'rfqs' and 'quotations'

// Vendor Dashboard  
- Product performance from 'analytics'
- Order management from 'orders'
- Revenue tracking from 'payments'
- Customer communications from 'chats'

// Admin Dashboard
- System analytics from multiple tables
- User management across user tables
- Business intelligence from 'analytics'
- Support ticket management
```

This database flow documentation provides a comprehensive view of how your iTech B2B marketplace data is structured and flows through the system. The cleanup has optimized the database by removing redundant tables, making it more efficient for your frontend integration.
