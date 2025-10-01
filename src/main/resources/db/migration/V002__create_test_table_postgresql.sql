-- MySQL compatible test migration
-- Converted from PostgreSQL syntax to MySQL syntax

CREATE TABLE IF NOT EXISTS flyway_test_mysql (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index (MySQL syntax)
CREATE INDEX idx_flyway_test_mysql_name ON flyway_test_mysql (name);

-- Insert test data (MySQL doesn't support ON CONFLICT DO NOTHING, use INSERT IGNORE instead)
INSERT IGNORE INTO flyway_test_mysql (name) VALUES ('MySQL Flyway Migration Test');

-- Add comment to table (MySQL syntax)
ALTER TABLE flyway_test_mysql COMMENT = 'MySQL test table to verify Flyway migration';
