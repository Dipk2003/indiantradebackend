-- Migration script to create essential base tables
-- Version: V1
-- Description: Create all fundamental tables required by the application

-- ===============================
-- USER TABLE (Core authentication)
-- ===============================
CREATE TABLE IF NOT EXISTS `user` (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    
    -- Basic Information
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    
    -- Address Information
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(20),
    country VARCHAR(100) DEFAULT 'India',
    
    -- Status and Verification
    verified BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    role VARCHAR(50) DEFAULT 'ROLE_USER',
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_role (role),
    INDEX idx_active (is_active),
    INDEX idx_verified (verified),
    INDEX idx_created_at (created_at)
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
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE,
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
    
    -- Verification Status
    verification_status ENUM('PENDING', 'VERIFIED', 'REJECTED') DEFAULT 'PENDING',
    kyc_verified BOOLEAN DEFAULT FALSE,
    
    -- Preferences
    preferred_categories TEXT,
    buying_frequency ENUM('DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'ANNUALLY') DEFAULT 'MONTHLY',
    
    -- Credit Information
    credit_limit DECIMAL(15,2),
    payment_terms VARCHAR(100),
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_company_id (company_id),
    INDEX idx_buyer_type (buyer_type),
    INDEX idx_city_state (city, state),
    INDEX idx_verification_status (verification_status),
    UNIQUE KEY uk_buyer_user (user_id)
);

-- ===============================
-- PRODUCTS TABLE (Basic structure)
-- ===============================
CREATE TABLE IF NOT EXISTS products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    vendor_id BIGINT NOT NULL,
    
    -- Basic Information
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) UNIQUE,
    description TEXT,
    brand VARCHAR(100),
    category VARCHAR(100),
    
    -- Pricing
    base_price DECIMAL(15,2) NOT NULL,
    selling_price DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    
    -- Inventory
    stock_quantity INT DEFAULT 0,
    min_order_quantity INT DEFAULT 1,
    max_order_quantity INT,
    
    -- Status
    status ENUM('ACTIVE', 'INACTIVE', 'OUT_OF_STOCK', 'DISCONTINUED') DEFAULT 'ACTIVE',
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- SEO
    slug VARCHAR(255) UNIQUE,
    meta_title VARCHAR(255),
    meta_description TEXT,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_vendor_id (vendor_id),
    INDEX idx_name (name),
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_featured (is_featured),
    INDEX idx_slug (slug),
    INDEX idx_price (selling_price)
);
