-- PostgreSQL Database Schema for iTech Backend
-- This script creates all necessary tables

-- Drop existing tables if they exist (in correct order to avoid foreign key conflicts)
DROP TABLE IF EXISTS cart_item CASCADE;
DROP TABLE IF EXISTS cart CASCADE;
DROP TABLE IF EXISTS order_item CASCADE;
DROP TABLE IF EXISTS "order" CASCADE;
DROP TABLE IF EXISTS lead CASCADE;
DROP TABLE IF EXISTS contact_message CASCADE;
DROP TABLE IF EXISTS chatbot_message CASCADE;
DROP TABLE IF EXISTS subscription CASCADE;
DROP TABLE IF EXISTS product_image CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TABLE IF EXISTS user_address CASCADE;
DROP TABLE IF EXISTS vendor_gst_selection CASCADE;
DROP TABLE IF EXISTS vendor_tax_profile CASCADE;
DROP TABLE IF EXISTS vendor_tds_selection CASCADE;
DROP TABLE IF EXISTS vendor_ranking CASCADE;
DROP TABLE IF EXISTS otp_verification CASCADE;
DROP TABLE IF EXISTS vendors CASCADE;
DROP TABLE IF EXISTS admins CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;

-- Create sequences
CREATE SEQUENCE IF NOT EXISTS user_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS vendors_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS admins_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS category_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS product_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS product_image_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS cart_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS cart_item_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS order_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS order_item_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS lead_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS contact_message_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS chatbot_message_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS subscription_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS user_address_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS vendor_gst_selection_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS vendor_tax_profile_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS vendor_tds_selection_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS vendor_ranking_id_seq START 1;
CREATE SEQUENCE IF NOT EXISTS otp_verification_id_seq START 1;

-- Create user table
CREATE TABLE "user" (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(255) UNIQUE,
    password VARCHAR(255) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    role VARCHAR(255) DEFAULT 'ROLE_USER',
    business_name VARCHAR(255),
    business_address TEXT,
    gst_number VARCHAR(255),
    pan_number VARCHAR(255),
    vendor_type VARCHAR(255) DEFAULT 'BASIC',
    department VARCHAR(255),
    designation VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create vendors table
CREATE TABLE vendors (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(255) UNIQUE,
    password VARCHAR(255) NOT NULL,
    business_name VARCHAR(255),
    business_address TEXT,
    gst_number VARCHAR(255),
    pan_number VARCHAR(255),
    vendor_type VARCHAR(255) DEFAULT 'BASIC',
    verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create admins table
CREATE TABLE admins (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(255) UNIQUE,
    password VARCHAR(255) NOT NULL,
    department VARCHAR(255),
    designation VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create category table
CREATE TABLE category (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    parent_id BIGINT REFERENCES category(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create product table
CREATE TABLE product (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    quantity_available INTEGER DEFAULT 0,
    category_id BIGINT REFERENCES category(id),
    vendor_id BIGINT REFERENCES "user"(id),
    sku VARCHAR(255),
    brand VARCHAR(255),
    model VARCHAR(255),
    specifications TEXT,
    min_order_quantity INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create product_image table
CREATE TABLE product_image (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT REFERENCES product(id) ON DELETE CASCADE,
    image_url VARCHAR(512) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    alt_text VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create cart table
CREATE TABLE cart (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES "user"(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create cart_item table
CREATE TABLE cart_item (
    id BIGSERIAL PRIMARY KEY,
    cart_id BIGINT REFERENCES cart(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES product(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create order table
CREATE TABLE "order" (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES "user"(id),
    vendor_id BIGINT REFERENCES "user"(id),
    order_number VARCHAR(255) UNIQUE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING',
    payment_status VARCHAR(50) DEFAULT 'PENDING',
    payment_method VARCHAR(50),
    shipping_address TEXT,
    billing_address TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create order_item table
CREATE TABLE order_item (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES "order"(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES product(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create lead table
CREATE TABLE lead (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES "user"(id),
    vendor_id BIGINT REFERENCES "user"(id),
    product_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    budget_min DECIMAL(10,2),
    budget_max DECIMAL(10,2),
    requirements TEXT,
    priority VARCHAR(50) DEFAULT 'MEDIUM',
    status VARCHAR(50) DEFAULT 'OPEN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create contact_message table
CREATE TABLE contact_message (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(255),
    subject VARCHAR(255),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create chatbot_message table
CREATE TABLE chatbot_message (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES "user"(id),
    session_id VARCHAR(255),
    message TEXT NOT NULL,
    response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create subscription table
CREATE TABLE subscription (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES "user"(id),
    plan_name VARCHAR(255) NOT NULL,
    plan_type VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create user_address table
CREATE TABLE user_address (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES "user"(id) ON DELETE CASCADE,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(255) NOT NULL,
    state VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(255) DEFAULT 'India',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create vendor_gst_selection table
CREATE TABLE vendor_gst_selection (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES "user"(id) ON DELETE CASCADE,
    gst_number VARCHAR(255) NOT NULL,
    business_name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create vendor_tax_profile table
CREATE TABLE vendor_tax_profile (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES "user"(id) ON DELETE CASCADE,
    pan_number VARCHAR(255) NOT NULL,
    gst_number VARCHAR(255),
    tax_registration_type VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create vendor_tds_selection table
CREATE TABLE vendor_tds_selection (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES "user"(id) ON DELETE CASCADE,
    tds_rate DECIMAL(5,2) NOT NULL,
    applicable_from DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create vendor_ranking table
CREATE TABLE vendor_ranking (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES "user"(id) ON DELETE CASCADE,
    ranking_score DECIMAL(5,2) DEFAULT 0.00,
    total_orders INTEGER DEFAULT 0,
    total_sales DECIMAL(12,2) DEFAULT 0.00,
    rating DECIMAL(3,2) DEFAULT 0.00,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create otp_verification table
CREATE TABLE otp_verification (
    id BIGSERIAL PRIMARY KEY,
    contact VARCHAR(255) NOT NULL,
    otp_code VARCHAR(10) NOT NULL,
    verification_type VARCHAR(50) NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_user_email ON "user"(email);
CREATE INDEX idx_user_phone ON "user"(phone);
CREATE INDEX idx_user_role ON "user"(role);
CREATE INDEX idx_product_vendor ON product(vendor_id);
CREATE INDEX idx_product_category ON product(category_id);
CREATE INDEX idx_product_active ON product(is_active);
CREATE INDEX idx_cart_user ON cart(user_id);
CREATE INDEX idx_cart_item_cart ON cart_item(cart_id);
CREATE INDEX idx_cart_item_product ON cart_item(product_id);
CREATE INDEX idx_order_user ON "order"(user_id);
CREATE INDEX idx_order_vendor ON "order"(vendor_id);
CREATE INDEX idx_order_status ON "order"(status);
CREATE INDEX idx_lead_user ON lead(user_id);
CREATE INDEX idx_lead_vendor ON lead(vendor_id);
CREATE INDEX idx_lead_status ON lead(status);
CREATE INDEX idx_otp_contact ON otp_verification(contact);
CREATE INDEX idx_otp_expires ON otp_verification(expires_at);
