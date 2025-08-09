# Analytics Dashboard API Documentation

## Overview
This document describes the analytics API endpoints that provide real-time data for the vendor dashboard. All endpoints require authentication with a valid JWT token.

## Base URL
```
http://localhost:8080/api/analytics
```

## Authentication
All endpoints require a valid JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## Endpoints

### 1. Vendor Dashboard Overview
Get comprehensive dashboard data for the authenticated vendor.

**Endpoint:** `GET /vendor/dashboard`

**Response:**
```json
{
  "totalRevenue": 328000,
  "totalOrders": 1248,
  "avgOrderValue": 2630,
  "conversionRate": 3.8,
  "revenueGrowth": 12.5,
  "orderGrowth": 8.2,
  "avgOrderValueGrowth": 5.8,
  "conversionRateGrowth": -2.1,
  "salesOverview": [
    {
      "month": "Jan",
      "revenue": 45000,
      "orders": 120
    },
    {
      "month": "Feb", 
      "revenue": 52000,
      "orders": 135
    }
  ]
}
```

### 2. Detailed Analytics
Get comprehensive analytics data including all metrics.

**Endpoint:** `GET /vendor/detailed?months=12`

**Parameters:**
- `months` (optional): Number of months of historical data (default: 12)

**Response:**
```json
{
  "dashboard": {
    "totalProducts": 45,
    "activeProducts": 42,
    "totalOrders": 128,
    "monthlyRevenue": 45000,
    "totalInquiries": 89,
    "completedOrders": 116,
    "pendingQuotes": 12,
    "averageRating": 4.7
  },
  "revenue": {
    "data": [
      {
        "month": "Jan",
        "revenue": 35000,
        "orders": 35,
        "averageOrderValue": 1000,
        "profit": 10500
      }
    ]
  },
  "orders": {
    "totalOrders": 128,
    "pendingOrders": 15,
    "completedOrders": 105,
    "cancelledOrders": 8,
    "recentOrders": []
  },
  "customers": {
    "totalCustomers": 45,
    "newCustomers": 8,
    "customerGrowth": 8.5,
    "topCustomers": []
  },
  "products": {
    "products": [
      {
        "productId": 1,
        "productName": "Industrial Sensors",
        "category": "Electronics",
        "views": 245,
        "inquiries": 23,
        "orders": 12,
        "revenue": 15000,
        "rating": 4.5,
        "conversionRate": 0.049
      }
    ]
  }
}
```

### 3. Revenue Chart Data
Get revenue analytics data for charts.

**Endpoint:** `GET /vendor/revenue-chart?months=6`

**Parameters:**
- `months` (optional): Number of months of data (default: 6)

**Response:**
```json
{
  "data": [
    {
      "month": "Jan",
      "revenue": 35000,
      "orders": 100,
      "averageOrderValue": 350
    },
    {
      "month": "Feb",
      "revenue": 42000,
      "orders": 120,
      "averageOrderValue": 350
    }
  ]
}
```

### 4. Key Metrics Summary
Get key performance indicators for the vendor.

**Endpoint:** `GET /vendor/metrics`

**Response:**
```json
{
  "totalProducts": 45,
  "activeProducts": 42,
  "totalOrders": 128,
  "completedOrders": 116,
  "pendingQuotes": 12,
  "totalInquiries": 89,
  "monthlyRevenue": 45000,
  "averageRating": 4.7,
  "profileViews": 1250,
  "unreadMessages": 7
}
```

## Error Handling

All endpoints return appropriate HTTP status codes:
- `200 OK`: Success
- `401 Unauthorized`: Invalid or missing JWT token
- `403 Forbidden`: User doesn't have required permissions
- `404 Not Found`: Endpoint not found
- `500 Internal Server Error`: Server error

Error response format:
```json
{
  "error": "Error message",
  "timestamp": "2024-01-01T12:00:00Z",
  "status": 401
}
```

## Frontend Integration

### Using Axios (React)
```javascript
import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080/api/analytics';

// Get dashboard data
const fetchDashboardData = async () => {
  try {
    const token = localStorage.getItem('token');
    const response = await axios.get(`${API_BASE_URL}/vendor/dashboard`, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    return response.data;
  } catch (error) {
    console.error('Error fetching dashboard data:', error);
    throw error;
  }
};
```

### Using Fetch API
```javascript
const fetchDashboardData = async () => {
  try {
    const token = localStorage.getItem('token');
    const response = await fetch('http://localhost:8080/api/analytics/vendor/dashboard', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
};
```

## Data Flow

1. **Frontend Request**: React component calls API endpoint with JWT token
2. **Backend Authentication**: Spring Security validates the JWT token
3. **Database Query**: Service layer queries database for vendor-specific data
4. **Data Processing**: Service calculates metrics, growth rates, and formats data
5. **Response**: JSON response sent back to frontend
6. **UI Update**: React component updates state and re-renders with new data

## Real-time Updates

For real-time dashboard updates, consider implementing:
- WebSocket connections for live data
- Polling every 30-60 seconds for fresh data
- Server-Sent Events (SSE) for push notifications

## Database Tables Used

The analytics API queries the following database tables:
- `vendors` - Vendor information
- `products` - Product catalog
- `orders` - Order details and order items
- `inquiries` - Customer inquiries
- `quotes` - Vendor quotes
- `reviews` - Customer reviews
- `chat_messages` - Chat/messaging data

## Performance Considerations

1. **Caching**: Consider implementing Redis caching for frequently accessed data
2. **Database Indexing**: Ensure proper indexes on vendor_id, created_at columns
3. **Query Optimization**: Use database-specific optimizations for complex aggregations
4. **Rate Limiting**: Implement API rate limiting to prevent abuse

## Security Notes

1. All endpoints require valid vendor role authentication
2. Data is filtered by vendor ownership (vendors can only see their own data)
3. Input validation is performed on all parameters
4. SQL injection prevention through parameterized queries

## Running the Backend

1. Make sure you have Java 11+ and Maven installed
2. Navigate to the backend directory
3. Run: `./mvnw spring-boot:run`
4. Backend will start on port 8080

## Testing the APIs

You can test the APIs using:
- Postman/Insomnia with proper JWT tokens
- Frontend applications
- curl commands with authentication headers

Example curl command:
```bash
curl -X GET "http://localhost:8080/api/analytics/vendor/dashboard" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```
