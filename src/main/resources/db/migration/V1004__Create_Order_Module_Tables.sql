-- Migration script for Order Management System
-- Version: V1004
-- Description: Create comprehensive tables for order management with proper relationships and constraints

-- ===============================
-- MAIN ORDERS TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS orders (
    -- Primary Key
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    
    -- Order Identification
    order_number VARCHAR(50) NOT NULL UNIQUE,
    reference_number VARCHAR(100),
    po_number VARCHAR(100),
    
    -- Party References
    buyer_id BIGINT NOT NULL,
    company_id BIGINT,
    primary_vendor_id BIGINT,
    
    -- Order Status
    order_status ENUM('DRAFT', 'PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'PARTIALLY_SHIPPED', 
                      'DELIVERED', 'PARTIALLY_DELIVERED', 'COMPLETED', 'CANCELLED', 'REFUNDED', 
                      'RETURNED', 'FAILED') NOT NULL DEFAULT 'PENDING',
    fulfillment_status ENUM('UNFULFILLED', 'PARTIALLY_FULFILLED', 'FULFILLED', 'SHIPPED', 
                           'DELIVERED', 'RETURNED', 'CANCELLED') DEFAULT 'UNFULFILLED',
    payment_status ENUM('PENDING', 'AUTHORIZED', 'PAID', 'PARTIALLY_PAID', 'FAILED', 
                        'CANCELLED', 'REFUNDED', 'PARTIALLY_REFUNDED', 'DISPUTED') DEFAULT 'PENDING',
    
    -- Financial Information
    subtotal_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(15,2) DEFAULT 0.00,
    shipping_amount DECIMAL(15,2) DEFAULT 0.00,
    discount_amount DECIMAL(15,2) DEFAULT 0.00,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'INR',
    exchange_rate DECIMAL(10,4) DEFAULT 1.0000,
    
    -- Shipping Address
    shipping_address_line1 VARCHAR(255),
    shipping_address_line2 VARCHAR(255),
    shipping_city VARCHAR(100),
    shipping_state VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    shipping_country VARCHAR(100),
    shipping_contact_name VARCHAR(100),
    shipping_contact_phone VARCHAR(20),
    
    -- Billing Address
    billing_address_line1 VARCHAR(255),
    billing_address_line2 VARCHAR(255),
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_postal_code VARCHAR(20),
    billing_country VARCHAR(100),
    billing_contact_name VARCHAR(100),
    billing_contact_phone VARCHAR(20),
    
    -- Shipping Information
    shipping_method VARCHAR(100),
    shipping_carrier VARCHAR(100),
    tracking_number VARCHAR(100),
    expected_delivery_date TIMESTAMP NULL,
    actual_delivery_date TIMESTAMP NULL,
    
    -- Order Items Summary
    total_items INT DEFAULT 0,
    total_quantity INT DEFAULT 0,
    
    -- Discounts and Promotions
    coupon_code VARCHAR(50),
    coupon_discount_amount DECIMAL(15,2) DEFAULT 0.00,
    promotional_discount_amount DECIMAL(15,2) DEFAULT 0.00,
    volume_discount_amount DECIMAL(15,2) DEFAULT 0.00,
    
    -- Payment Information
    payment_method ENUM('CASH', 'CARD', 'BANK_TRANSFER', 'CHECK', 'CREDIT', 'UPI', 'WALLET', 'NET_BANKING', 'COD'),
    payment_reference VARCHAR(200),
    paid_amount DECIMAL(15,2) DEFAULT 0.00,
    outstanding_amount DECIMAL(15,2) DEFAULT 0.00,
    payment_due_date TIMESTAMP NULL,
    payment_terms VARCHAR(100),
    
    -- Tax Information
    tax_type VARCHAR(50),
    tax_rate DECIMAL(5,2),
    tax_inclusive BOOLEAN DEFAULT FALSE,
    tax_number VARCHAR(50),
    
    -- Order Workflow Timestamps
    confirmed_at TIMESTAMP NULL,
    shipped_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    cancellation_reason VARCHAR(500),
    approved_by VARCHAR(100),
    approved_at TIMESTAMP NULL,
    
    -- Special Instructions and Notes
    special_instructions TEXT,
    internal_notes TEXT,
    customer_notes TEXT,
    
    -- Priority and Urgency
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT', 'CRITICAL') DEFAULT 'NORMAL',
    is_urgent BOOLEAN DEFAULT FALSE,
    required_by_date TIMESTAMP NULL,
    
    -- B2B Specific Fields
    order_type ENUM('STANDARD', 'QUOTE', 'RECURRING', 'BULK', 'SAMPLE', 'RETURN', 'EXCHANGE') DEFAULT 'STANDARD',
    quote_valid_until TIMESTAMP NULL,
    credit_approved BOOLEAN DEFAULT FALSE,
    credit_limit_checked BOOLEAN DEFAULT FALSE,
    
    -- Analytics and Metrics
    processing_time_hours INT,
    fulfillment_time_hours INT,
    customer_rating INT CHECK (customer_rating >= 1 AND customer_rating <= 5),
    customer_feedback TEXT,
    
    -- Audit and Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    
    -- Foreign Key Constraints
    FOREIGN KEY (buyer_id) REFERENCES buyers(id) ON DELETE RESTRICT,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL,
    FOREIGN KEY (primary_vendor_id) REFERENCES vendors(id) ON DELETE SET NULL,
    
    -- Indexes for Performance
    INDEX idx_order_number (order_number),
    INDEX idx_order_buyer (buyer_id),
    INDEX idx_order_status (order_status),
    INDEX idx_order_created (created_at),
    INDEX idx_order_amount (total_amount),
    INDEX idx_order_payment_status (payment_status),
    INDEX idx_order_fulfillment_status (fulfillment_status),
    INDEX idx_order_priority (priority),
    INDEX idx_order_vendor (primary_vendor_id),
    INDEX idx_order_company (company_id),
    INDEX idx_order_type (order_type),
    INDEX idx_order_urgent (is_urgent),
    INDEX idx_order_payment_due (payment_due_date),
    INDEX idx_order_delivery_expected (expected_delivery_date)
);

