
# Itech-Backend API Documentation

## Overview

This document provides a comprehensive overview of the API endpoints for the Itech-Backend B2B platform. The base URL for all API endpoints is `http://localhost:8080`.

---

## Authentication (`/auth`)

Handles user, vendor, and admin registration and login.

- **`POST /auth/register`**: Register a new user.
- **`POST /auth/vendor/register`**: Register a new vendor.
- **`POST /auth/admin/register`**: Register a new admin.
- **`POST /auth/login`**: Generic login for any user type.
- **`POST /auth/user/login`**: User-specific login.
- **`POST /auth/vendor/login`**: Vendor-specific login.
- **`POST /auth/admin/login`**: Admin-specific login.
- **`POST /auth/verify`**: Verify a user's OTP to complete registration.
- **`POST /auth/forgot-password`**: Initiate the password reset process.
- **`POST /auth/verify-forgot-password-otp`**: Verify the OTP for password reset.
- **`POST /auth/check-email-role`**: Check the role associated with an email.

---

## Products (`/api/products`)

Endpoints for managing and searching products.

- **`GET /api/products`**: Get a paginated list of all products.
- **`GET /api/products/{productId}`**: Get details of a single product.
- **`GET /api/products/search`**: Basic product search.
- **`GET /api/products/advanced-search-products`**: Advanced product search with filters.
- **`GET /api/products/search/featured`**: Get a list of featured products.
- **`GET /api/products/search/category/{categoryId}`**: Get products by category.
- **`GET /api/products/search/vendor/{vendorId}`**: Get products by vendor.
- **`GET /api/products/suggestions`**: Get search suggestions for a query.

---

## Cart (`/api/cart`)

Manages the user's shopping cart. Requires `USER` role.

- **`GET /api/cart`**: Get the current user's cart.
- **`POST /api/cart/add`**: Add a product to the cart.
- **`PUT /api/cart/item/{cartItemId}`**: Update an item's quantity in the cart.
- **`DELETE /api/cart/item/{cartItemId}`**: Remove an item from the cart.
- **`DELETE /api/cart/clear`**: Clear the entire cart.

---

## Wishlist (`/api/wishlist`)

Manages the user's wishlist. Requires `USER` role.

- **`POST /api/wishlist/add/{productId}`**: Add a product to the wishlist.
- **`GET /api/wishlist/my-wishlist`**: Get the current user's wishlist.
- **`DELETE /api/wishlist/remove/{productId}`**: Remove a product from the wishlist.

---

## Orders (`/api/orders`)

Endpoints for order management.

- **`POST /api/orders/create`**: Create an order from the cart. Requires `USER` role.
- **`GET /api/orders/my-orders`**: Get the current user's orders. Requires `USER` role.
- **`GET /api/orders/{orderId}`**: Get details of a specific order. Requires `USER` or `ADMIN` role.
- **`PUT /api/orders/{orderId}/status`**: Update the status of an order. Requires `ADMIN` role.

---

## User Management (`/api/users`)

Admin endpoints for managing users.

- **`GET /api/users`**: Get a list of all users. Requires `ADMIN` role.
- **`GET /api/users/{id}`**: Get a user by ID.
- **`PUT /api/users/{id}`**: Update a user's details.
- **`DELETE /api/users/{id}`**: Delete a user. Requires `ADMIN` role.

---

## Vendor Management (`/api/vendors`)

Admin endpoints for managing vendors.

- **`GET /api/vendors`**: Get a list of all vendors. Requires `ADMIN` role.
- **`GET /api/vendors/{id}`**: Get a vendor by ID.
- **`PUT /api/vendors/{id}`**: Update a vendor's details.
- **`DELETE /api/vendors/{id}`**: Delete a vendor.

---

## Category Management (`/api/admin/categories`)

Admin endpoints for managing categories.

- **`GET /api/admin/categories`**: Get all categories.
- **`POST /api/admin/categories`**: Create a new category.
- **`PUT /api/admin/categories/{categoryId}`**: Update a category.
- **`DELETE /api/admin/categories/{categoryId}`**: Delete a category.
- **`GET /api/admin/categories/{categoryId}/subcategories`**: Get sub-categories for a category.
- **`POST /api/admin/categories/{categoryId}/subcategories`**: Create a new sub-category.
- **`GET /api/admin/categories/tree`**: Get the full category tree.

---

## Data Entry (`/api/dataentry`)

Endpoints for data entry personnel.

- **`GET /api/dataentry/categories`**: Get all categories for data entry.
- **`POST /api/dataentry/categories`**: Create a new category.
- **`GET /api/dataentry/products`**: Get all products for data entry.
- **`POST /api/dataentry/products`**: Create a new product.
- **`POST /api/dataentry/categories/bulk-import`**: Bulk import categories from a file.

