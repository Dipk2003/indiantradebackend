# Analytics Dashboard Setup Guide

## Overview
This guide helps you integrate the dynamic analytics dashboard with your backend API and database. The system replaces static data with real-time analytics from your database.

## What We've Built

### 1. Backend Analytics API
- **AnalyticsDashboardController**: New REST controller with vendor analytics endpoints
- **Enhanced VendorAnalyticsService**: Service with comprehensive database queries
- **Database Integration**: Real queries to fetch actual data from your database

### 2. Frontend Components
- **AnalyticsDashboard.jsx**: React component that matches your UI design
- **Dynamic Data Loading**: Replaces static data with API calls
- **Error Handling**: Graceful fallback to mock data if API fails

### 3. API Documentation
- Complete endpoint documentation with request/response examples
- Integration guides for React/JavaScript
- Security and performance considerations

## Files Added/Modified

### New Files:
1. `src/main/java/com/itech/itech_backend/controller/AnalyticsDashboardController.java`
2. `AnalyticsDashboard.jsx` (React component)
3. `ANALYTICS_API_DOCS.md`
4. `SETUP_GUIDE.md` (this file)

### Enhanced Files:
1. `src/main/java/com/itech/itech_backend/service/AdminAnalyticsService.java` (added helper method)

## Setup Instructions

### Backend Setup

1. **Start the Backend Server**
   ```bash
   cd D:\itech-backend\itech-backend
   ./mvnw spring-boot:run
   ```
   The server will start on `http://localhost:8080`

2. **Database Configuration**
   - Ensure your database is running and properly configured
   - Check `application.properties` for database connection settings
   - Verify all required tables exist (vendors, products, orders, inquiries, quotes, etc.)

3. **Test the APIs**
   ```bash
   # Test endpoint (replace YOUR_JWT_TOKEN with actual token)
   curl -X GET "http://localhost:8080/api/analytics/vendor/dashboard" \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -H "Content-Type: application/json"
   ```

### Frontend Setup

1. **Copy the React Component**
   - Copy `AnalyticsDashboard.jsx` to your frontend project
   - Place it in your components directory: `src/components/AnalyticsDashboard.jsx`

2. **Install Dependencies** (if not already installed)
   ```bash
   npm install axios
   # or
   yarn add axios
   ```

3. **Update Your Route/Page**
   ```jsx
   import AnalyticsDashboard from './components/AnalyticsDashboard';
   
   // In your analytics route/page
   function AnalyticsPage() {
     return <AnalyticsDashboard />;
   }
   ```

4. **Configure API Base URL**
   Update the API_BASE_URL in the component:
   ```jsx
   const API_BASE_URL = 'http://localhost:8080/api/analytics';
   ```

### Authentication Setup

1. **JWT Token Storage**
   Ensure your frontend stores JWT tokens properly:
   ```jsx
   // After successful login
   localStorage.setItem('token', jwtToken);
   
   // Or use secure HTTP-only cookies
   ```

2. **API Interceptors** (Optional but Recommended)
   ```jsx
   import axios from 'axios';
   
   // Add request interceptor to automatically include auth token
   axios.interceptors.request.use(
     (config) => {
       const token = localStorage.getItem('token');
       if (token) {
         config.headers.Authorization = `Bearer ${token}`;
       }
       return config;
     },
     (error) => Promise.reject(error)
   );
   ```

## API Endpoints Available

### Main Dashboard Data
- `GET /api/analytics/vendor/dashboard` - Complete dashboard overview
- `GET /api/analytics/vendor/detailed` - Detailed analytics with all metrics
- `GET /api/analytics/vendor/revenue-chart` - Revenue chart data
- `GET /api/analytics/vendor/metrics` - Key performance indicators

