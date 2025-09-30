-- Simple test migration to verify Flyway is working
-- This will create a simple test table

CREATE TABLE flyway_test (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_flyway_test_name (name)
) ENGINE=InnoDB COMMENT='Test table to verify Flyway migration';

-- Insert test data
INSERT INTO flyway_test (name) VALUES ('Flyway Migration Test');

-- Log migration completion
SELECT 'V001: Test migration completed successfully' as status;
