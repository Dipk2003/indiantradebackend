# Vendor Dashboard Fixes

## Current Status: ⚠️ NEEDS MINOR FIXES

The vendor dashboard is mostly functional but some buttons/features need implementation or API integration.

## Required Fixes:

### 1. "Add Price Now" Button Implementation
```javascript
// In VendorProducts.tsx - Around line 122
<button 
  onClick={() => handleAddPriceAction()}
  className="bg-yellow-500 hover:bg-yellow-600 text-white px-4 py-2 rounded-lg text-sm font-medium flex items-center space-x-2 transition-all">
  <span>💰</span>
  <span>Add Price Now</span>
</button>

// Add this function
const handleAddPriceAction = () => {
  // Show modal with product price editing
  // Call API to update prices
  const productsWithoutPrice = products.filter(p => !p.price || p.price === 0);
  // Display these products in a modal or redirect to a bulk price editor
};
```

### 2. Excel Import API Integration
The Excel import component needs proper API integration to the backend:

```javascript
// In ExcelImport.tsx
const handleFileUpload = async (file) => {
  const formData = new FormData();
  formData.append('file', file);
  
  try {
    setUploading(true);
    const response = await fetch('/api/vendor/products/bulk-import', {
      method: 'POST',
      body: formData,
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('authToken')}`
      }
    });
    
    const result = await response.json();
    setUploadResult(result);
    if (result.success) {
      toast.success(`Successfully imported ${result.processedCount} products`);
    } else {
      toast.error(`Import failed: ${result.error}`);
    }
  } catch (error) {
    console.error('Error uploading file:', error);
    toast.error('Failed to upload file');
  } finally {
    setUploading(false);
  }
};
```

### 3. Transaction History Real Data
The transaction history component needs real data integration:

```javascript
// In TransactionHistory.tsx
useEffect(() => {
  const fetchTransactions = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/vendor/transactions', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('authToken')}`
        }
      });
      
      if (!response.ok) throw new Error('Failed to fetch transactions');
      
      const data = await response.json();
      setTransactions(data);
    } catch (error) {
      console.error('Error fetching transactions:', error);
      setError('Failed to load transactions');
    } finally {
      setLoading(false);
    }
  };
  
  fetchTransactions();
}, []);
```

### 4. Real Analytics Data
Replace mock analytics data with real API calls:

```javascript
// In VendorAnalytics.tsx
useEffect(() => {
  const fetchAnalyticsData = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/vendor/analytics/dashboard', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('authToken')}`
        }
      });
      
      if (!response.ok) throw new Error('Failed to fetch analytics');
      
      const data = await response.json();
      setAnalyticsData(data);
    } catch (error) {
      console.error('Error fetching analytics:', error);
      setError('Failed to load analytics data');
    } finally {
      setLoading(false);
    }
  };
  
  fetchAnalyticsData();
}, []);
```

## Implementation Timeline:
1. "Add Price Now" button - 1 day
2. Excel Import API integration - 2 days
3. Transaction History real data - 1 day
4. Analytics real data - 2 days

Total time: 1 week for full vendor dashboard implementation
