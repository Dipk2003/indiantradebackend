# Next.js Subdomain Middleware Implementation

This document provides a complete guide for implementing subdomain routing with Next.js middleware to work with the itech-backend subdomain system.

## 🚀 Implementation Overview

The middleware system handles:
- Subdomain extraction and validation
- Route rewrites for subdomain-specific content
- CORS headers for subdomain requests
- Vendor-specific routing (vendor.example.com)
- Admin panel routing (admin.example.com)
- Development environment support

## 📁 File Structure

```
frontend/
├── middleware.ts                 # Main middleware file
├── lib/
│   ├── subdomain.ts             # Subdomain utilities
│   └── constants.ts             # Subdomain constants
├── app/
│   ├── (vendor)/                # Vendor subdomain layout
│   ├── (admin)/                 # Admin subdomain layout
│   └── (www)/                   # Main domain layout
└── next.config.js               # Next.js configuration
```

## 🔧 1. middleware.ts

```typescript
import { NextResponse, NextRequest } from 'next/server';
import { getSubdomain, isValidSubdomain, RESERVED_SUBDOMAINS } from './lib/subdomain';

export async function middleware(request: NextRequest) {
  const url = request.nextUrl.clone();
  const hostname = request.headers.get('host') || '';
  
  // Extract subdomain
  const subdomain = getSubdomain(hostname);
  
  console.log(`🌐 Middleware: ${hostname} -> subdomain: ${subdomain}`);

  // Handle subdomain routing
  if (subdomain && isValidSubdomain(subdomain)) {
    return handleSubdomainRouting(request, subdomain, url);
  }

  // Handle main domain
  return handleMainDomain(request, url);
}

async function handleSubdomainRouting(
  request: NextRequest,
  subdomain: string,
  url: URL
) {
  const response = NextResponse.next();
  
  // Add subdomain headers
  response.headers.set('X-Subdomain', subdomain);
  response.headers.set('X-Subdomain-Valid', 'true');

  // Handle specific subdomains
  switch (subdomain) {
    case 'admin':
      return handleAdminSubdomain(request, url);
    
    case 'api':
      return handleApiSubdomain(request, url);
    
    case 'vendor':
      return handleVendorSubdomain(request, url);
    
    default:
      return handleDynamicVendorSubdomain(request, subdomain, url);
  }
}

function handleAdminSubdomain(request: NextRequest, url: URL) {
  // Rewrite to admin layout
  url.pathname = `/admin${url.pathname}`;
  
  const response = NextResponse.rewrite(url);
  response.headers.set('X-Subdomain-Type', 'admin');
  return response;
}

function handleApiSubdomain(request: NextRequest, url: URL) {
  // Redirect API subdomain to backend
  const backendUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';
  return NextResponse.redirect(`${backendUrl}${url.pathname}${url.search}`);
}

function handleVendorSubdomain(request: NextRequest, url: URL) {
  // Rewrite to vendor layout
  url.pathname = `/vendor${url.pathname}`;
  
  const response = NextResponse.rewrite(url);
  response.headers.set('X-Subdomain-Type', 'vendor');
  return response;
}

async function handleDynamicVendorSubdomain(
  request: NextRequest,
  subdomain: string,
  url: URL
) {
  // Validate vendor exists via API
  const isValidVendor = await validateVendorSubdomain(subdomain);
  
  if (!isValidVendor) {
    // Redirect to main domain with error
    const mainDomain = getMainDomain(request.headers.get('host') || '');
    return NextResponse.redirect(`${request.nextUrl.protocol}//${mainDomain}/vendor-not-found`);
  }
  
  // Rewrite to vendor store with vendor parameter
  url.pathname = `/store/${subdomain}${url.pathname}`;
  url.searchParams.set('vendor', subdomain);
  
  const response = NextResponse.rewrite(url);
  response.headers.set('X-Subdomain-Type', 'vendor-store');
  response.headers.set('X-Vendor', subdomain);
  
  return response;
}

function handleMainDomain(request: NextRequest, url: URL) {
  const response = NextResponse.next();
  response.headers.set('X-Subdomain', '');
  response.headers.set('X-Subdomain-Valid', 'false');
  response.headers.set('X-Subdomain-Type', 'main');
  
  return response;
}

