# Vendor Package Subscription System

## Overview

The Vendor Package Subscription System provides a comprehensive solution for vendors to purchase subscription packages with different tiers (Silver, Gold, Platinum, Diamond) offering various features and limitations.

## Architecture

### Core Components

1. **Models**
   - `VendorPackage` - Defines package plans with features and pricing
   - `VendorPackageFeature` - Individual features for each package
   - `VendorPackageTransaction` - Transaction records for package purchases

2. **Services**
   - `VendorPackageService` - Core business logic for package management
   - `VendorPackageInitializationService` - Initializes default packages

3. **Controllers**
   - `VendorPackageController` - REST API endpoints for vendor dashboard

4. **Repositories**
   - `VendorPackageRepository`
   - `VendorPackageFeatureRepository` 
   - `VendorPackageTransactionRepository`

## Package Tiers

### 1. Silver Plan (₹2,499/month)
- **Target**: Small businesses getting started
- **Features**:
  - 50 products, 100 leads
  - Basic dashboard
  - GST compliance
  - Inventory management
  - Bulk import/export
  - 1 GB storage
  - 7-day trial

### 2. Gold Plan (₹4,999/month) 
- **Target**: Growing businesses
- **Features**:
  - 200 products, 500 leads
  - Featured listings
  - Priority support
  - Analytics access
  - API access (5,000 calls/month)
  - Multi-location support
  - Payment gateway integration
  - 5 GB storage
  - 14-day trial

### 3. Platinum Plan (₹8,499/month)
- **Target**: Established businesses
- **Features**:
  - 1,000 products, 2,000 leads
  - Custom branding
  - Advanced analytics
  - Chatbot priority
  - API access (20,000 calls/month)
  - Loyalty program
  - Advanced inventory
  - 20 GB storage
  - 30-day trial

### 4. Diamond Plan (₹16,999/month)
- **Target**: Enterprise clients
- **Features**:
  - Unlimited products and leads
  - Complete white-label
  - AI-powered insights
  - Custom development
  - Unlimited API access
  - Enterprise integrations
  - Dedicated success team
  - Unlimited storage
  - 30-day trial

## API Endpoints

### Get All Packages
```http
GET /api/vendor/packages/all
Authorization: Bearer {vendor-token}
```

### Get Popular Packages
```http
GET /api/vendor/packages/popular
Authorization: Bearer {vendor-token}
```

### Get Packages by Type
```http
GET /api/vendor/packages/type/{planType}
Authorization: Bearer {vendor-token}
```

### Purchase Package
```http
POST /api/vendor/packages/purchase
Authorization: Bearer {vendor-token}
Content-Type: application/json

{
  "planId": 1,
  "paymentMethod": "RAZORPAY",
  "billingAddress": "123 Business Street",
  "billingCity": "Mumbai",
  "billingState": "Maharashtra",
  "billingPincode": "400001",
  "gstNumber": "27AAAAA0000A1Z5"
}
```

### Get Current Subscription
```http
GET /api/vendor/packages/subscription/current
Authorization: Bearer {vendor-token}
```

### Get Transaction History
```http
GET /api/vendor/packages/transactions/history
Authorization: Bearer {vendor-token}
```

### Get Package Comparison
```http
GET /api/vendor/packages/comparison
Authorization: Bearer {vendor-token}
```

### Get Dashboard Summary
```http
GET /api/vendor/packages/dashboard/summary
Authorization: Bearer {vendor-token}
```

## Business Logic

### Package Purchase Flow
1. Vendor selects a package
2. System calculates total amount (including taxes)
3. Transaction record is created with PENDING status
4. Payment is processed through payment gateway
5. On successful payment, subscription is activated
6. Previous subscription is cancelled
7. Invoice is generated (if requested)

### Subscription Management
- Only one active subscription per vendor
- Automatic expiry handling
- Upgrade/downgrade capabilities
- Transaction history tracking
- Usage limits enforcement

