-- Create user table for PostgreSQL
-- Note: Using quoted identifiers to handle reserved keywords

CREATE TABLE IF NOT EXISTS "user" (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(255) UNIQUE,
    password VARCHAR(255) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    role VARCHAR(50) DEFAULT 'ROLE_USER',
    business_name VARCHAR(255),
    business_address TEXT,
    gst_number VARCHAR(50),
    pan_number VARCHAR(50),
    vendor_type VARCHAR(50) DEFAULT 'BASIC',
    department VARCHAR(255),
    designation VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_email ON "user"(email);
CREATE INDEX IF NOT EXISTS idx_user_phone ON "user"(phone);
CREATE INDEX IF NOT EXISTS idx_user_role ON "user"(role);
CREATE INDEX IF NOT EXISTS idx_user_gst_number ON "user"(gst_number);
CREATE INDEX IF NOT EXISTS idx_user_pan_number ON "user"(pan_number);
CREATE INDEX IF NOT EXISTS idx_user_verified ON "user"(verified);
CREATE INDEX IF NOT EXISTS idx_user_is_active ON "user"(is_active);
