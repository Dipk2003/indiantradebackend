-- Migration script for Base System Tables
-- Version: V001
-- Description: Create fundamental tables required by other modules

-- ===============================
-- USERS TABLE (Base authentication)
-- ===============================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    
    -- Status and Verification
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    account_status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING_VERIFICATION') DEFAULT 'PENDING_VERIFICATION',
    
    -- Profile
    profile_picture_url VARCHAR(500),
    date_of_birth DATE,
    gender ENUM('MALE', 'FEMALE', 'OTHER'),
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL,
    
    -- Indexes
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_phone (phone),
    INDEX idx_status (account_status),
    INDEX idx_created_at (created_at)
);

-- ===============================
-- USER ROLES TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS user_roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    role ENUM('ADMIN', 'BUYER', 'VENDOR', 'SUPPORT', 'DIRECTORY_PROVIDER') NOT NULL,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by VARCHAR(100),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_role (role),
    UNIQUE KEY uk_user_role (user_id, role)
);

-- ===============================
-- COMPANIES TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS companies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(255) NOT NULL,
    company_type ENUM('PRIVATE_LIMITED', 'PUBLIC_LIMITED', 'PARTNERSHIP', 'PROPRIETORSHIP', 'LLP') NOT NULL,
    
    -- Registration Details
    registration_number VARCHAR(100),
    gst_number VARCHAR(20),
    pan_number VARCHAR(20),
    
    -- Contact Information
    email VARCHAR(255),
    phone VARCHAR(20),
    website VARCHAR(500),
    
    -- Address
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'India',
    
    -- Business Details
    industry VARCHAR(100),
    description TEXT,
    established_year INT,
    employee_count INT,
    annual_turnover DECIMAL(15,2),
    
    -- Status
    status ENUM('ACTIVE', 'INACTIVE', 'PENDING', 'SUSPENDED') DEFAULT 'PENDING',
    verified BOOLEAN DEFAULT FALSE,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_company_name (company_name),
    INDEX idx_gst_number (gst_number),
    INDEX idx_city_state (city, state),
    INDEX idx_status (status),
    INDEX idx_verified (verified)
);

-- ===============================
-- VENDORS TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS vendors (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    company_id BIGINT,
    
    -- Basic Information
    business_name VARCHAR(255) NOT NULL,
    business_type ENUM('MANUFACTURER', 'DISTRIBUTOR', 'WHOLESALER', 'RETAILER', 'SERVICE_PROVIDER') NOT NULL,
    
    -- Contact Information
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(500),
    
    -- Address
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'India',
    
    -- Business Details
    description TEXT,
    established_year INT,
    annual_turnover DECIMAL(15,2),
    employee_count INT,
    
    -- Verification Status
    verification_status ENUM('PENDING', 'VERIFIED', 'REJECTED', 'SUSPENDED') DEFAULT 'PENDING',
    kyc_verified BOOLEAN DEFAULT FALSE,
    
    -- Registration Numbers
    gst_number VARCHAR(20),
    pan_number VARCHAR(20),
    trade_license VARCHAR(100),
    
    -- Rating and Reviews
    rating DECIMAL(3,2) DEFAULT 0.00,
    review_count INT DEFAULT 0,
    
    -- Subscription and Package
    subscription_status ENUM('ACTIVE', 'INACTIVE', 'EXPIRED', 'SUSPENDED') DEFAULT 'INACTIVE',
    subscription_start_date TIMESTAMP NULL,
    subscription_end_date TIMESTAMP NULL,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_company_id (company_id),
    INDEX idx_business_name (business_name),
    INDEX idx_city_state (city, state),
    INDEX idx_verification_status (verification_status),
    INDEX idx_subscription_status (subscription_status),
    INDEX idx_rating (rating),
    UNIQUE KEY uk_vendor_user (user_id)
);

