# 🚀 Complete Indian Trade Mart API Documentation

## 🌐 Base URLs
- **Local Development**: `http://localhost:8080`
- **AWS Production**: `https://your-eb-app.region.elasticbeanstalk.com`

---

## 🔐 AUTHENTICATION & REGISTRATION

### 1. User Registration
```http
POST /auth/register
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe", 
  "email": "john@example.com",
  "phone": "9876543210",
  "password": "password123"
}
```

### 2. Vendor Registration
```http
POST /auth/vendor/register
Content-Type: application/json

{
  "firstName": "Vendor",
  "lastName": "Company",
  "email": "vendor@example.com", 
  "phone": "9876543210",
  "password": "password123"
}
```

### 3. Admin Registration
```http
POST /auth/admin/register
Content-Type: application/json

{
  "firstName": "Admin",
  "lastName": "User",
  "email": "admin@example.com",
  "phone": "9876543210", 
  "password": "password123"
}
```

### 4. Login (Generic)
```http
POST /auth/login
Content-Type: application/json

{
  "emailOrPhone": "john@example.com",
  "password": "password123"
}
```

### 5. User-Specific Login
```http
POST /auth/user/login
Content-Type: application/json

{
  "emailOrPhone": "john@example.com",
  "password": "password123"
}
```

### 6. Vendor Login
```http
POST /auth/vendor/login
Content-Type: application/json

{
  "emailOrPhone": "vendor@example.com",
  "password": "password123"
}
```

### 7. Admin Login
```http
POST /auth/admin/login
Content-Type: application/json

{
  "emailOrPhone": "admin@example.com",
  "password": "password123"
}
```

### 8. OTP Verification
```http
POST /auth/verify-otp
Content-Type: application/json

{
  "emailOrPhone": "john@example.com",
  "otp": "123456"
}
```

### 9. Forgot Password
```http
POST /auth/forgot-password
Content-Type: application/json

{
  "email": "john@example.com"
}
```

### 10. Verify Forgot Password OTP
```http
POST /auth/verify-forgot-password-otp
Content-Type: application/json

{
  "email": "john@example.com",
  "otp": "123456",
  "newPassword": "newpassword123"
}
```

---

## 👥 USER MANAGEMENT

### 11. Get All Users (Admin Only)
```http
GET /api/users
Authorization: Bearer <admin-token>
```

### 12. Get Users by Role
```http
GET /api/users/role/{role}
# Example: /api/users/role/ROLE_USER
```

### 13. Get User by ID
```http
GET /api/users/{id}
```

### 14. Get User by Email
```http
GET /api/users/email/{email}
```

### 15. Get User by Phone
```http
GET /api/users/phone/{phone}
```

### 16. Get User Count
```http
GET /api/users/count
```

### 17. Check if Email Exists
```http
GET /api/users/exists/email/{email}
```

### 18. Activate User
```http
PATCH /api/users/{id}/activate
```

### 19. Deactivate User
```http
PATCH /api/users/{id}/deactivate
```

---

## 📊 DATA ENTRY MANAGEMENT

### 20. Get All Categories
```http
GET /api/dataentry/categories?search=&page=0&size=10
```

### 21. Create Category
```http
POST /api/dataentry/categories
Content-Type: application/json

{
  "name": "Electronics",
  "description": "Electronic items",
  "isActive": true
}
```

### 22. Update Category
```http
PUT /api/dataentry/categories/{id}
Content-Type: application/json

{
  "name": "Updated Electronics", 
  "description": "Updated description"
}
```

### 23. Delete Category
```http
DELETE /api/dataentry/categories/{id}
```

### 24. Get SubCategories by Category
```http
GET /api/dataentry/categories/{categoryId}/subcategories
```

### 25. Create SubCategory
```http
POST /api/dataentry/subcategories
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Mobile Phones",
  "categoryId": 1,
  "description": "All mobile phones"
}
```

### 26. Get All Products
```http
GET /api/dataentry/products?search=&categoryId=1&page=0&size=10
```

### 27. Create Product
```http
POST /api/dataentry/products
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "iPhone 15",
  "description": "Latest iPhone",
  "categoryId": 1,
  "subCategoryId": 1,
  "basePrice": 80000,
  "isActive": true
}
```

### 28. Bulk Import Categories
```http
POST /api/dataentry/categories/bulk-import
Authorization: Bearer <token>
Content-Type: multipart/form-data

file: categories.xlsx
```

### 29. Export Categories
```http
GET /api/dataentry/export/categories
```

### 30. Data Entry Dashboard Analytics
```http
GET /api/dataentry/analytics/dashboard
```

---

## 🛒 PRODUCT & CATALOG MANAGEMENT

