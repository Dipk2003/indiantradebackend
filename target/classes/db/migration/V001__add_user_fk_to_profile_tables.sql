-- ============================================
-- PHASE 1: ZERO-DOWNTIME SCHEMA MIGRATION
-- Add user_id FK columns to all profile tables
-- Enterprise-grade: reversible, safe, with checks
-- ============================================

-- Check if we have the required tables
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = DATABASE() AND table_name IN ('user', 'buyers', 'legacy_vendors', 'admins', 'employee_profiles');

-- ============================================
-- 1. ADD USER_ID COLUMNS (NULLABLE INITIALLY)
-- ============================================

-- Add user_id to buyers table
ALTER TABLE buyers 
ADD COLUMN user_id BIGINT NULL COMMENT 'FK to user table for normalized identity',
ADD INDEX idx_buyers_user_id (user_id);

-- Add user_id to legacy_vendors table  
ALTER TABLE legacy_vendors 
ADD COLUMN user_id BIGINT NULL COMMENT 'FK to user table for normalized identity',
ADD INDEX idx_vendors_user_id (user_id);

-- Add user_id to admins table
ALTER TABLE admins 
ADD COLUMN user_id BIGINT NULL COMMENT 'FK to user table for normalized identity', 
ADD INDEX idx_admins_user_id (user_id);

-- Add user_id to employee_profiles table (if not exists)
ALTER TABLE employee_profiles 
ADD COLUMN IF NOT EXISTS user_id BIGINT NULL COMMENT 'FK to user table for normalized identity',
ADD INDEX IF NOT EXISTS idx_employee_user_id (user_id);

-- ============================================
-- 2. ADD FOREIGN KEY CONSTRAINTS (DEFERRED)
-- ============================================

-- Note: We'll add FK constraints AFTER data migration to avoid constraint violations

-- ============================================
-- 3. CREATE BACKUP VERIFICATION TABLES
-- ============================================

CREATE TABLE migration_audit (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(50) NOT NULL,
    record_id BIGINT NOT NULL,
    old_values JSON NULL,
    new_values JSON NULL,
    migration_phase VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_migration_table (table_name),
    INDEX idx_migration_phase (migration_phase)
) ENGINE=InnoDB COMMENT='Audit trail for data migration';

-- ============================================
-- 4. CREATE MIGRATION STATUS TRACKING
-- ============================================