-- ===============================
-- BUYERS TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS buyers (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    company_id BIGINT,
    
    -- Basic Information
    buyer_type ENUM('INDIVIDUAL', 'BUSINESS', 'GOVERNMENT', 'NGO') NOT NULL DEFAULT 'INDIVIDUAL',
    
    -- Contact Information
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255),
    
    -- Address
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'India',
    
    -- Business Details (for business buyers)
    business_name VARCHAR(255),
    gst_number VARCHAR(20),
    pan_number VARCHAR(20),
    
    -- Credit Information
    credit_limit DECIMAL(15,2) DEFAULT 0.00,
    credit_used DECIMAL(15,2) DEFAULT 0.00,
    credit_score INT,
    
    -- Preferences
    preferred_payment_method ENUM('CASH', 'CARD', 'BANK_TRANSFER', 'CREDIT', 'UPI'),
    preferred_delivery_method ENUM('STANDARD', 'EXPRESS', 'OVERNIGHT', 'PICKUP'),
    
    -- Status
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING') DEFAULT 'ACTIVE',
    kyc_verified BOOLEAN DEFAULT FALSE,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_company_id (company_id),
    INDEX idx_buyer_type (buyer_type),
    INDEX idx_city_state (city, state),
    INDEX idx_status (status),
    INDEX idx_kyc_verified (kyc_verified),
    UNIQUE KEY uk_buyer_user (user_id)
);

-- ===============================
-- PRODUCT CATEGORIES TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS product_categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    parent_id BIGINT NULL,
    
    -- SEO
    meta_title VARCHAR(255),
    meta_description TEXT,
    keywords TEXT,
    
    -- Display
    image_url VARCHAR(500),
    icon VARCHAR(100),
    color VARCHAR(20),
    sort_order INT DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (parent_id) REFERENCES product_categories(id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_parent_id (parent_id),
    INDEX idx_slug (slug),
    INDEX idx_active (is_active),
    INDEX idx_featured (is_featured),
    INDEX idx_sort_order (sort_order)
);

-- ===============================
-- PRODUCTS TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    vendor_id BIGINT NOT NULL,
    category_id BIGINT,
    
    -- Basic Information
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    sku VARCHAR(100) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    
    -- Categorization
    brand VARCHAR(100),
    model VARCHAR(100),
    
    -- Pricing
    base_price DECIMAL(15,2) NOT NULL,
    sale_price DECIMAL(15,2),
    cost_price DECIMAL(15,2),
    currency VARCHAR(3) DEFAULT 'INR',
    
    -- Physical Attributes
    weight DECIMAL(10,3),
    length DECIMAL(10,2),
    width DECIMAL(10,2),
    height DECIMAL(10,2),
    
    -- Inventory
    stock_quantity INT DEFAULT 0,
    min_order_quantity INT DEFAULT 1,
    max_order_quantity INT,
    
    -- Status
    status ENUM('DRAFT', 'ACTIVE', 'INACTIVE', 'OUT_OF_STOCK', 'DISCONTINUED') DEFAULT 'DRAFT',
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- SEO
    meta_title VARCHAR(255),
    meta_description TEXT,
    keywords TEXT,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES product_categories(id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_vendor_id (vendor_id),
    INDEX idx_category_id (category_id),
    INDEX idx_sku (sku),
    INDEX idx_slug (slug),
    INDEX idx_brand (brand),
    INDEX idx_status (status),
    INDEX idx_featured (is_featured),
    INDEX idx_price (base_price),
    UNIQUE KEY uk_vendor_sku (vendor_id, sku)
);

-- ===============================
-- USER ADDRESSES TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS user_addresses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    
    -- Address Details
    type ENUM('HOME', 'WORK', 'BILLING', 'SHIPPING', 'OTHER') NOT NULL DEFAULT 'HOME',
    name VARCHAR(100),
    phone VARCHAR(20),
    
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) DEFAULT 'India',
    
    -- Location
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    
    -- Flags
    is_default BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_city_state (city, state),
    INDEX idx_default (is_default),
    INDEX idx_verified (is_verified)
);

-- ===============================
-- TRANSACTIONS TABLE (Basic structure for payments)
-- ===============================
CREATE TABLE IF NOT EXISTS transactions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    transaction_id VARCHAR(100) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    
    -- Transaction Details
    type ENUM('PAYMENT', 'REFUND', 'CREDIT', 'DEBIT', 'TRANSFER') NOT NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED', 'CANCELLED', 'REFUNDED') DEFAULT 'PENDING',
    
    -- Amounts
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    
    -- Payment Method
    payment_method ENUM('CARD', 'UPI', 'NET_BANKING', 'WALLET', 'BANK_TRANSFER', 'CASH') NOT NULL,
    payment_gateway VARCHAR(50),
    gateway_transaction_id VARCHAR(255),
    gateway_response TEXT,
    
    -- References
    reference_type ENUM('ORDER', 'SUBSCRIPTION', 'WALLET', 'OTHER'),
    reference_id BIGINT,
    
    -- Description
    description VARCHAR(500),
    notes TEXT,
    
    -- Dates
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_reference (reference_type, reference_id),
    INDEX idx_processed_at (processed_at)
);
