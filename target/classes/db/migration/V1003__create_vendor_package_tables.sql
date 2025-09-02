-- Migration script for vendor package system
-- Version: V1003
-- Description: Create tables for vendor package management system

-- Create vendor_packages table
CREATE TABLE IF NOT EXISTS vendor_packages (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    display_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    discounted_price DECIMAL(10,2),
    duration_days INT NOT NULL,
    duration_type ENUM('MONTHLY', 'YEARLY', 'LIFETIME') DEFAULT 'MONTHLY',
    plan_type ENUM('BASIC', 'SILVER', 'GOLD', 'PLATINUM', 'DIAMOND') NOT NULL,
    badge VARCHAR(50),
    color VARCHAR(20),
    icon VARCHAR(100),
    
    -- Core Features
    max_products INT,
    max_leads INT,
    max_orders INT,
    max_quotations INT,
    max_product_images INT,
    
    -- Premium Features
    featured_listing BOOLEAN DEFAULT FALSE,
    priority_support BOOLEAN DEFAULT FALSE,
    analytics_access BOOLEAN DEFAULT FALSE,
    chatbot_priority BOOLEAN DEFAULT FALSE,
    custom_branding BOOLEAN DEFAULT FALSE,
    bulk_import_export BOOLEAN DEFAULT FALSE,
    api_access BOOLEAN DEFAULT FALSE,
    multi_location_support BOOLEAN DEFAULT FALSE,
    inventory_management BOOLEAN DEFAULT FALSE,
    customer_insights BOOLEAN DEFAULT FALSE,
    marketplace_integration BOOLEAN DEFAULT FALSE,
    social_media_integration BOOLEAN DEFAULT FALSE,
    
    -- Business Features
    gst_compliance BOOLEAN DEFAULT FALSE,
    invoice_generation BOOLEAN DEFAULT FALSE,
    payment_gateway BOOLEAN DEFAULT FALSE,
    shipping_integration BOOLEAN DEFAULT FALSE,
    return_management BOOLEAN DEFAULT FALSE,
    loyalty_program BOOLEAN DEFAULT FALSE,
    
    -- Technical Features
    search_ranking INT,
    storage_limit INT COMMENT 'Storage limit in GB',
    bandwidth_limit INT COMMENT 'Bandwidth limit in GB',
    api_call_limit INT COMMENT 'API calls per month',
    
    -- Pricing & Offers
    setup_fee DECIMAL(10,2) DEFAULT 0.00,
    monthly_price DECIMAL(10,2),
    yearly_price DECIMAL(10,2),
    trial_days INT DEFAULT 0,
    offer_text VARCHAR(255),
    
    -- Status & Management
    is_active BOOLEAN DEFAULT TRUE,
    is_popular BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_plan_type (plan_type),
    INDEX idx_active (is_active),
    INDEX idx_popular (is_popular),
    INDEX idx_sort_order (sort_order)
);

-- Create vendor_package_features table
CREATE TABLE IF NOT EXISTS vendor_package_features (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    vendor_package_id BIGINT NOT NULL,
    feature_name VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    feature_type ENUM('CORE', 'PREMIUM', 'BUSINESS', 'TECHNICAL', 'SUPPORT', 'LIMIT', 'BENEFIT') NOT NULL,
    value VARCHAR(100) COMMENT 'For features with specific values',
    is_included BOOLEAN DEFAULT TRUE,
    is_highlighted BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vendor_package_id) REFERENCES vendor_packages(id) ON DELETE CASCADE,
    INDEX idx_vendor_package (vendor_package_id),
    INDEX idx_feature_type (feature_type),
    INDEX idx_display_order (display_order),
    INDEX idx_included (is_included),
    INDEX idx_highlighted (is_highlighted)
);

-- Create vendor_package_transactions table
CREATE TABLE IF NOT EXISTS vendor_package_transactions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    transaction_id VARCHAR(100) NOT NULL UNIQUE,
    vendor_id BIGINT NOT NULL,
    vendor_package_id BIGINT NOT NULL,
    
    -- Pricing
    amount DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    
    -- Payment Details
    payment_method ENUM('RAZORPAY', 'UPI', 'NET_BANKING', 'DEBIT_CARD', 'CREDIT_CARD', 'BANK_TRANSFER', 'WALLET', 'EMI') NOT NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED', 'CANCELLED', 'REFUNDED', 'PARTIALLY_REFUNDED') DEFAULT 'PENDING',
    payment_gateway_transaction_id VARCHAR(255),
    payment_gateway_response TEXT,
    
    -- Additional Details
    coupon_code VARCHAR(50),
    billing_address TEXT,
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_pincode VARCHAR(10),
    gst_number VARCHAR(20),
    invoice_number VARCHAR(100),
    receipt_url VARCHAR(500),
    
    -- Installment Details
    installment_count INT,
    installment_amount DECIMAL(10,2),
    current_installment INT DEFAULT 1,
    
    notes TEXT,
    payment_date TIMESTAMP NULL,
    expiry_date TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
    FOREIGN KEY (vendor_package_id) REFERENCES vendor_packages(id) ON DELETE RESTRICT,
    
    INDEX idx_vendor (vendor_id),
    INDEX idx_vendor_package (vendor_package_id),
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_status (status),
    INDEX idx_payment_method (payment_method),
    INDEX idx_payment_date (payment_date),
    INDEX idx_created_at (created_at)
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_vendor_packages_plan_active ON vendor_packages(plan_type, is_active);
CREATE INDEX IF NOT EXISTS idx_vendor_packages_popular_active ON vendor_packages(is_popular, is_active, sort_order);
CREATE INDEX IF NOT EXISTS idx_transactions_vendor_status ON vendor_package_transactions(vendor_id, status, created_at);
CREATE INDEX IF NOT EXISTS idx_transactions_package_status ON vendor_package_transactions(vendor_package_id, status, created_at);

-- Insert a comment for migration tracking
INSERT IGNORE INTO flyway_schema_history_comments (version, description, created_at) 
VALUES ('1003', 'Create vendor package management system tables with features and transactions', NOW())
ON DUPLICATE KEY UPDATE description = VALUES(description);