### 31. Get All Products (Public)
```http
GET /api/products?page=0&size=10&search=&categoryId=1
```

### 32. Get Product by ID
```http
GET /api/products/{id}
```

### 33. Search Products
```http
GET /api/products/search?query=mobile&page=0&size=10
```

### 34. Get Products by Category
```http
GET /api/products/category/{categoryId}
```

### 35. Get Featured Products
```http
GET /api/products/featured
```

### 36. Get Popular Products
```http
GET /api/products/popular
```

---

## 🏢 VENDOR MANAGEMENT

### 37. Get All Vendors
```http
GET /api/vendors?page=0&size=10
```

### 38. Get Vendor by ID
```http
GET /api/vendors/{id}
```

### 39. Get Vendor Profile
```http
GET /api/vendors/profile
Authorization: Bearer <vendor-token>
```

### 40. Update Vendor Profile
```http
PUT /api/vendors/profile
Authorization: Bearer <vendor-token>
Content-Type: application/json

{
  "businessName": "ABC Electronics",
  "address": "123 Business Street",
  "city": "Mumbai",
  "state": "Maharashtra",
  "pincode": "400001"
}
```

### 41. Vendor Products
```http
GET /api/vendors/products
Authorization: Bearer <vendor-token>
```

### 42. Add Vendor Product
```http
POST /api/vendors/products
Authorization: Bearer <vendor-token>
Content-Type: application/json

{
  "productId": 1,
  "price": 25000,
  "stock": 100,
  "isAvailable": true
}
```

---

## 📈 ANALYTICS & DASHBOARD

### 43. Global Analytics Dashboard
```http
GET /api/analytics/dashboard
```
**Response:**
```json
{
  "totalUsers": 156,
  "totalProducts": 45,
  "totalVendors": 32,
  "totalOrders": 89,
  "verifiedVendors": 28,
  "activeProducts": 42,
  "totalInquiries": 134,
  "totalReviews": 78
}
```

### 44. Vendor Dashboard (Authentication Required)
```http
GET /api/analytics/vendor/dashboard
Authorization: Bearer <vendor-token>
```

### 45. Vendor Detailed Analytics
```http
GET /api/analytics/vendor/detailed?months=12
Authorization: Bearer <vendor-token>
```

### 46. Revenue Chart Data
```http
GET /api/analytics/vendor/revenue-chart?months=6
Authorization: Bearer <vendor-token>
```

### 47. Admin Analytics
```http
GET /api/admin/analytics/dashboard
Authorization: Bearer <admin-token>
```

### 48. CTO Dashboard
```http
GET /api/cto/dashboard
Authorization: Bearer <cto-token>
```

---

## 🛒 CART & ORDERS

### 49. Get Cart
```http
GET /api/cart
Authorization: Bearer <user-token>
```

### 50. Add to Cart
```http
POST /api/cart/add
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "productId": 1,
  "vendorId": 1,
  "quantity": 2
}
```

### 51. Update Cart Item
```http
PUT /api/cart/update/{itemId}
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "quantity": 3
}
```

### 52. Remove from Cart
```http
DELETE /api/cart/remove/{itemId}
Authorization: Bearer <user-token>
```

### 53. Get User Orders
```http
GET /api/orders
Authorization: Bearer <user-token>
```

### 54. Create Order
```http
POST /api/orders
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "addressId": 1,
  "paymentMethod": "RAZORPAY",
  "items": [
    {
      "productId": 1,
      "vendorId": 1,
      "quantity": 2,
      "price": 25000
    }
  ]
}
```

### 55. Get Order by ID
```http
GET /api/orders/{orderId}
Authorization: Bearer <user-token>
```

---

## 💳 PAYMENT

### 56. Create Payment
```http
POST /api/payments/create
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "orderId": 1,
  "amount": 50000,
  "currency": "INR"
}
```

### 57. Verify Payment
```http
POST /api/payments/verify
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "razorpayOrderId": "order_xyz",
  "razorpayPaymentId": "pay_abc",
  "razorpaySignature": "signature_123"
}
```

---

## 📞 INQUIRIES & LEADS

### 58. Create Inquiry
```http
POST /api/inquiries
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "productId": 1,
  "vendorId": 1,
  "message": "I'm interested in this product",
  "quantity": 10
}
```

### 59. Get User Inquiries
```http
GET /api/inquiries
Authorization: Bearer <user-token>
```

### 60. Get Vendor Inquiries
```http
GET /api/inquiries/vendor
Authorization: Bearer <vendor-token>
```

### 61. Create Lead
```http
POST /api/leads
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "9876543210",
  "company": "ABC Corp",
  "message": "Looking for bulk electronics"
}
```

---

## ⭐ REVIEWS & RATINGS

### 62. Get Product Reviews
```http
GET /api/reviews/product/{productId}
```

