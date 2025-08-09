import React, { useState, useEffect } from 'react';
import axios from 'axios';

const AnalyticsDashboard = () => {
  const [dashboardData, setDashboardData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Backend API base URL - update this to match your backend
  const API_BASE_URL = 'http://localhost:8080/api/analytics';

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      
      // First try the test endpoint (no authentication needed)
      try {
        const testResponse = await axios.get(`${API_BASE_URL}/test-dashboard`);
        if (testResponse.data) {
          console.log('✅ Backend API is working! Using test data:', testResponse.data);
          setDashboardData(testResponse.data);
          setError('Using test data from backend API');
          return;
        }
      } catch (testError) {
        console.log('❌ Test endpoint failed, trying authenticated endpoint...');
      }
      
      // Get JWT token from localStorage or however you store it
      const token = localStorage.getItem('token');
      
      const config = {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      };

      const response = await axios.get(`${API_BASE_URL}/vendor/dashboard`, config);
      setDashboardData(response.data);
      setError(null);
    } catch (err) {
      console.error('Error fetching dashboard data:', err);
      setError('Failed to load dashboard data');
      
      // Use mock data for demonstration
      setDashboardData({
        totalRevenue: 328000,
        totalOrders: 1248,
        avgOrderValue: 2630,
        conversionRate: 3.8,
        revenueGrowth: 12.5,
        orderGrowth: 8.2,
        avgOrderValueGrowth: 5.8,
        conversionRateGrowth: -2.1,
        salesOverview: [
          { month: 'Jan', revenue: 45000, orders: 120 },
          { month: 'Feb', revenue: 52000, orders: 135 },
          { month: 'Mar', revenue: 48000, orders: 128 },
          { month: 'Apr', revenue: 61000, orders: 165 }
        ]
      });
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount);
  };

  const formatPercentage = (value) => {
    const sign = value > 0 ? '+' : '';
    return `${sign}${value}%`;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!dashboardData) {
    return (
      <div className="text-center py-8">
        <p className="text-red-600">Error loading dashboard data</p>
        <button 
          onClick={fetchDashboardData}
          className="mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Vendor Dashboard</h1>
        <p className="text-gray-600">Track your business performance and insights</p>
        
        {/* Time Selector */}
        <div className="mt-4 flex items-center space-x-4">
          <select className="px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            <option>This Month</option>
            <option>Last 3 Months</option>
            <option>Last 6 Months</option>
            <option>This Year</option>
          </select>
          
          <button className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors">
            <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 10v6m0 0l-3-3m3 3l3-3M3 17V7a2 2 0 012-2h6l2 2h6a2 2 0 012 2v10a2 2 0 01-2 2H5a2 2 0 01-2-2z" />
            </svg>
            Export Report
          </button>
        </div>
      </div>

      {/* Key Metrics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {/* Total Revenue */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-sm font-medium text-gray-500">Total Revenue</h3>
            <div className="p-2 bg-orange-100 rounded-full">
              <svg className="w-5 h-5 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
              </svg>
            </div>
          </div>
          <p className="text-2xl font-bold text-gray-900 mb-1">
            {formatCurrency(dashboardData.totalRevenue)}
          </p>
          <p className={`text-sm ${dashboardData.revenueGrowth > 0 ? 'text-green-600' : 'text-red-600'}`}>
            {formatPercentage(dashboardData.revenueGrowth)} from last month
          </p>
        </div>

        {/* Total Orders */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-sm font-medium text-gray-500">Total Orders</h3>
            <div className="p-2 bg-red-100 rounded-full">
              <svg className="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
              </svg>
            </div>
          </div>
          <p className="text-2xl font-bold text-blue-600 mb-1">
            {dashboardData.totalOrders?.toLocaleString()}
          </p>
          <p className={`text-sm ${dashboardData.orderGrowth > 0 ? 'text-green-600' : 'text-red-600'}`}>
            {formatPercentage(dashboardData.orderGrowth)} from last month
          </p>
        </div>

        {/* Avg Order Value */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-sm font-medium text-gray-500">Avg Order Value</h3>
            <div className="p-2 bg-blue-100 rounded-full">
              <svg className="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
              </svg>
            </div>
          </div>
          <p className="text-2xl font-bold text-purple-600 mb-1">
            {formatCurrency(dashboardData.avgOrderValue)}
          </p>
          <p className={`text-sm ${dashboardData.avgOrderValueGrowth > 0 ? 'text-green-600' : 'text-red-600'}`}>
            {formatPercentage(dashboardData.avgOrderValueGrowth)} from last month
          </p>
        </div>

        {/* Conversion Rate */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-sm font-medium text-gray-500">Conversion Rate</h3>
            <div className="p-2 bg-pink-100 rounded-full">
              <svg className="w-5 h-5 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
              </svg>
            </div>
          </div>
          <p className="text-2xl font-bold text-orange-600 mb-1">
            {dashboardData.conversionRate}%
          </p>
          <p className={`text-sm ${dashboardData.conversionRateGrowth > 0 ? 'text-green-600' : 'text-red-600'}`}>
            {formatPercentage(dashboardData.conversionRateGrowth)} from last month
          </p>
        </div>
      </div>

      {/* Sales Overview Chart */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-lg font-semibold text-gray-900">Sales Overview</h2>
          <div className="flex space-x-4">
            <button className="px-4 py-2 bg-blue-600 text-white rounded-md text-sm font-medium">
              Revenue
            </button>
            <button className="px-4 py-2 text-gray-500 hover:text-gray-700 rounded-md text-sm font-medium">
              Orders
            </button>
          </div>
        </div>
        
        <div className="space-y-4">
          {dashboardData.salesOverview?.map((data, index) => (
            <div key={index} className="flex items-center">
              <div className="w-12 text-sm font-medium text-gray-600">
                {data.month}
              </div>
              <div className="flex-1 mx-4">
                <div className="bg-gray-200 rounded-full h-6 relative">
                  <div 
                    className="bg-blue-600 h-6 rounded-full flex items-center justify-end pr-2"
                    style={{ width: `${(data.revenue / Math.max(...dashboardData.salesOverview.map(d => d.revenue))) * 100}%` }}
                  >
                    <span className="text-white text-xs font-medium">
                      {formatCurrency(data.revenue)}
                    </span>
                  </div>
                </div>
              </div>
              <div className="w-20 text-right text-sm text-gray-600">
                {data.orders} orders
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Additional Info */}
      {error && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-4">
          <div className="flex">
            <div className="flex-shrink-0">
              <svg className="h-5 w-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
              </svg>
            </div>
            <div className="ml-3">
              <p className="text-sm text-yellow-800">
                <strong>Note:</strong> Currently showing mock data. Make sure your backend is running on port 8080 and you're authenticated to see real data.
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AnalyticsDashboard;
