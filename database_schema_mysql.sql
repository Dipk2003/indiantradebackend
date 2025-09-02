-- =============================================================================
-- iTech Backend - MySQL Database Schema for Local Development
-- =============================================================================
-- Run this script in MySQL Workbench to create the database schema locally
-- This is adapted from the PostgreSQL version for local MySQL development

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS itech_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE itech_db;

-- =============================================================================
-- CORE ENTITIES
-- =============================================================================

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20) UNIQUE,
    role VARCHAR(50) DEFAULT 'USER',
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    profile_image_url TEXT,
    last_login TIMESTAMP NULL,
    login_count BIGINT DEFAULT 0,
    password_reset_token VARCHAR(255),
    password_reset_token_expiry TIMESTAMP NULL,
    email_verification_token VARCHAR(255),
    email_verification_token_expiry TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Companies table
CREATE TABLE IF NOT EXISTS companies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(200) NOT NULL,
    company_type VARCHAR(50),
    registration_number VARCHAR(100) UNIQUE,
    gst_number VARCHAR(50) UNIQUE,
    pan_number VARCHAR(20) UNIQUE,
    tan_number VARCHAR(20),
    industry VARCHAR(100),
    business_type VARCHAR(50),
    company_size VARCHAR(50),
    established_year INT,
    annual_revenue DECIMAL(15,2),
    employee_count INT,
    website_url TEXT,
    logo_url TEXT,
    description TEXT,
    address_line1 TEXT,
    address_line2 TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'India',
    primary_phone VARCHAR(20),
    secondary_phone VARCHAR(20),
    primary_email VARCHAR(100),
    secondary_email VARCHAR(100),
    linkedin_url TEXT,
    facebook_url TEXT,
    twitter_url TEXT,
    instagram_url TEXT,
    contact_person_name VARCHAR(100),
    contact_person_email VARCHAR(100),
    contact_person_phone VARCHAR(20),
    contact_person_designation VARCHAR(100),
    verification_status VARCHAR(50) DEFAULT 'PENDING',
    is_verified BOOLEAN DEFAULT FALSE,
    verification_date TIMESTAMP NULL,
    verification_documents JSON,
    kyc_status VARCHAR(50) DEFAULT 'NOT_SUBMITTED',
    kyc_data TEXT,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- =============================================================================
-- BUYER MODULE
-- =============================================================================

-- Buyers table (Main table that was missing)
CREATE TABLE IF NOT EXISTS buyers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT,
    buyer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password VARCHAR(255) NOT NULL,
    buyer_type VARCHAR(50) DEFAULT 'INDIVIDUAL',
    buyer_status VARCHAR(50) DEFAULT 'ACTIVE',
    is_verified BOOLEAN DEFAULT FALSE,
    is_premium BOOLEAN DEFAULT FALSE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    display_name VARCHAR(150),
    job_title VARCHAR(100),
    department VARCHAR(100),
    bio TEXT,
    profile_image_url TEXT,
    secondary_email VARCHAR(100),
    secondary_phone VARCHAR(20),
    linkedin_url TEXT,
    website_url TEXT,
    billing_address_line1 TEXT,
    billing_address_line2 TEXT,
    billing_city VARCHAR(50),
    billing_state VARCHAR(50),
    billing_postal_code VARCHAR(10),
    billing_country VARCHAR(50) DEFAULT 'India',
    shipping_address_line1 TEXT,
    shipping_address_line2 TEXT,
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(50),
    shipping_postal_code VARCHAR(10),
    shipping_country VARCHAR(50) DEFAULT 'India',
    same_as_billing BOOLEAN DEFAULT TRUE,
    business_type VARCHAR(50),
    company_size VARCHAR(50),
    annual_budget DECIMAL(15,2),
    purchasing_authority VARCHAR(50),
    credit_limit DECIMAL(15,2),
    payment_terms_preference INT,
    total_orders BIGINT DEFAULT 0,
    completed_orders BIGINT DEFAULT 0,
    cancelled_orders BIGINT DEFAULT 0,
    total_spent DECIMAL(15,2) DEFAULT 0,
    average_order_value DECIMAL(15,2) DEFAULT 0,
    last_order_date TIMESTAMP NULL,
    favorite_vendors TEXT,
    profile_views BIGINT DEFAULT 0,
    product_views BIGINT DEFAULT 0,
    inquiries_sent BIGINT DEFAULT 0,
    quotes_requested BIGINT DEFAULT 0,
    reviews_written INT DEFAULT 0,
    wishlist_items INT DEFAULT 0,
    email_notifications BOOLEAN DEFAULT TRUE,
    sms_notifications BOOLEAN DEFAULT FALSE,
    marketing_emails BOOLEAN DEFAULT TRUE,
    price_alerts BOOLEAN DEFAULT TRUE,
    new_product_alerts BOOLEAN DEFAULT FALSE,
    order_updates BOOLEAN DEFAULT TRUE,
    verification_status VARCHAR(50) DEFAULT 'PENDING',
    kyc_status VARCHAR(50) DEFAULT 'NOT_SUBMITTED',
    kyc_submitted BOOLEAN DEFAULT FALSE,
    kyc_approved BOOLEAN DEFAULT FALSE,
    kyc_submitted_at TIMESTAMP NULL,
    kyc_approved_at TIMESTAMP NULL,
    kyc_approved_by VARCHAR(100),
    kyc_rejection_reason TEXT,
    subscription_type VARCHAR(50) DEFAULT 'FREE',
    subscription_start_date TIMESTAMP NULL,
    subscription_end_date TIMESTAMP NULL,
    last_login TIMESTAMP NULL,
    last_activity TIMESTAMP NULL,
    login_count BIGINT DEFAULT 0,
    session_duration_minutes BIGINT DEFAULT 0,
    profile_visibility VARCHAR(50) DEFAULT 'PUBLIC',
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    password_hash VARCHAR(255),
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_phone_verified BOOLEAN DEFAULT FALSE,
    is_kyc_verified BOOLEAN DEFAULT FALSE,
    last_login_date TIMESTAMP NULL,
    email_verification_token VARCHAR(255),
    email_verification_token_expiry TIMESTAMP NULL,
    email_verification_date TIMESTAMP NULL,
    phone_verification_otp VARCHAR(10),
    phone_verification_otp_expiry TIMESTAMP NULL,
    phone_verification_date TIMESTAMP NULL,
    kyc_data TEXT,
    kyc_attempts INT DEFAULT 0,
    kyc_verification_date TIMESTAMP NULL,
    suspension_end_date TIMESTAMP NULL,
    status_reason TEXT,
    subscription_expiry_date TIMESTAMP NULL,
    total_order_value DECIMAL(15,2) DEFAULT 0,
    company_name VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    
    -- Foreign Key
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL
);