### 63. Add Review
```http
POST /api/reviews
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "productId": 1,
  "vendorId": 1,
  "rating": 5,
  "comment": "Excellent product!"
}
```

### 64. Update Review
```http
PUT /api/reviews/{reviewId}
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "rating": 4,
  "comment": "Good product with minor issues"
}
```

---

## 💬 CHAT & MESSAGING

### 65. Get Chat Messages
```http
GET /api/chat/{chatId}
Authorization: Bearer <token>
```

### 66. Send Message
```http
POST /api/chat/send
Authorization: Bearer <token>
Content-Type: application/json

{
  "receiverId": 2,
  "message": "Hello, I'm interested in your product"
}
```

### 67. Chatbot Query
```http
POST /api/chatbot/query
Content-Type: application/json

{
  "message": "What are your delivery charges?",
  "sessionId": "session_123"
}
```

---

## 🏠 USER ADDRESSES

### 68. Get User Addresses
```http
GET /api/addresses
Authorization: Bearer <user-token>
```

### 69. Add Address
```http
POST /api/addresses
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "type": "HOME",
  "address": "123 Main Street",
  "city": "Mumbai",
  "state": "Maharashtra",
  "pincode": "400001",
  "isDefault": true
}
```

---

## 📂 FILE UPLOADS

### 70. Upload File
```http
POST /api/files/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

file: image.jpg
type: PRODUCT_IMAGE
```

### 71. Get File
```http
GET /api/files/{fileId}
```

---

## 🔍 SEARCH

### 72. Global Search
```http
GET /api/search?q=mobile&type=products&page=0&size=10
```

### 73. Advanced Product Search
```http
GET /api/products/search/advanced?category=1&minPrice=1000&maxPrice=50000&location=Mumbai
```

---

## 🎫 SUPPORT

### 74. Create Support Ticket
```http
POST /api/support/tickets
Authorization: Bearer <token>
Content-Type: application/json

{
  "subject": "Payment Issue",
  "description": "Having trouble with payment",
  "priority": "HIGH"
}
```

### 75. Get Support Tickets
```http
GET /api/support/tickets
Authorization: Bearer <token>
```

---

## 📊 ADMIN MANAGEMENT

### 76. Get All Admins
```http
GET /api/admins
Authorization: Bearer <super-admin-token>
```

### 77. Admin Dashboard Stats
```http
GET /api/admin/dashboard
Authorization: Bearer <admin-token>
```

### 78. User Management (Admin)
```http
GET /api/admin/users?page=0&size=10&status=active
Authorization: Bearer <admin-token>
```

### 79. Vendor Approval
```http
POST /api/admin/vendors/{vendorId}/approve
Authorization: Bearer <admin-token>
```

---

## 🏥 HEALTH CHECK

### 80. API Health Check
```http
GET /health
```

### 81. Database Health
```http
GET /health/db
```

---

## 📧 NOTIFICATIONS

### 82. Get Notifications
```http
GET /api/notifications
Authorization: Bearer <token>
```

### 83. Mark Notification as Read
```http
PATCH /api/notifications/{id}/read
Authorization: Bearer <token>
```

---

## 🔒 KYC & VERIFICATION

### 84. Upload KYC Documents
```http
POST /api/kyc/upload
Authorization: Bearer <vendor-token>
Content-Type: multipart/form-data

document: pan_card.jpg
documentType: PAN_CARD
```

### 85. Verify PAN
```http
POST /api/verification/pan
Authorization: Bearer <token>
Content-Type: application/json

{
  "panNumber": "ABCDE1234F",
  "name": "John Doe"
}
```

---

## 🎯 TESTING ENDPOINTS

### 86. Test Database Connection
```http
GET /api/test/db
```

### 87. Test Email Service
```http
POST /api/test/email
Content-Type: application/json

{
  "to": "test@example.com",
  "subject": "Test Email"
}
```

### 88. Test OTP Service
```http
POST /api/test/otp
Content-Type: application/json

{
  "phone": "9876543210"
}
```

---

## 🌟 SPECIAL FEATURES

### 89. Get Categories with Hierarchy
```http
GET /api/dataentry/hierarchy/full
```

### 90. Export Data
```http
GET /api/dataentry/export/products
```

---

## 📝 NOTES

### Authentication
- Most endpoints require JWT token in Authorization header
- Token format: `Bearer <your-jwt-token>`
- Tokens expire after 24 hours

### Rate Limiting
- API calls are rate-limited to 1000 requests per hour per IP
- Bulk operations have separate limits

### Error Codes
- `200` - Success
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

### Pagination
- Most list endpoints support pagination with `page` and `size` parameters
- Default page size is 10
- Maximum page size is 100
