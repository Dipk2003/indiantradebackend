# API Endpoints Documentation

## 🌐 Base URL
- **Local Development**: `http://localhost:8080/api`
- **Production**: `https://your-backend-domain.com/api`

## 🔐 Authentication
All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <jwt-token>
```

## 📋 Response Format
All API responses follow this structure:
```json
{
  "success": true,
  "data": {},
  "message": "Operation successful",
  "timestamp": "2025-01-11T10:00:00Z"
}
```

Error responses:
```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE",
  "timestamp": "2025-01-11T10:00:00Z"
}
```

---

## 🔑 Authentication Endpoints

### POST /auth/login
User login authentication
```json
{
  "email": "user@example.com",
  "password": "password123",
  "userType": "buyer" // "admin", "vendor", "buyer"
}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "token": "jwt-token-here",
    "refreshToken": "refresh-token-here",
    "user": {
      "id": "12345",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "BUYER",
      "isVerified": true
    }
  }
}
```

### POST /auth/register
User registration
```json
{
  "firstName": "John",
  "lastName": "Doe", 
  "email": "user@example.com",
  "phoneNumber": "+91-9876543210",
  "password": "password123",
  "confirmPassword": "password123",
  "userType": "buyer",
  "companyName": "Company Ltd", // Optional for vendors
  "gstNumber": "GST123456789", // Optional for vendors
  "address": "123 Street, City",
  "city": "Mumbai",
  "state": "Maharashtra", 
  "pincode": "400001"
}
```

### POST /auth/refresh
Refresh JWT token
```json
{
  "refreshToken": "refresh-token-here"
}
```

### POST /auth/logout
User logout (invalidate tokens)

### POST /auth/forgot-password
Request password reset
```json
{
  "email": "user@example.com"
}
```

### POST /auth/reset-password
Reset password with OTP
```json
{
  "email": "user@example.com",
  "otp": "123456",
  "newPassword": "newpassword123"
}
```

---

## 👤 User Management Endpoints

### GET /users/profile
Get user profile information

### PUT /users/profile  
Update user profile
```json
{
  "name": "John Doe",
  "phone": "+91-9876543210",
  "address": "New Address",
  "city": "Mumbai",
  "state": "Maharashtra",
  "pincode": "400001"
}
```

### POST /users/avatar
Upload user avatar/profile picture
**Content-Type:** `multipart/form-data`

### PUT /users/change-password
Change user password
```json
{
  "oldPassword": "oldpassword123",
  "newPassword": "newpassword123"
}
```

---

## 🛒 Product Endpoints

### GET /products
List products with pagination and filters
**Query Parameters:**
- `page=0` (default)
- `size=20` (default)
- `category=electronics`
- `minPrice=100`
- `maxPrice=5000`
- `search=laptop`
- `sortBy=price`
- `sortDir=asc`

### GET /products/{id}
Get product details by ID

### GET /products/featured
Get featured products

### GET /products/search
Search products
**Query Parameters:**
- `q=search query`
- `category=category-name`
- `location=city-name`

### POST /products (Vendor Only)
Create new product
```json
{
  "name": "Product Name",
  "description": "Product description",
  "price": 999.99,
  "categoryId": 1,
  "subCategoryId": 10,
  "brand": "Brand Name",
  "model": "Model XYZ",
  "sku": "SKU123",
  "stock": 100,
  "minOrderQuantity": 1,
  "unit": "piece",
  "specifications": "Technical specifications",
  "weight": 1.5,
  "dimensions": {
    "length": 10,
    "width": 8,
    "height": 2
  },
  "freeShipping": true,
  "shippingCharge": 0,
  "tags": ["electronics", "gadget"]
}
```

### PUT /products/{id} (Vendor Only)
Update product

### DELETE /products/{id} (Vendor Only)
Delete product

### POST /products/{id}/images (Vendor Only)
Upload product images
**Content-Type:** `multipart/form-data`

---

## 📦 Category Endpoints

### GET /categories
Get all categories

### GET /categories/hierarchy
Get categories with subcategories hierarchy

### GET /categories/{id}/subcategories
Get subcategories for a category

### GET /subcategories/{id}/microcategories
Get microcategories for a subcategory

### POST /categories (Admin Only)
Create new category
```json
{
  "name": "Electronics",
  "description": "Electronic products",
  "isActive": true
}
```

---

## 🛍️ Cart Endpoints

### GET /cart
Get user's cart items

### POST /cart/add
Add item to cart
```json
{
  "productId": "12345",
  "quantity": 2
}
```

### PUT /cart/update
Update cart item quantity
```json
{
  "productId": "12345",
  "quantity": 3
}
```

### DELETE /cart/remove/{productId}
Remove item from cart

### DELETE /cart/clear
Clear entire cart

---

## 📝 Order Endpoints

### GET /orders
Get user's orders with pagination
**Query Parameters:**
- `page=0`
- `size=10`
- `status=PENDING`

### GET /orders/{id}
Get order details by ID

### POST /orders
Create new order
```json
{
  "items": [
    {
      "productId": "12345",
      "quantity": 2,
      "price": 999.99
    }
  ],
  "shippingAddressId": 1,
  "billingAddressId": 1,
  "paymentMethod": "ONLINE", // "COD", "ONLINE", "BANK_TRANSFER"
  "notes": "Handle with care"
}
```

### PUT /orders/{id}/status (Vendor/Admin Only)
Update order status
```json
{
  "status": "SHIPPED", // "PENDING", "CONFIRMED", "SHIPPED", "DELIVERED", "CANCELLED"
  "notes": "Order shipped via courier"
}
```

### GET /orders/{id}/track
Track order status

### POST /orders/{id}/cancel
Cancel order
```json
{
  "reason": "Changed mind"
}
```

---

## 💰 Payment Endpoints

### POST /payments/create-order
Create payment order for Razorpay
```json
{
  "orderId": "ORDER123",
  "amount": 99999, // Amount in paise
  "currency": "INR"
}
```

### POST /payments/verify
Verify Razorpay payment
```json
{
  "razorpay_order_id": "order_id",
  "razorpay_payment_id": "payment_id", 
  "razorpay_signature": "signature"
}
```

### GET /payments/{orderId}
Get payment details for an order

---

## ❓ Inquiry & Quote Endpoints

### GET /inquiries
Get user's inquiries

### POST /inquiries
Create new inquiry
```json
{
  "productId": 12345,
  "subject": "Price inquiry",
  "message": "What's the bulk price for 100 units?"
}
```

### GET /inquiries/{id}
Get inquiry details

### POST /inquiries/{id}/respond (Vendor Only)
Respond to inquiry
```json
{
  "response": "Bulk price for 100 units is Rs. 800 each"
}
```

### GET /quotes
Get user's quotes

### POST /quotes
Create new quote (Vendor to Buyer)
```json
{
  "inquiryId": "inquiry123",
  "price": 80000,
  "quantity": 100,
  "validUntil": "2025-02-15T00:00:00Z",
  "terms": "Payment terms and conditions"
}
```

### PUT /quotes/{id}/accept
Accept a quote

### PUT /quotes/{id}/reject
Reject a quote

---

## ❤️ Wishlist Endpoints

### GET /wishlist
Get user's wishlist

### POST /wishlist
Add product to wishlist
```json
{
  "productId": "12345"
}
```

### DELETE /wishlist/{productId}
Remove product from wishlist

### GET /wishlist/count
Get wishlist items count

---

## 🎧 Support Endpoints

### GET /support/tickets
Get user's support tickets

### POST /support/tickets
Create new support ticket
```json
{
  "subject": "Product issue",
  "description": "Product not working as expected",
  "category": "TECHNICAL",
  "priority": "HIGH" // "LOW", "MEDIUM", "HIGH", "URGENT"
}
```

### GET /support/tickets/{id}
Get ticket details

### POST /support/tickets/{id}/reply
Reply to support ticket
```json
{
  "message": "Thank you for your inquiry..."
}
```

### PUT /support/tickets/{id}/status (Support Only)
Update ticket status
```json
{
  "status": "RESOLVED" // "OPEN", "IN_PROGRESS", "RESOLVED", "CLOSED"
}
```

---

## 💬 Chat Endpoints

### GET /chat/conversations
Get user's chat conversations

### POST /chat/conversations
Start new conversation
```json
{
  "participantId": "vendor123",
  "message": "Hello, I'm interested in your product"
}
```

### GET /chat/conversations/{id}/messages
Get messages for a conversation

### POST /chat/conversations/{id}/messages
Send message in conversation
```json
{
  "message": "When will this be delivered?"
}
```

### WebSocket: /ws/chat
Real-time chat messaging

---

## 👔 Vendor-Specific Endpoints

### GET /vendors/dashboard
Get vendor dashboard data

### GET /vendors/products
Get vendor's products

### GET /vendors/orders
Get orders for vendor's products

### GET /vendors/analytics
Get vendor analytics data

### POST /vendors/products/bulk-import
Bulk import products via Excel
**Content-Type:** `multipart/form-data`

---

## 🛒 Buyer-Specific Endpoints

### GET /buyers/dashboard
Get buyer dashboard data

### GET /buyers/orders
Get buyer's order history

### GET /buyers/inquiries
Get buyer's inquiries

### POST /buyers/leads
Create buyer lead
```json
{
  "productCategory": "Electronics",
  "description": "Looking for laptop suppliers",
  "quantity": 50,
  "budget": 2500000,
  "location": "Mumbai"
}
```

---

## 👑 Admin Endpoints

### GET /admin/dashboard
Get admin dashboard analytics

### GET /admin/users
Get all users with pagination and filters

### GET /admin/vendors
Get all vendors for verification

### PUT /admin/vendors/{id}/verify
Verify vendor account
```json
{
  "verified": true,
  "notes": "All documents verified"
}
```

### GET /admin/products/pending
Get products pending approval

### PUT /admin/products/{id}/approve
Approve/reject product
```json
{
  "approved": true,
  "notes": "Product approved"
}
```

### GET /admin/orders
Get all orders for monitoring

### GET /admin/analytics/summary
Get platform analytics summary

---

## 📊 Analytics Endpoints

### GET /analytics/dashboard
Get dashboard analytics (role-based)

### GET /analytics/sales
Get sales analytics
**Query Parameters:**
- `startDate=2025-01-01`
- `endDate=2025-01-31`
- `groupBy=month` // day, week, month

### GET /analytics/products/top-selling
Get top selling products

### GET /analytics/users/activity
Get user activity analytics

---

## 📋 General Endpoints

### GET /health
Application health check

### GET /actuator/health
Detailed health information (Admin only)

### GET /actuator/info
Application information

### GET /categories/mega-menu
Get data for mega menu

### POST /contact
Contact form submission
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "subject": "Inquiry",
  "message": "I have a question about..."
}
```

---

## 🔄 Status Codes

- **200 OK** - Successful GET requests
- **201 Created** - Successful POST requests creating resources
- **204 No Content** - Successful DELETE requests
- **400 Bad Request** - Invalid request data
- **401 Unauthorized** - Authentication required
- **403 Forbidden** - Access denied
- **404 Not Found** - Resource not found
- **409 Conflict** - Resource already exists
- **422 Unprocessable Entity** - Validation errors
- **429 Too Many Requests** - Rate limit exceeded
- **500 Internal Server Error** - Server error

## 🚀 Rate Limiting

- **Authentication endpoints**: 5 requests per minute per IP
- **General API endpoints**: 100 requests per minute per user
- **File upload endpoints**: 10 requests per minute per user
- **Bulk operations**: 5 requests per minute per user

## 📄 Pagination

All list endpoints support pagination:
```json
{
  "success": true,
  "data": {
    "content": [...],
    "page": 0,
    "size": 20,
    "totalElements": 150,
    "totalPages": 8,
    "first": true,
    "last": false,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

---

**Last Updated**: January 2025  
**API Version**: v1  
**Documentation Format**: OpenAPI 3.0