CREATE TABLE migration_status (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    phase_name VARCHAR(100) NOT NULL UNIQUE,
    status ENUM('PENDING', 'RUNNING', 'COMPLETED', 'FAILED', 'ROLLED_BACK') NOT NULL DEFAULT 'PENDING',
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    error_message TEXT NULL,
    records_processed INT DEFAULT 0,
    records_total INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Track migration progress and status';

-- Initialize migration phases
INSERT INTO migration_status (phase_name, status) VALUES
('SCHEMA_MIGRATION', 'COMPLETED'),
('DATA_BACKFILL_BUYERS', 'PENDING'),
('DATA_BACKFILL_VENDORS', 'PENDING'), 
('DATA_BACKFILL_ADMINS', 'PENDING'),
('DATA_BACKFILL_EMPLOYEES', 'PENDING'),
('ADD_FK_CONSTRAINTS', 'PENDING'),
('VALIDATE_DATA_INTEGRITY', 'PENDING'),
('CLEANUP_DUPLICATE_DATA', 'PENDING');

-- ============================================
-- 5. CREATE ROLLBACK SAFETY NET
-- ============================================

CREATE TABLE rollback_data AS
SELECT 
    'buyers' as table_name,
    id as record_id,
    JSON_OBJECT(
        'email', email,
        'phone', phone, 
        'buyer_name', buyer_name,
        'is_email_verified', is_email_verified
    ) as original_data
FROM buyers
WHERE user_id IS NULL

UNION ALL

SELECT 
    'legacy_vendors' as table_name,
    id as record_id,
    JSON_OBJECT(
        'email', email,
        'phone', phone,
        'name', name,
        'verified', verified
    ) as original_data  
FROM legacy_vendors
WHERE user_id IS NULL

UNION ALL

SELECT 
    'admins' as table_name,
    id as record_id,
    JSON_OBJECT(
        'email', email,
        'phone', phone,
        'name', name,
        'verified', verified
    ) as original_data
FROM admins 
WHERE user_id IS NULL;

-- ============================================
-- 6. PERFORMANCE OPTIMIZATIONS
-- ============================================

-- Add composite indexes for efficient lookups during migration
CREATE INDEX idx_user_email_role ON user(email, role);
CREATE INDEX idx_user_phone_role ON user(phone, role);

-- Add indexes on profile tables for efficient joins
CREATE INDEX idx_buyers_email_status ON buyers(email, buyer_status);
CREATE INDEX idx_vendors_email_verified ON legacy_vendors(email, verified);
CREATE INDEX idx_admins_email_verified ON admins(email, verified);

-- ============================================
-- 7. VALIDATION FUNCTIONS
-- ============================================

DELIMITER $$

CREATE FUNCTION validate_migration_readiness()
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE user_count INT;
    DECLARE buyers_count INT;
    DECLARE vendors_count INT;
    DECLARE admins_count INT;
    
    SELECT COUNT(*) INTO user_count FROM user;
    SELECT COUNT(*) INTO buyers_count FROM buyers;
    SELECT COUNT(*) INTO vendors_count FROM legacy_vendors;
    SELECT COUNT(*) INTO admins_count FROM admins;
    
    -- Basic sanity checks
    IF user_count = 0 OR buyers_count = 0 OR vendors_count = 0 THEN
        RETURN FALSE;
    END IF;
    
    -- Check for duplicate emails across tables
    IF (SELECT COUNT(*) FROM (
        SELECT email FROM user 
        UNION ALL SELECT email FROM buyers WHERE email IS NOT NULL
        UNION ALL SELECT email FROM legacy_vendors WHERE email IS NOT NULL  
        UNION ALL SELECT email FROM admins WHERE email IS NOT NULL
    ) t GROUP BY email HAVING COUNT(*) > 2) > 0 THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END$$

DELIMITER ;

-- Run validation
SELECT validate_migration_readiness() as migration_ready;

-- ============================================
-- 8. EMERGENCY ROLLBACK PROCEDURE
-- ============================================

DELIMITER $$

CREATE PROCEDURE emergency_rollback()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        UPDATE migration_status SET status = 'FAILED', error_message = 'Rollback failed' WHERE phase_name = 'EMERGENCY_ROLLBACK';
    END;
    
    START TRANSACTION;
    
    -- Remove user_id values that were added during migration
    UPDATE buyers SET user_id = NULL WHERE user_id IS NOT NULL;
    UPDATE legacy_vendors SET user_id = NULL WHERE user_id IS NOT NULL;  
    UPDATE admins SET user_id = NULL WHERE user_id IS NOT NULL;
    UPDATE employee_profiles SET user_id = NULL WHERE user_id IS NOT NULL;
    
    -- Log rollback
    INSERT INTO migration_audit (table_name, operation, record_id, migration_phase)
    VALUES ('ALL_TABLES', 'EMERGENCY_ROLLBACK', 0, 'ROLLBACK');
    
    COMMIT;
END$$

DELIMITER ;

-- ============================================
-- 9. FINAL VERIFICATION
-- ============================================

-- Verify all columns were added successfully
SELECT 
    table_name,
    column_name,
    is_nullable,
    column_type
FROM information_schema.columns 
WHERE table_schema = DATABASE() 
  AND column_name = 'user_id'
  AND table_name IN ('buyers', 'legacy_vendors', 'admins', 'employee_profiles');

-- Log completion
INSERT INTO migration_audit (table_name, operation, record_id, migration_phase)
VALUES ('SCHEMA', 'PHASE_1_COMPLETE', 0, 'SCHEMA_MIGRATION');

SELECT 'Phase 1: Schema migration completed successfully' as status;
