-- iTech Backend - Complete Database Schema Initialization
-- This script creates all necessary tables for the itech-backend Spring Boot application
-- Run this script on your AWS PostgreSQL database

-- =============================================================================
-- CORE ENTITIES
-- =============================================================================

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
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
    last_login TIMESTAMP,
    login_count BIGINT DEFAULT 0,
    password_reset_token VARCHAR(255),
    password_reset_token_expiry TIMESTAMP,
    email_verification_token VARCHAR(255),
    email_verification_token_expiry TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Companies table
CREATE TABLE IF NOT EXISTS companies (
    id BIGSERIAL PRIMARY KEY,
    company_name VARCHAR(200) NOT NULL,
    company_type VARCHAR(50),
    registration_number VARCHAR(100) UNIQUE,
    gst_number VARCHAR(50) UNIQUE,
    pan_number VARCHAR(20) UNIQUE,
    tan_number VARCHAR(20),
    industry VARCHAR(100),
    business_type VARCHAR(50),
    company_size VARCHAR(50),
    established_year INTEGER,
    annual_revenue DECIMAL(15,2),
    employee_count INTEGER,
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
    verification_date TIMESTAMP,
    verification_documents TEXT[],
    kyc_status VARCHAR(50) DEFAULT 'NOT_SUBMITTED',
    kyc_data TEXT,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- =============================================================================
-- BUYER MODULE
-- =============================================================================

-- Buyers table (Main table causing the error)
CREATE TABLE IF NOT EXISTS buyers (
    id BIGSERIAL PRIMARY KEY,
    company_id BIGINT REFERENCES companies(id),
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
    payment_terms_preference INTEGER,
    total_orders BIGINT DEFAULT 0,
    completed_orders BIGINT DEFAULT 0,
    cancelled_orders BIGINT DEFAULT 0,
    total_spent DECIMAL(15,2) DEFAULT 0,
    average_order_value DECIMAL(15,2) DEFAULT 0,
    last_order_date TIMESTAMP,
    favorite_vendors TEXT,
    profile_views BIGINT DEFAULT 0,
    product_views BIGINT DEFAULT 0,
    inquiries_sent BIGINT DEFAULT 0,
    quotes_requested BIGINT DEFAULT 0,
    reviews_written INTEGER DEFAULT 0,
    wishlist_items INTEGER DEFAULT 0,
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
    kyc_submitted_at TIMESTAMP,
    kyc_approved_at TIMESTAMP,
    kyc_approved_by VARCHAR(100),
    kyc_rejection_reason TEXT,
    subscription_type VARCHAR(50) DEFAULT 'FREE',
    subscription_start_date TIMESTAMP,
    subscription_end_date TIMESTAMP,
    last_login TIMESTAMP,
    last_activity TIMESTAMP,
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
    last_login_date TIMESTAMP,
    email_verification_token VARCHAR(255),
    email_verification_token_expiry TIMESTAMP,
    email_verification_date TIMESTAMP,
    phone_verification_otp VARCHAR(10),
    phone_verification_otp_expiry TIMESTAMP,
    phone_verification_date TIMESTAMP,
    kyc_data TEXT,
    kyc_attempts INTEGER DEFAULT 0,
    kyc_verification_date TIMESTAMP,
    suspension_end_date TIMESTAMP,
    status_reason TEXT,
    subscription_expiry_date TIMESTAMP,
    total_order_value DECIMAL(15,2) DEFAULT 0,
    company_name VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Buyer related tables
CREATE TABLE IF NOT EXISTS buyer_industries (
    buyer_id BIGINT REFERENCES buyers(id) ON DELETE CASCADE,
    industry VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS buyer_preferred_categories (
    buyer_id BIGINT REFERENCES buyers(id) ON DELETE CASCADE,
    category VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS buyer_payment_methods (
    buyer_id BIGINT REFERENCES buyers(id) ON DELETE CASCADE,
    payment_method VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS buyer_documents (
    buyer_id BIGINT REFERENCES buyers(id) ON DELETE CASCADE,
    document_url TEXT
);

-- Categories
CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    slug VARCHAR(100) UNIQUE,
    image_url TEXT,
    parent_id BIGINT REFERENCES categories(id),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    meta_title VARCHAR(200),
    meta_description TEXT,
    meta_keywords TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sub_categories (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT REFERENCES categories(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    slug VARCHAR(100) UNIQUE,
    image_url TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS micro_categories (
    id BIGSERIAL PRIMARY KEY,
    sub_category_id BIGINT REFERENCES sub_categories(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    slug VARCHAR(100) UNIQUE,
    image_url TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT,
    category_id BIGINT REFERENCES categories(id),
    sub_category_id BIGINT REFERENCES sub_categories(id),
    micro_category_id BIGINT REFERENCES micro_categories(id),
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
    stock_quantity INTEGER DEFAULT 0,
    min_order_quantity INTEGER DEFAULT 1,
    max_order_quantity INTEGER,
    unit VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    views_count BIGINT DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    meta_title VARCHAR(200),
    meta_description TEXT,
    meta_keywords TEXT,
    slug VARCHAR(200) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product_images (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT REFERENCES products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    alt_text VARCHAR(200),
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS product_attributes (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT REFERENCES products(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    value TEXT,
    attribute_type VARCHAR(50) DEFAULT 'TEXT',
    is_filterable BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS product_attribute_values (
    id BIGSERIAL PRIMARY KEY,
    product_attribute_id BIGINT REFERENCES product_attributes(id) ON DELETE CASCADE,
    value TEXT NOT NULL,
    additional_price DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS product_variants (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT REFERENCES products(id) ON DELETE CASCADE,
    variant_name VARCHAR(100),
    sku VARCHAR(100) UNIQUE,
    price DECIMAL(12,2),
    stock_quantity INTEGER DEFAULT 0,
    attributes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cart
CREATE TABLE IF NOT EXISTS carts (
    id BIGSERIAL PRIMARY KEY,
    buyer_id BIGINT REFERENCES buyers(id) ON DELETE CASCADE,
    session_id VARCHAR(100),
    total_items INTEGER DEFAULT 0,
    total_amount DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cart_items (
    id BIGSERIAL PRIMARY KEY,
    cart_id BIGINT REFERENCES carts(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES products(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(12,2),
    total_price DECIMAL(12,2),
    selected_attributes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders
CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    buyer_id BIGINT REFERENCES buyers(id),
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
    delivered_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    product_name VARCHAR(200),
    product_sku VARCHAR(100),
    selected_attributes TEXT
);

-- Inquiries
CREATE TABLE IF NOT EXISTS inquiries (
    id BIGSERIAL PRIMARY KEY,
    buyer_id BIGINT REFERENCES buyers(id),
    product_id BIGINT REFERENCES products(id),
    subject VARCHAR(200),
    message TEXT NOT NULL,
    quantity INTEGER,
    expected_price DECIMAL(12,2),
    required_by_date DATE,
    status VARCHAR(50) DEFAULT 'OPEN',
    response TEXT,
    responded_at TIMESTAMP,
    responded_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Quotes
CREATE TABLE IF NOT EXISTS quotes (
    id BIGSERIAL PRIMARY KEY,
    buyer_id BIGINT REFERENCES buyers(id),
    vendor_id BIGINT,
    inquiry_id BIGINT REFERENCES inquiries(id),
    quote_number VARCHAR(50) UNIQUE,
    total_amount DECIMAL(12,2),
    valid_until DATE,
    status VARCHAR(50) DEFAULT 'DRAFT',
    terms_and_conditions TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Reviews
CREATE TABLE IF NOT EXISTS reviews (
    id BIGSERIAL PRIMARY KEY,
    buyer_id BIGINT REFERENCES buyers(id),
    product_id BIGINT REFERENCES products(id),
    order_id BIGINT REFERENCES orders(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    comment TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    helpful_count INTEGER DEFAULT 0,
    is_approved BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Wishlist
CREATE TABLE IF NOT EXISTS wishlists (
    id BIGSERIAL PRIMARY KEY,
    buyer_id BIGINT REFERENCES buyers(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(buyer_id, product_id)
);

-- =============================================================================
-- VENDOR MODULE
-- =============================================================================

CREATE TABLE IF NOT EXISTS vendors (
    id BIGSERIAL PRIMARY KEY,
    company_id BIGINT REFERENCES companies(id),
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
    established_year INTEGER,
    employee_count INTEGER,
    annual_turnover DECIMAL(15,2),
    specializations TEXT[],
    certifications TEXT[],
    awards TEXT[],
    vendor_type VARCHAR(50) DEFAULT 'SUPPLIER',
    vendor_status VARCHAR(50) DEFAULT 'ACTIVE',
    verification_status VARCHAR(50) DEFAULT 'PENDING',
    kyc_status VARCHAR(50) DEFAULT 'NOT_SUBMITTED',
    is_verified BOOLEAN DEFAULT FALSE,
    is_premium BOOLEAN DEFAULT FALSE,
    subscription_type VARCHAR(50) DEFAULT 'FREE',
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    total_products INTEGER DEFAULT 0,
    total_orders BIGINT DEFAULT 0,
    completed_orders BIGINT DEFAULT 0,
    total_revenue DECIMAL(15,2) DEFAULT 0,
    response_time_hours INTEGER DEFAULT 24,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS vendor_gst_selections (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES vendors(id) ON DELETE CASCADE,
    gst_rate DECIMAL(5,2) NOT NULL,
    category VARCHAR(100),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vendor_tds_selections (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES vendors(id) ON DELETE CASCADE,
    tds_rate DECIMAL(5,2) NOT NULL,
    section VARCHAR(50),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vendor_tax_profiles (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES vendors(id) ON DELETE CASCADE,
    tax_type VARCHAR(50) NOT NULL,
    tax_rate DECIMAL(5,2) NOT NULL,
    applicable_from DATE,
    applicable_to DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vendor_reviews (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES vendors(id),
    buyer_id BIGINT REFERENCES buyers(id),
    order_id BIGINT REFERENCES orders(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    comment TEXT,
    response TEXT,
    responded_at TIMESTAMP,
    is_approved BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vendor_rankings (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES vendors(id),
    category VARCHAR(100),
    rank_position INTEGER,
    score DECIMAL(5,2),
    period_start DATE,
    period_end DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- ADMIN MODULE
-- =============================================================================

CREATE TABLE IF NOT EXISTS admins (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    role VARCHAR(50) DEFAULT 'ADMIN',
    permissions TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    is_super_admin BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS leads (
    id BIGSERIAL PRIMARY KEY,
    lead_type VARCHAR(50) NOT NULL,
    source VARCHAR(100),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    company VARCHAR(200),
    designation VARCHAR(100),
    industry VARCHAR(100),
    location VARCHAR(100),
    requirement TEXT,
    budget DECIMAL(12,2),
    timeline VARCHAR(100),
    status VARCHAR(50) DEFAULT 'NEW',
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    assigned_to VARCHAR(100),
    follow_up_date DATE,
    notes TEXT,
    conversion_probability INTEGER DEFAULT 0,
    estimated_value DECIMAL(12,2),
    actual_value DECIMAL(12,2),
    closed_date DATE,
    closure_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- =============================================================================
-- PAYMENT MODULE
-- =============================================================================

CREATE TABLE IF NOT EXISTS subscription_plans (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR',
    duration_months INTEGER NOT NULL,
    features TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    max_products INTEGER,
    max_inquiries INTEGER,
    priority_support BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS subscriptions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    user_type VARCHAR(20), -- 'BUYER', 'VENDOR'
    plan_id BIGINT REFERENCES subscription_plans(id),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    amount_paid DECIMAL(10,2),
    payment_id VARCHAR(100),
    auto_renewal BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payments (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    user_type VARCHAR(20),
    order_id BIGINT REFERENCES orders(id),
    subscription_id BIGINT REFERENCES subscriptions(id),
    payment_gateway VARCHAR(50),
    payment_id VARCHAR(100) UNIQUE,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR',
    status VARCHAR(50) DEFAULT 'PENDING',
    payment_method VARCHAR(50),
    gateway_response TEXT,
    failure_reason TEXT,
    refund_amount DECIMAL(12,2) DEFAULT 0,
    refunded_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS transactions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    user_type VARCHAR(20),
    transaction_type VARCHAR(50) NOT NULL,
    reference_type VARCHAR(50), -- ORDER, SUBSCRIPTION, REFUND
    reference_id BIGINT,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR',
    description TEXT,
    status VARCHAR(50) DEFAULT 'COMPLETED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS refunds (
    id BIGSERIAL PRIMARY KEY,
    payment_id BIGINT REFERENCES payments(id),
    order_id BIGINT REFERENCES orders(id),
    refund_amount DECIMAL(12,2) NOT NULL,
    reason TEXT,
    status VARCHAR(50) DEFAULT 'PENDING',
    processed_at TIMESTAMP,
    gateway_refund_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS invoices (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    user_type VARCHAR(20),
    order_id BIGINT REFERENCES orders(id),
    subscription_id BIGINT REFERENCES subscriptions(id),
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    final_amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR',
    status VARCHAR(50) DEFAULT 'DRAFT',
    due_date DATE,
    paid_date DATE,
    invoice_data TEXT, -- JSON data
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- SUPPORT MODULE
-- =============================================================================

CREATE TABLE IF NOT EXISTS support_tickets (
    id BIGSERIAL PRIMARY KEY,
    ticket_number VARCHAR(50) UNIQUE NOT NULL,
    user_id BIGINT,
    user_type VARCHAR(20), -- 'BUYER', 'VENDOR'
    category VARCHAR(100),
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    status VARCHAR(50) DEFAULT 'OPEN',
    subject VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    assigned_to VARCHAR(100),
    resolved_at TIMESTAMP,
    resolution TEXT,
    satisfaction_rating INTEGER,
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS chats (
    id BIGSERIAL PRIMARY KEY,
    user1_id BIGINT,
    user1_type VARCHAR(20),
    user2_id BIGINT,
    user2_type VARCHAR(20),
    last_message TEXT,
    last_message_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS chat_messages (
    id BIGSERIAL PRIMARY KEY,
    chat_id BIGINT REFERENCES chats(id) ON DELETE CASCADE,
    sender_id BIGINT,
    sender_type VARCHAR(20),
    message TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'TEXT',
    attachment_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS chat_attachments (
    id BIGSERIAL PRIMARY KEY,
    chat_message_id BIGINT REFERENCES chat_messages(id) ON DELETE CASCADE,
    file_name VARCHAR(255),
    file_url TEXT NOT NULL,
    file_type VARCHAR(50),
    file_size BIGINT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS contact_messages (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    subject VARCHAR(200),
    message TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'NEW',
    responded_at TIMESTAMP,
    response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- SHARED/SYSTEM TABLES
-- =============================================================================

-- User Addresses
CREATE TABLE IF NOT EXISTS user_addresses (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    user_type VARCHAR(20),
    address_type VARCHAR(20) DEFAULT 'BILLING',
    address_line1 TEXT NOT NULL,
    address_line2 TEXT,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) DEFAULT 'India',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- KYC Documents
CREATE TABLE IF NOT EXISTS kyc_documents (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    user_type VARCHAR(20),
    document_type VARCHAR(50) NOT NULL,
    document_number VARCHAR(100),
    document_url TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING',
    verified_at TIMESTAMP,
    verified_by VARCHAR(100),
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- OTP Verification
CREATE TABLE IF NOT EXISTS otp_verifications (
    id BIGSERIAL PRIMARY KEY,
    identifier VARCHAR(100) NOT NULL, -- email or phone
    identifier_type VARCHAR(20) NOT NULL, -- EMAIL or PHONE
    otp_code VARCHAR(10) NOT NULL,
    purpose VARCHAR(50) NOT NULL, -- REGISTRATION, LOGIN, FORGOT_PASSWORD
    is_verified BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP NOT NULL,
    verified_at TIMESTAMP,
    attempts INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    user_type VARCHAR(20),
    type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    data TEXT, -- JSON data
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Activity Logs
CREATE TABLE IF NOT EXISTS activity_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    user_type VARCHAR(20),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id BIGINT,
    details TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- API Logs
CREATE TABLE IF NOT EXISTS api_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    method VARCHAR(10) NOT NULL,
    url TEXT NOT NULL,
    request_body TEXT,
    response_body TEXT,
    status_code INTEGER,
    response_time BIGINT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Error Logs
CREATE TABLE IF NOT EXISTS error_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    error_type VARCHAR(100),
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    request_url TEXT,
    request_method VARCHAR(10),
    request_body TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System Metrics
CREATE TABLE IF NOT EXISTS system_metrics (
    id BIGSERIAL PRIMARY KEY,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15,4),
    metric_unit VARCHAR(20),
    tags TEXT, -- JSON
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Banners
CREATE TABLE IF NOT EXISTS banners (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    image_url TEXT NOT NULL,
    link_url TEXT,
    position VARCHAR(50) DEFAULT 'HOME',
    is_active BOOLEAN DEFAULT TRUE,
    start_date DATE,
    end_date DATE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Campaigns
CREATE TABLE IF NOT EXISTS campaigns (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    campaign_type VARCHAR(50),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(12,2),
    status VARCHAR(50) DEFAULT 'DRAFT',
    target_audience TEXT, -- JSON
    metrics TEXT, -- JSON
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Coupons
CREATE TABLE IF NOT EXISTS coupons (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) NOT NULL, -- PERCENTAGE, FIXED
    discount_value DECIMAL(10,2) NOT NULL,
    minimum_amount DECIMAL(12,2),
    maximum_discount DECIMAL(12,2),
    usage_limit INTEGER,
    used_count INTEGER DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    applicable_for TEXT[], -- categories, products, users
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SEO Keywords
CREATE TABLE IF NOT EXISTS seo_keywords (
    id BIGSERIAL PRIMARY KEY,
    keyword VARCHAR(200) NOT NULL,
    page_type VARCHAR(50),
    page_id BIGINT,
    search_volume INTEGER DEFAULT 0,
    competition DECIMAL(3,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Buyer Leads (for lead generation)
CREATE TABLE IF NOT EXISTS buyer_leads (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    company VARCHAR(200),
    designation VARCHAR(100),
    industry VARCHAR(100),
    product_interest TEXT,
    budget DECIMAL(12,2),
    timeline VARCHAR(100),
    source VARCHAR(100),
    status VARCHAR(50) DEFAULT 'NEW',
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    assigned_to VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- MARKETPLACE SPECIFIC TABLES
-- =============================================================================

CREATE TABLE IF NOT EXISTS knowledge_base_articles (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100),
    tags TEXT[],
    is_published BOOLEAN DEFAULT FALSE,
    views_count INTEGER DEFAULT 0,
    helpful_count INTEGER DEFAULT 0,
    author VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sla_configurations (
    id BIGSERIAL PRIMARY KEY,
    service_type VARCHAR(100) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    response_time_hours INTEGER NOT NULL,
    resolution_time_hours INTEGER NOT NULL,
    escalation_time_hours INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sla_trackings (
    id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT REFERENCES support_tickets(id),
    sla_config_id BIGINT REFERENCES sla_configurations(id),
    response_due_at TIMESTAMP,
    resolution_due_at TIMESTAMP,
    escalation_due_at TIMESTAMP,
    responded_at TIMESTAMP,
    resolved_at TIMESTAMP,
    escalated_at TIMESTAMP,
    is_breached BOOLEAN DEFAULT FALSE,
    breach_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vendor_payments (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES vendors(id),
    order_id BIGINT REFERENCES orders(id),
    amount DECIMAL(12,2) NOT NULL,
    commission_amount DECIMAL(12,2) DEFAULT 0,
    net_amount DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_reference VARCHAR(100),
    status VARCHAR(50) DEFAULT 'PENDING',
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- ANALYTICS TABLES
-- =============================================================================

CREATE TABLE IF NOT EXISTS analytics (
    id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    user_id BIGINT,
    user_type VARCHAR(20),
    entity_type VARCHAR(50),
    entity_id BIGINT,
    properties TEXT, -- JSON data
    ip_address VARCHAR(45),
    user_agent TEXT,
    session_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Buyers indexes
CREATE INDEX IF NOT EXISTS idx_buyers_email ON buyers(email);
CREATE INDEX IF NOT EXISTS idx_buyers_phone ON buyers(phone);
CREATE INDEX IF NOT EXISTS idx_buyers_status ON buyers(buyer_status);
CREATE INDEX IF NOT EXISTS idx_buyers_verification ON buyers(verification_status);
CREATE INDEX IF NOT EXISTS idx_buyers_created_at ON buyers(created_at);

-- Products indexes
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_subcategory ON products(sub_category_id);
CREATE INDEX IF NOT EXISTS idx_products_vendor ON products(vendor_id);
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_featured ON products(is_featured);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);

-- Orders indexes
CREATE INDEX IF NOT EXISTS idx_orders_buyer ON orders(buyer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);

-- Vendors indexes
CREATE INDEX IF NOT EXISTS idx_vendors_email ON vendors(email);
CREATE INDEX IF NOT EXISTS idx_vendors_status ON vendors(vendor_status);
CREATE INDEX IF NOT EXISTS idx_vendors_verification ON vendors(verification_status);

-- Categories indexes
CREATE INDEX IF NOT EXISTS idx_categories_slug ON categories(slug);
CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_categories_active ON categories(is_active);

-- Support tickets indexes
CREATE INDEX IF NOT EXISTS idx_tickets_user ON support_tickets(user_id, user_type);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_priority ON support_tickets(priority);
CREATE INDEX IF NOT EXISTS idx_tickets_created_at ON support_tickets(created_at);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, user_type);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);

-- Activity logs indexes
CREATE INDEX IF NOT EXISTS idx_activity_logs_user ON activity_logs(user_id, user_type);
CREATE INDEX IF NOT EXISTS idx_activity_logs_action ON activity_logs(action);
CREATE INDEX IF NOT EXISTS idx_activity_logs_created_at ON activity_logs(created_at);

-- =============================================================================
-- INITIAL DATA
-- =============================================================================

-- Insert default admin user
INSERT INTO admins (username, email, password, first_name, last_name, role, is_super_admin) 
VALUES ('admin', 'admin@indiantrademart.com', '$2a$10$eImiTXuWVxfm37uY4JANjOhSzm.tKN8OWn6r.8TaxQ.IIz.AoRGjS', 'System', 'Administrator', 'SUPER_ADMIN', true)
ON CONFLICT (email) DO NOTHING;

-- Insert default subscription plans
INSERT INTO subscription_plans (name, description, price, duration_months, features, max_products, max_inquiries, priority_support) VALUES
('Free', 'Basic features for new users', 0.00, 1, ARRAY['Basic product listing', '5 inquiries per month'], 10, 5, false),
('Basic', 'Essential features for small businesses', 999.00, 12, ARRAY['Up to 100 products', 'Unlimited inquiries', 'Email support'], 100, -1, false),
('Premium', 'Advanced features for growing businesses', 2999.00, 12, ARRAY['Unlimited products', 'Priority listing', 'Phone support', 'Analytics dashboard'], -1, -1, true),
('Enterprise', 'Complete solution for large businesses', 9999.00, 12, ARRAY['Unlimited everything', 'Dedicated account manager', '24/7 support', 'Custom integrations'], -1, -1, true)
ON CONFLICT DO NOTHING;

-- Insert default categories
INSERT INTO categories (name, description, slug) VALUES
('Electronics', 'Electronic products and components', 'electronics'),
('Machinery', 'Industrial machinery and equipment', 'machinery'),
('Textiles', 'Textile products and fabrics', 'textiles'),
('Chemicals', 'Chemical products and raw materials', 'chemicals'),
('Food & Beverages', 'Food products and beverages', 'food-beverages'),
('Healthcare', 'Medical and healthcare products', 'healthcare'),
('Automotive', 'Automotive parts and accessories', 'automotive'),
('Construction', 'Construction materials and tools', 'construction')
ON CONFLICT (slug) DO NOTHING;

-- Insert SLA configurations
INSERT INTO sla_configurations (service_type, priority, response_time_hours, resolution_time_hours, escalation_time_hours) VALUES
('SUPPORT_TICKET', 'HIGH', 2, 24, 4),
('SUPPORT_TICKET', 'MEDIUM', 8, 72, 12),
('SUPPORT_TICKET', 'LOW', 24, 168, 48),
('INQUIRY', 'HIGH', 1, 8, 2),
('INQUIRY', 'MEDIUM', 4, 24, 8),
('INQUIRY', 'LOW', 12, 48, 24)
ON CONFLICT DO NOTHING;

-- =============================================================================
-- COMPLETION MESSAGE
-- =============================================================================

SELECT 'Database schema initialization completed successfully!' as message;