### Feature Access Control
```java
// Example usage in business logic
if (!vendorPackageService.canPerformAction("ADD_PRODUCT", vendor)) {
    throw new LimitExceededException("Product limit exceeded for current plan");
}
```

## Database Schema

### vendor_packages
- Core package information
- Feature flags
- Pricing details
- Limits and quotas

### vendor_package_features
- Detailed feature descriptions
- Feature categorization
- Display ordering

### vendor_package_transactions
- Payment processing
- Transaction status tracking
- Billing information
- Installment support

## Configuration

### Payment Gateway Integration
```yaml
payment:
  razorpay:
    key: ${RAZORPAY_KEY}
    secret: ${RAZORPAY_SECRET}
  tax:
    gst_rate: 0.18
```

### Package Features Configuration
Features are categorized as:
- **CORE**: Basic functionality
- **PREMIUM**: Advanced features
- **BUSINESS**: Business-specific tools
- **TECHNICAL**: API and integrations
- **SUPPORT**: Support levels
- **LIMIT**: Usage limits
- **BENEFIT**: Additional benefits

## Usage Examples

### Frontend Integration
```javascript
// Get all packages
const response = await fetch('/api/vendor/packages/all', {
  headers: {
    'Authorization': 'Bearer ' + vendorToken,
    'Content-Type': 'application/json'
  }
});
const packages = await response.json();

// Purchase package
const purchaseData = {
  planId: selectedPackage.id,
  paymentMethod: 'RAZORPAY',
  billingAddress: billingForm.address,
  // ... other billing details
};

const purchaseResponse = await fetch('/api/vendor/packages/purchase', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + vendorToken,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(purchaseData)
});
```

### Backend Service Usage
```java
@Autowired
private VendorPackageService vendorPackageService;

// Check if vendor can add products
public void addProduct(Product product) {
    if (!vendorPackageService.canPerformAction("ADD_PRODUCT", getCurrentVendor())) {
        throw new LimitExceededException("Product limit reached. Please upgrade your plan.");
    }
    // Proceed with adding product
}

// Get vendor's current limits
public Map<String, Object> getVendorLimits() {
    return vendorPackageService.getVendorSubscriptionDetails();
}
```

## Security Considerations

1. **Authentication**: All endpoints require vendor authentication
2. **Authorization**: Package-specific feature access control
3. **Payment Security**: Secure payment gateway integration
4. **Data Privacy**: Billing information encryption
5. **Rate Limiting**: API call limits based on subscription

## Monitoring and Analytics

### Key Metrics
- Package adoption rates
- Upgrade/downgrade patterns  
- Transaction success rates
- Revenue by package tier
- Feature usage analytics

### Alerts
- Payment failures
- Subscription expirations
- Limit violations
- Transaction anomalies

## Future Enhancements

1. **Coupon System**: Discount codes and promotional offers
2. **Referral Program**: Vendor referral rewards
3. **Usage Analytics**: Detailed feature usage tracking
4. **Auto-scaling**: Dynamic limit adjustments
5. **Multi-currency**: International pricing support
6. **A/B Testing**: Package pricing optimization

## Testing

### Unit Tests
- Service layer business logic
- Repository query methods
- DTO validations

### Integration Tests
- Complete purchase flow
- Payment gateway integration
- Database transactions

### API Tests
- All REST endpoints
- Authentication/authorization
- Error handling

## Deployment

### Database Migration
```bash
# Run flyway migration
./gradlew flywayMigrate
```

### Environment Variables
```bash
SPRING_PROFILES_ACTIVE=production
RAZORPAY_KEY=your_razorpay_key
RAZORPAY_SECRET=your_razorpay_secret
DATABASE_URL=jdbc:mysql://localhost:3306/itech_db
```

### Health Checks
- Package service availability
- Payment gateway connectivity
- Database connection status

---

This vendor package system provides a robust foundation for subscription-based B2B marketplace monetization with comprehensive feature management and payment processing capabilities.