-- Buyer related tables
CREATE TABLE IF NOT EXISTS buyer_industries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    buyer_id BIGINT NOT NULL,
    industry VARCHAR(50),
    FOREIGN KEY (buyer_id) REFERENCES buyers(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS buyer_preferred_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    buyer_id BIGINT NOT NULL,
    category VARCHAR(100),
    FOREIGN KEY (buyer_id) REFERENCES buyers(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS buyer_payment_methods (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    buyer_id BIGINT NOT NULL,
    payment_method VARCHAR(50),
    FOREIGN KEY (buyer_id) REFERENCES buyers(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS buyer_documents (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    buyer_id BIGINT NOT NULL,
    document_url TEXT,
    FOREIGN KEY (buyer_id) REFERENCES buyers(id) ON DELETE CASCADE
);

-- Categories
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    slug VARCHAR(100) UNIQUE,
    image_url TEXT,
    parent_id BIGINT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    meta_title VARCHAR(200),
    meta_description TEXT,
    meta_keywords TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS sub_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    slug VARCHAR(100) UNIQUE,
    image_url TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS micro_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sub_category_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    slug VARCHAR(100) UNIQUE,
    image_url TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sub_category_id) REFERENCES sub_categories(id) ON DELETE CASCADE
);

-- Products
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vendor_id BIGINT,
    category_id BIGINT,
    sub_category_id BIGINT,
    micro_category_id BIGINT,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    short_description TEXT,
    sku VARCHAR(100) UNIQUE,
    hsn_code VARCHAR(20),
    brand VARCHAR(100),
    model VARCHAR(100),
    weight DECIMAL(10,3),
    dimensions VARCHAR(100),
    color VARCHAR(50),
    material VARCHAR(100),
    warranty VARCHAR(100),
    price DECIMAL(12,2),
    mrp DECIMAL(12,2),
    discount_percentage DECIMAL(5,2),
    tax_rate DECIMAL(5,2),
    stock_quantity INT DEFAULT 0,
    min_order_quantity INT DEFAULT 1,
    max_order_quantity INT,
    unit VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    views_count BIGINT DEFAULT 0,
    likes_count INT DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INT DEFAULT 0,
    meta_title VARCHAR(200),
    meta_description TEXT,
    meta_keywords TEXT,
    slug VARCHAR(200) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (sub_category_id) REFERENCES sub_categories(id) ON DELETE SET NULL,
    FOREIGN KEY (micro_category_id) REFERENCES micro_categories(id) ON DELETE SET NULL
);

-- Vendors table
CREATE TABLE IF NOT EXISTS vendors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT,
    vendor_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password VARCHAR(255) NOT NULL,
    business_name VARCHAR(200),
    business_type VARCHAR(50),
    registration_number VARCHAR(100),
    gst_number VARCHAR(50),
    pan_number VARCHAR(20),
    business_address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'India',
    website_url TEXT,
    description TEXT,
    logo_url TEXT,
    established_year INT,
    employee_count INT,
    annual_turnover DECIMAL(15,2),
    specializations JSON,
    certifications JSON,
    awards JSON,
    vendor_type VARCHAR(50) DEFAULT 'SUPPLIER',
    vendor_status VARCHAR(50) DEFAULT 'ACTIVE',
    verification_status VARCHAR(50) DEFAULT 'PENDING',
    kyc_status VARCHAR(50) DEFAULT 'NOT_SUBMITTED',
    is_verified BOOLEAN DEFAULT FALSE,
    is_premium BOOLEAN DEFAULT FALSE,
    subscription_type VARCHAR(50) DEFAULT 'FREE',
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INT DEFAULT 0,
    total_products INT DEFAULT 0,
    total_orders BIGINT DEFAULT 0,
    completed_orders BIGINT DEFAULT 0,
    total_revenue DECIMAL(15,2) DEFAULT 0,
    response_time_hours INT DEFAULT 24,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL
);