async function validateVendorSubdomain(subdomain: string): Promise<boolean> {
  try {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';
    const response = await fetch(`${apiUrl}/api/subdomain/validate/${subdomain}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    });
    
    const data = await response.json();
    return data.success && data.valid;
  } catch (error) {
    console.error('Error validating vendor subdomain:', error);
    return false;
  }
}

function getMainDomain(hostname: string): string {
  if (hostname.includes('localhost')) {
    return 'localhost:3000';
  }
  
  // Remove subdomain from hostname
  const parts = hostname.split('.');
  if (parts.length > 2) {
    return parts.slice(1).join('.');
  }
  
  return hostname;
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public assets
     */
    '/((?!api|_next/static|_next/image|favicon.ico|public).*)',
  ],
};
```

## 🔧 2. lib/subdomain.ts

```typescript
export const RESERVED_SUBDOMAINS = [
  'www', 'api', 'admin', 'mail', 'ftp', 'test', 'dev', 'staging', 
  'prod', 'support', 'help', 'docs', 'blog', 'store', 'shop', 
  'app', 'mobile', 'cdn', 'assets', 'static', 'images', 'files'
];

export function getSubdomain(hostname: string): string | null {
  if (!hostname) return null;
  
  // Handle localhost development
  if (hostname.includes('localhost') || hostname.includes('127.0.0.1')) {
    return getDevSubdomain(hostname);
  }
  
  // Handle production domains
  return getProdSubdomain(hostname);
}

function getDevSubdomain(hostname: string): string | null {
  // Support formats like:
  // - vendor.localhost:3000
  // - admin.localhost:3000
  if (hostname.includes('.localhost')) {
    const parts = hostname.split('.');
    if (parts.length >= 2 && parts[0] !== 'www') {
      return parts[0].toLowerCase();
    }
  }
  
  return null;
}

function getProdSubdomain(hostname: string): string | null {
  const parts = hostname.split('.');
  
  // Need at least subdomain.domain.tld (3 parts)
  if (parts.length >= 3) {
    const subdomain = parts[0].toLowerCase();
    
    // Skip www
    if (subdomain !== 'www') {
      return subdomain;
    }
  }
  
  return null;
}

export function isValidSubdomain(subdomain: string): boolean {
  if (!subdomain) return false;
  
  // Check pattern: alphanumeric and hyphens, 1-63 chars
  const pattern = /^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$/;
  return pattern.test(subdomain.toLowerCase());
}

export function isReservedSubdomain(subdomain: string): boolean {
  return RESERVED_SUBDOMAINS.includes(subdomain.toLowerCase());
}

export function getSubdomainType(subdomain: string): 'admin' | 'vendor' | 'api' | 'dynamic' {
  switch (subdomain) {
    case 'admin':
      return 'admin';
    case 'vendor':
      return 'vendor';
    case 'api':
      return 'api';
    default:
      return 'dynamic';
  }
}

export async function validateVendorExists(vendorSlug: string): Promise<boolean> {
  try {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';
    const response = await fetch(`${apiUrl}/api/vendors/validate/${vendorSlug}`);
    const data = await response.json();
    return data.success && data.exists;
  } catch {
    return false;
  }
}
```

## 🔧 3. next.config.js

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  async rewrites() {
    return [
      // API proxy to backend
      {
        source: '/api/:path*',
        destination: `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080'}/api/:path*`,
      },
    ];
  },
  
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin',
          },
        ],
      },
    ];
  },

  // Enable experimental features for subdomain support
  experimental: {
    middleware: true,
  },

  // Environment variables
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
    NEXT_PUBLIC_BASE_DOMAIN: process.env.NEXT_PUBLIC_BASE_DOMAIN,
  },
};

module.exports = nextConfig;
```

## 🔧 4. Environment Variables (.env.local)

```bash
# Backend API URL
NEXT_PUBLIC_API_URL=http://localhost:8080

# Domain configuration
NEXT_PUBLIC_BASE_DOMAIN=example.com
NEXT_PUBLIC_DEV_DOMAIN=localhost:3000

# Subdomain settings
NEXT_PUBLIC_SUBDOMAIN_ENABLED=true
```

## 🏗️ 5. App Router Structure

### app/(vendor)/layout.tsx
```typescript
import { headers } from 'next/headers';
import VendorLayout from '@/components/layouts/VendorLayout';

export default function VendorSubdomainLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const headersList = headers();
  const subdomain = headersList.get('x-subdomain') || '';
  const vendor = headersList.get('x-vendor') || subdomain;

  return (
    <VendorLayout vendor={vendor}>
      {children}
    </VendorLayout>
  );
}
```

### app/(admin)/layout.tsx
```typescript
import AdminLayout from '@/components/layouts/AdminLayout';

export default function AdminSubdomainLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <AdminLayout>
      {children}
    </AdminLayout>
  );
}
```

## 🧪 6. Testing the Implementation

### Test URLs (Development)
```bash
# Main domain
http://localhost:3000

# Admin subdomain  
http://admin.localhost:3000

# Vendor portal
http://vendor.localhost:3000

# Dynamic vendor store
http://acme-corp.localhost:3000
http://tech-solutions.localhost:3000
```

### Test API Endpoints
```bash
# Test subdomain info
curl http://admin.localhost:3000/api/subdomain/info

# Validate subdomain
curl http://localhost:8080/api/subdomain/validate/acme-corp

# Get subdomain config
curl http://localhost:8080/api/subdomain/config
```

## 🚀 7. Production Deployment

### DNS Configuration
```bash
# A Records
www.example.com     → YOUR_SERVER_IP
*.example.com       → YOUR_SERVER_IP

# Or individual subdomains
admin.example.com   → YOUR_SERVER_IP
api.example.com     → YOUR_SERVER_IP
vendor.example.com  → YOUR_SERVER_IP
```

### Environment Variables (Production)
```bash
NEXT_PUBLIC_API_URL=https://api.example.com
NEXT_PUBLIC_BASE_DOMAIN=example.com
SUBDOMAIN_ENABLED=true
BASE_DOMAIN=example.com
```

## 🔍 8. Debugging & Monitoring

### Middleware Logging
```typescript
// Add to middleware.ts
console.log(`🌐 [${new Date().toISOString()}] ${hostname} -> ${subdomain}`);
```

### Backend Monitoring
Check the backend logs for subdomain processing:
```bash
tail -f logs/application.log | grep "Subdomain"
```

## ⚠️ Important Notes

1. **Development Setup**: Use `.localhost` for development subdomains
2. **CORS Configuration**: Backend automatically handles subdomain CORS
3. **SSL Certificates**: Use wildcard SSL certificates for production (*.example.com)
4. **Caching**: Be careful with CDN caching for different subdomains
5. **SEO**: Each subdomain is treated as a separate domain by search engines

## 🔧 Troubleshooting

### Common Issues
1. **Subdomain not resolving**: Check DNS configuration
2. **CORS errors**: Verify backend CORS configuration
3. **Middleware not running**: Check middleware matcher configuration
4. **Infinite redirects**: Verify subdomain validation logic

This implementation provides a complete subdomain routing solution that integrates seamlessly with your Spring Boot backend! 🎉