### Data Structure
The API returns data that matches your frontend expectations:
```javascript
{
  totalRevenue: 328000,      // From database orders
  totalOrders: 1248,         // Actual order count
  avgOrderValue: 2630,       // Calculated: revenue / orders
  conversionRate: 3.8,       // Calculated: orders / inquiries
  revenueGrowth: 12.5,       // Month-over-month growth %
  orderGrowth: 8.2,          // Month-over-month growth %
  salesOverview: [...]       // Monthly data for charts
}
```

## Database Queries

The system uses these main queries:
- **Orders**: Revenue, order counts, customer analytics
- **Products**: Product performance, inventory status
- **Inquiries**: Conversion rate calculations
- **Reviews**: Average ratings and feedback
- **Vendors**: Profile and verification data

## Testing & Verification

### 1. Backend API Testing
```bash
# Test with curl
curl -X GET "http://localhost:8080/api/analytics/vendor/dashboard" \
  -H "Authorization: Bearer <your-token>"

# Expected response: JSON with dashboard data
```

### 2. Frontend Integration Testing
1. Start your React development server
2. Navigate to the analytics page
3. Check browser console for any API errors
4. Verify data loads correctly or shows mock data

### 3. Database Data Verification
1. Check that your database has sample data in key tables
2. Verify vendor associations are correct
3. Ensure date ranges in test data are recent

## Troubleshooting

### Common Issues

1. **401 Unauthorized Error**
   - Check JWT token validity
   - Verify token is included in Authorization header
   - Ensure user has VENDOR role

2. **CORS Errors**
   - Check `@CrossOrigin` annotation in controller
   - Update allowed origins if needed
   - Configure proper CORS in Spring Security

3. **No Data Returned**
   - Verify database has sample data
   - Check vendor ID associations
   - Review query parameters and filters

4. **API Not Found (404)**
   - Confirm backend server is running on port 8080
   - Check endpoint URLs match exactly
   - Verify Spring Boot started successfully

### Debug Steps

1. **Check Backend Logs**
   ```bash
   # Look for errors in Spring Boot console output
   ./mvnw spring-boot:run
   ```

2. **Test Database Queries**
   ```sql
   -- Test basic vendor data exists
   SELECT COUNT(*) FROM vendors WHERE email = 'your-vendor-email';
   
   -- Test order data
   SELECT COUNT(*) FROM orders o 
   JOIN order_items oi ON o.id = oi.order_id 
   JOIN vendors v ON oi.vendor_id = v.id 
   WHERE v.email = 'your-vendor-email';
   ```

3. **Frontend Network Tab**
   - Open browser Developer Tools > Network
   - Check API requests and responses
   - Verify status codes and response data

## Performance Optimization

### Backend Optimizations
1. **Database Indexing**
   ```sql
   -- Add indexes for better query performance
   CREATE INDEX idx_orders_vendor_created ON orders(vendor_id, created_at);
   CREATE INDEX idx_products_vendor_active ON products(vendor_id, is_active);
   ```

2. **Caching** (Optional)
   - Add Redis cache for frequently accessed data
   - Cache vendor statistics for 5-10 minutes

### Frontend Optimizations
1. **Data Caching**: Cache API responses for 30-60 seconds
2. **Loading States**: Show skeleton loaders while fetching
3. **Error Boundaries**: Implement React error boundaries

## Next Steps

1. **Customize the Dashboard**
   - Modify the React component to match your exact design
   - Add additional metrics as needed
   - Customize colors and styling

2. **Add Real-time Updates**
   - Implement WebSocket connections
   - Add periodic data refresh
   - Show live notifications

3. **Enhanced Analytics**
   - Add date range pickers
   - Implement data export features
   - Add more detailed charts and graphs

4. **Security Enhancements**
   - Implement API rate limiting
   - Add data validation
   - Enhance error handling

## Support

If you encounter issues:
1. Check the logs for error messages
2. Verify database connections and data
3. Test API endpoints with tools like Postman
4. Review the API documentation for proper request format

The system is designed to gracefully handle errors and show mock data if the backend is unavailable, ensuring your frontend remains functional during development.
