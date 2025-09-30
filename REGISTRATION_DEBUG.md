# 🔧 Registration Issue Fix & Debug Guide

## ✅ **Fixed Issues:**

1. **CORS Configuration**: Added `https://indiantrademar.netlify.app` to allowed origins
2. **Backend is Live**: ✅ `https://indiantradebackend.onrender.com`
3. **Endpoints Available**: All registration endpoints working

## 🚀 **Next Steps:**

### 1. Push Backend Fix to GitHub:
```bash
git add .
git commit -m "Add Netlify URL to CORS configuration"
git push origin main
```

### 2. Update Netlify Environment Variables:
Go to Netlify Dashboard → Site Settings → Environment Variables

Add these **exact** variables:
```bash
NEXT_PUBLIC_API_BASE_URL=https://indiantradebackend.onrender.com
NEXT_PUBLIC_API_URL=https://indiantradebackend.onrender.com/api  
NEXT_PUBLIC_AUTH_API_URL=https://indiantradebackend.onrender.com/auth
NODE_ENV=production
```

### 3. Test Registration Endpoints:

**User Registration:**
```bash
curl -X POST https://indiantradebackend.onrender.com/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com", 
    "phone": "1234567890",
    "password": "testpass123"
  }'
```

**Vendor Registration:**
```bash
curl -X POST https://indiantradebackend.onrender.com/auth/vendor/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Vendor",
    "email": "vendor@example.com",
    "phone": "1234567890", 
    "password": "testpass123"
  }'
```

## 🔍 **Debug Frontend Issue:**

### Check Browser Console:
1. Open your Netlify site: `https://indiantrademar.netlify.app`
2. Open Developer Tools (F12)
3. Go to **Console** tab
4. Try registration
5. Look for CORS errors or network errors

### Common Issues & Solutions:

#### Issue 1: CORS Error
```
Access to fetch at 'https://indiantradebackend.onrender.com/auth/register' 
from origin 'https://indiantrademar.netlify.app' has been blocked by CORS policy
```
**Solution**: ✅ Already fixed by adding Netlify URL to CORS config

#### Issue 2: Network Error
```
TypeError: Failed to fetch
```
**Solution**: Check if API URL is correct in frontend code

#### Issue 3: API URL Wrong
**Frontend should use:**
- Registration: `https://indiantradebackend.onrender.com/auth/register`
- Login: `https://indiantradebackend.onrender.com/auth/login`

## 📋 **Verification Checklist:**

- [ ] Backend deployed with CORS fix
- [ ] Netlify environment variables updated
- [ ] Frontend redeployed
- [ ] Registration form sends request to correct URL
- [ ] Browser console shows no CORS errors
- [ ] Backend logs show incoming registration requests

## 🎯 **Expected Flow:**

1. **Frontend Form Submit** → 
2. **POST to** `https://indiantradebackend.onrender.com/auth/register` → 
3. **Backend Process** → 
4. **OTP Email Sent** → 
5. **Success Response** → 
6. **Frontend Shows Success Message**

## 🆘 **Still Not Working?**

Share the **browser console error** and I'll help debug further!

After pushing the CORS fix and redeploying, registration should work! 🎉