-- Update products table to include vendor reference
ALTER TABLE products ADD FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE SET NULL;

-- =============================================================================
-- ESSENTIAL TABLES ONLY (FOR QUICK SETUP)
-- =============================================================================

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    buyer_id BIGINT,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    shipping_amount DECIMAL(12,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    final_amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR',
    status VARCHAR(50) DEFAULT 'PENDING',
    payment_status VARCHAR(50) DEFAULT 'PENDING',
    payment_method VARCHAR(50),
    payment_id VARCHAR(100),
    billing_address TEXT,
    shipping_address TEXT,
    notes TEXT,
    delivered_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    cancellation_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id) REFERENCES buyers(id) ON DELETE SET NULL
);

-- Admins table
CREATE TABLE IF NOT EXISTS admins (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    role VARCHAR(50) DEFAULT 'ADMIN',
    permissions JSON,
    is_active BOOLEAN DEFAULT TRUE,
    is_super_admin BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

-- Users indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);

-- Buyers indexes
CREATE INDEX idx_buyers_email ON buyers(email);
CREATE INDEX idx_buyers_phone ON buyers(phone);
CREATE INDEX idx_buyers_status ON buyers(buyer_status);
CREATE INDEX idx_buyers_verification ON buyers(verification_status);
CREATE INDEX idx_buyers_created_at ON buyers(created_at);

-- Products indexes
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_subcategory ON products(sub_category_id);
CREATE INDEX idx_products_vendor ON products(vendor_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_featured ON products(is_featured);
CREATE INDEX idx_products_price ON products(price);

-- Orders indexes
CREATE INDEX idx_orders_buyer ON orders(buyer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Vendors indexes
CREATE INDEX idx_vendors_email ON vendors(email);
CREATE INDEX idx_vendors_status ON vendors(vendor_status);
CREATE INDEX idx_vendors_verification ON vendors(verification_status);

-- Categories indexes
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_parent ON categories(parent_id);
CREATE INDEX idx_categories_active ON categories(is_active);

-- =============================================================================
-- INITIAL DATA
-- =============================================================================

-- Insert default admin user
INSERT IGNORE INTO admins (username, email, password, first_name, last_name, role, is_super_admin) 
VALUES ('admin', 'admin@indiantrademart.com', '$2a$10$eImiTXuWVxfm37uY4JANjOhSzm.tKN8OWn6r.8TaxQ.IIz.AoRGjS', 'System', 'Administrator', 'SUPER_ADMIN', true);

-- Insert default categories
INSERT IGNORE INTO categories (name, description, slug) VALUES
('Electronics', 'Electronic products and components', 'electronics'),
('Machinery', 'Industrial machinery and equipment', 'machinery'),
('Textiles', 'Textile products and fabrics', 'textiles'),
('Chemicals', 'Chemical products and raw materials', 'chemicals'),
('Food & Beverages', 'Food products and beverages', 'food-beverages'),
('Healthcare', 'Medical and healthcare products', 'healthcare'),
('Automotive', 'Automotive parts and accessories', 'automotive'),
('Construction', 'Construction materials and tools', 'construction');

-- =============================================================================
-- COMPLETION MESSAGE
-- =============================================================================

SELECT 'MySQL Database schema initialization completed successfully!' as message;