-- ===============================
-- ORDER ITEMS TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS order_items (
    -- Primary Key
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    
    -- Associations
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    vendor_id BIGINT NOT NULL,
    
    -- Product Information (Snapshot at time of order)
    product_sku VARCHAR(100),
    product_name VARCHAR(255) NOT NULL,
    product_description TEXT,
    product_brand VARCHAR(100),
    product_category VARCHAR(100),
    
    -- Variant Information
    variant_type VARCHAR(50),
    variant_value VARCHAR(100),
    variant_attributes TEXT,
    
    -- Quantity and Pricing
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(15,2) NOT NULL CHECK (unit_price >= 0),
    original_unit_price DECIMAL(15,2),
    total_price DECIMAL(15,2) NOT NULL CHECK (total_price >= 0),
    currency VARCHAR(3) DEFAULT 'INR',
    
    -- Discounts
    item_discount_amount DECIMAL(15,2) DEFAULT 0.00,
    item_discount_percentage DECIMAL(5,2) DEFAULT 0.00,
    volume_discount_amount DECIMAL(15,2) DEFAULT 0.00,
    promotional_discount_amount DECIMAL(15,2) DEFAULT 0.00,
    
    -- Tax Information
    tax_amount DECIMAL(15,2) DEFAULT 0.00,
    tax_rate DECIMAL(5,2) DEFAULT 0.00,
    tax_type VARCHAR(50),
    hsn_code VARCHAR(20),
    
    -- Fulfillment Status
    fulfillment_status ENUM('PENDING', 'CONFIRMED', 'PROCESSING', 'PACKED', 'SHIPPED', 
                           'PARTIALLY_SHIPPED', 'DELIVERED', 'PARTIALLY_DELIVERED', 
                           'CANCELLED', 'RETURNED', 'REFUNDED') DEFAULT 'PENDING',
    quantity_shipped INT DEFAULT 0 CHECK (quantity_shipped >= 0),
    quantity_delivered INT DEFAULT 0 CHECK (quantity_delivered >= 0),
    quantity_cancelled INT DEFAULT 0 CHECK (quantity_cancelled >= 0),
    quantity_returned INT DEFAULT 0 CHECK (quantity_returned >= 0),
    
    -- Shipping Information
    weight DECIMAL(10,3),
    dimensions VARCHAR(100),
    requires_shipping BOOLEAN DEFAULT TRUE,
    shipping_class VARCHAR(50),
    
    -- Dates and Timeline
    expected_ship_date TIMESTAMP NULL,
    actual_ship_date TIMESTAMP NULL,
    expected_delivery_date TIMESTAMP NULL,
    actual_delivery_date TIMESTAMP NULL,
    
    -- Special Instructions
    special_instructions TEXT,
    gift_message TEXT,
    is_gift BOOLEAN DEFAULT FALSE,
    
    -- Return and Refund
    is_returnable BOOLEAN DEFAULT TRUE,
    return_window_days INT,
    refunded_amount DECIMAL(15,2) DEFAULT 0.00,
    return_reason TEXT,
    
    -- External References
    vendor_item_id VARCHAR(100),
    vendor_sku VARCHAR(100),
    tracking_number VARCHAR(100),
    
    -- Audit Fields
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE RESTRICT,
    
    -- Indexes for Performance
    INDEX idx_order_item_order (order_id),
    INDEX idx_order_item_product (product_id),
    INDEX idx_order_item_vendor (vendor_id),
    INDEX idx_order_item_fulfillment (fulfillment_status),
    INDEX idx_order_item_sku (product_sku),
    INDEX idx_order_item_category (product_category),
    INDEX idx_order_item_brand (product_brand),
    INDEX idx_order_item_shipped (quantity_shipped),
    INDEX idx_order_item_delivered (quantity_delivered),
    INDEX idx_order_item_returnable (is_returnable),
    INDEX idx_order_item_gift (is_gift),
    INDEX idx_order_item_ship_date (expected_ship_date),
    INDEX idx_order_item_delivery_date (expected_delivery_date)
);

-- ===============================
-- ORDER COMMUNICATIONS TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS order_communications (
    -- Primary Key
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    
    -- Association
    order_id BIGINT NOT NULL,
    
    -- Communication Details
    communication_type ENUM('EMAIL', 'SMS', 'PHONE_CALL', 'CHAT', 'INTERNAL_NOTE', 'SYSTEM_MESSAGE', 'NOTIFICATION') NOT NULL,
    direction ENUM('INBOUND', 'OUTBOUND'),
    sender VARCHAR(100),
    recipient VARCHAR(100),
    subject VARCHAR(200),
    message TEXT NOT NULL,
    external_reference VARCHAR(100),
    is_internal BOOLEAN DEFAULT FALSE,
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL',
    
    -- Audit Fields
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    
    -- Foreign Key Constraints
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    
    -- Indexes for Performance
    INDEX idx_order_comm_order (order_id),
    INDEX idx_order_comm_type (communication_type),
    INDEX idx_order_comm_created (created_at),
    INDEX idx_order_comm_direction (direction),
    INDEX idx_order_comm_priority (priority),
    INDEX idx_order_comm_internal (is_internal)
);

-- ===============================
-- MIGRATION COMPLETED SUCCESSFULLY
-- ===============================
-- Note: Additional indexes are already defined in the table creation statements above
