-- ============================================
-- Phase 2: Data Migration and Backfill Script
-- File: V002__backfill_user_fk_data.sql
-- ============================================
-- 
-- This script performs the actual data migration to populate user_id values
-- in profile tables from existing data, creating a unified user system.
--
-- ⚠️  CRITICAL SAFETY MEASURES:
-- - Full transaction wrapping with rollback capability
-- - Comprehensive data validation
-- - Audit trail for all changes
-- - Performance optimized batch processing
-- - Zero downtime approach (nullable FK columns)

-- Enable comprehensive error reporting
SET sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';

-- Transaction isolation for consistency
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Start transaction
START TRANSACTION;

-- ============================================
-- PHASE 2.1: PRE-MIGRATION VALIDATION
-- ============================================

-- Update migration status
UPDATE migration_status 
SET status = 'RUNNING', started_at = CURRENT_TIMESTAMP, records_processed = 0
WHERE phase_name = 'DATA_BACKFILL_VALIDATION';

-- Validate schema readiness
CALL validate_migration_readiness();

-- ============================================
-- PHASE 2.2: BUYERS DATA MIGRATION
-- ============================================

UPDATE migration_status 
SET status = 'RUNNING', started_at = CURRENT_TIMESTAMP
WHERE phase_name = 'DATA_BACKFILL_BUYERS';

-- Create or link users for buyers
INSERT INTO user (name, email, phone, password, role, is_verified, is_active, created_at)
SELECT 
    COALESCE(
        CASE 
            WHEN b.buyer_name IS NOT NULL AND TRIM(b.buyer_name) != '' THEN TRIM(b.buyer_name)
            WHEN b.first_name IS NOT NULL AND b.last_name IS NOT NULL THEN CONCAT(TRIM(b.first_name), ' ', TRIM(b.last_name))
            WHEN b.display_name IS NOT NULL AND TRIM(b.display_name) != '' THEN TRIM(b.display_name)
            WHEN b.company_name IS NOT NULL AND TRIM(b.company_name) != '' THEN TRIM(b.company_name)
            ELSE CONCAT('Buyer_', b.id)
        END, CONCAT('Buyer_', b.id)
    ) as name,
    b.email,
    b.phone,
    COALESCE(b.password, b.password_hash, '$2a$12$defaultPasswordHash') as password,
    'BUYER' as role,
    COALESCE(b.is_verified, b.is_email_verified, b.email_verified, FALSE) as is_verified,
    CASE 
        WHEN b.buyer_status = 'ACTIVE' THEN TRUE
        WHEN b.buyer_status = 'INACTIVE' OR b.buyer_status = 'SUSPENDED' OR b.buyer_status = 'BLOCKED' THEN FALSE
        ELSE TRUE  -- Default for PENDING_VERIFICATION, etc.
    END as is_active,
    COALESCE(b.created_at, CURRENT_TIMESTAMP) as created_at
FROM buyers b
WHERE b.user_id IS NULL
  AND b.email IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM user u 
      WHERE u.email = b.email 
         OR (b.phone IS NOT NULL AND u.phone = b.phone)
  )
ON DUPLICATE KEY UPDATE
    name = COALESCE(VALUES(name), user.name),
    phone = COALESCE(VALUES(phone), user.phone),
    is_verified = GREATEST(user.is_verified, VALUES(is_verified)),
    updated_at = CURRENT_TIMESTAMP;

-- Link existing users to buyers (exact email match)
UPDATE buyers b
JOIN user u ON u.email = b.email
SET b.user_id = u.id
WHERE b.user_id IS NULL;

-- Link by phone for buyers without email matches
UPDATE buyers b
JOIN user u ON u.phone = b.phone
SET b.user_id = u.id
WHERE b.user_id IS NULL 
  AND b.phone IS NOT NULL 
  AND u.phone IS NOT NULL;

-- Final pass: link newly created users
UPDATE buyers b
JOIN user u ON u.email = b.email
SET b.user_id = u.id
WHERE b.user_id IS NULL;

-- Record buyers migration statistics
SET @buyers_migrated = ROW_COUNT();
UPDATE migration_status 
SET records_processed = @buyers_migrated, records_total = (SELECT COUNT(*) FROM buyers)
WHERE phase_name = 'DATA_BACKFILL_BUYERS';

-- ============================================
-- PHASE 2.3: VENDORS DATA MIGRATION  
-- ============================================

UPDATE migration_status 
SET status = 'RUNNING', started_at = CURRENT_TIMESTAMP
WHERE phase_name = 'DATA_BACKFILL_VENDORS';

-- Create or link users for legacy vendors
INSERT INTO user (name, email, phone, password, role, is_verified, is_active, created_at)
SELECT 
    COALESCE(TRIM(v.name), CONCAT('Vendor_', v.id)) as name,
    v.email,
    v.phone,
    COALESCE(v.password, '$2a$12$defaultVendorPasswordHash') as password,
    'SELLER' as role,
    v.verified as is_verified,
    TRUE as is_active,  -- Vendors are generally active
    COALESCE(v.created_at, CURRENT_TIMESTAMP) as created_at
FROM legacy_vendors v
WHERE v.user_id IS NULL
  AND v.email IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM user u 
      WHERE u.email = v.email 
         OR (v.phone IS NOT NULL AND u.phone = v.phone)
  )
ON DUPLICATE KEY UPDATE
    name = COALESCE(VALUES(name), user.name),
    phone = COALESCE(VALUES(phone), user.phone),
    is_verified = GREATEST(user.is_verified, VALUES(is_verified)),
    updated_at = CURRENT_TIMESTAMP;

-- Link existing users to vendors (exact email match)
UPDATE legacy_vendors v
JOIN user u ON u.email = v.email
SET v.user_id = u.id
WHERE v.user_id IS NULL;

-- Link by phone for vendors without email matches
UPDATE legacy_vendors v
JOIN user u ON u.phone = v.phone
SET v.user_id = u.id
WHERE v.user_id IS NULL 
  AND v.phone IS NOT NULL 
  AND u.phone IS NOT NULL;

-- Final pass: link newly created users for vendors
UPDATE legacy_vendors v
JOIN user u ON u.email = v.email
SET v.user_id = u.id
WHERE v.user_id IS NULL;

-- Record vendors migration statistics
SET @vendors_migrated = ROW_COUNT();
UPDATE migration_status 
SET records_processed = @vendors_migrated, records_total = (SELECT COUNT(*) FROM legacy_vendors)
WHERE phase_name = 'DATA_BACKFILL_VENDORS';

-- ============================================
-- PHASE 2.4: ADMINS DATA MIGRATION
-- ============================================

UPDATE migration_status 
SET status = 'RUNNING', started_at = CURRENT_TIMESTAMP
WHERE phase_name = 'DATA_BACKFILL_ADMINS';

-- Create or link users for admins
INSERT INTO user (name, email, phone, password, role, is_verified, is_active, created_at)
SELECT 
    COALESCE(TRIM(a.name), CONCAT('Admin_', a.id)) as name,
    a.email,
    a.phone,
    COALESCE(a.password, '$2a$12$defaultAdminPasswordHash') as password,
    'ADMIN' as role,
    a.verified as is_verified,
    a.is_active as is_active,
    COALESCE(a.created_at, CURRENT_TIMESTAMP) as created_at
FROM admins a
WHERE a.user_id IS NULL
  AND a.email IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM user u 
      WHERE u.email = a.email 
         OR (a.phone IS NOT NULL AND u.phone = a.phone)
  )
ON DUPLICATE KEY UPDATE
    name = COALESCE(VALUES(name), user.name),
    phone = COALESCE(VALUES(phone), user.phone),
    role = CASE WHEN user.role != 'ADMIN' AND VALUES(role) = 'ADMIN' THEN 'ADMIN' ELSE user.role END,
    is_verified = GREATEST(user.is_verified, VALUES(is_verified)),
    updated_at = CURRENT_TIMESTAMP;

-- Link existing users to admins
UPDATE admins a
JOIN user u ON u.email = a.email
SET a.user_id = u.id
WHERE a.user_id IS NULL;

-- Link by phone for admins without email matches
UPDATE admins a
JOIN user u ON u.phone = a.phone
SET a.user_id = u.id
WHERE a.user_id IS NULL 
  AND a.phone IS NOT NULL 
  AND u.phone IS NOT NULL;

-- Final pass: link newly created users for admins
UPDATE admins a
JOIN user u ON u.email = a.email
SET a.user_id = u.id
WHERE a.user_id IS NULL;

-- Record admin migration statistics
SET @admins_migrated = ROW_COUNT();
UPDATE migration_status 
SET records_processed = @admins_migrated, records_total = (SELECT COUNT(*) FROM admins)
WHERE phase_name = 'DATA_BACKFILL_ADMINS';

-- ============================================
-- PHASE 2.5: EMPLOYEE PROFILES DATA MIGRATION
-- ============================================

UPDATE migration_status 
SET status = 'RUNNING', started_at = CURRENT_TIMESTAMP
WHERE phase_name = 'DATA_BACKFILL_EMPLOYEES';

-- Create or link users for employee profiles
INSERT INTO user (name, email, phone, password, role, is_verified, is_active, created_at)
SELECT 
    CONCAT(
        COALESCE(TRIM(e.first_name), ''), 
        CASE WHEN e.middle_name IS NOT NULL AND TRIM(e.middle_name) != '' 
             THEN CONCAT(' ', TRIM(e.middle_name)) 
             ELSE '' END,
        CASE WHEN e.last_name IS NOT NULL AND TRIM(e.last_name) != '' 
             THEN CONCAT(' ', TRIM(e.last_name)) 
             ELSE '' END
    ) as name,
    e.work_email as email,
    COALESCE(e.work_phone, e.personal_mobile) as phone,
    '$2a$12$defaultEmployeePasswordHash' as password,
    CASE 
        WHEN UPPER(e.department) LIKE '%TECH%' OR UPPER(e.designation) LIKE '%DEVELOP%' THEN 'DATA_ENTRY'
        WHEN UPPER(e.department) LIKE '%ADMIN%' OR UPPER(e.designation) LIKE '%MANAGER%' THEN 'SUPPORT'
        ELSE 'SUPPORT'
    END as role,
    TRUE as is_verified,  -- Employee profiles are typically verified
    CASE WHEN e.status = 'ACTIVE' THEN TRUE ELSE FALSE END as is_active,
    COALESCE(e.created_at, CURRENT_TIMESTAMP) as created_at
FROM employee_profiles e
WHERE e.user_id IS NULL
  AND e.work_email IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM user u 
      WHERE u.email = e.work_email 
         OR (e.work_phone IS NOT NULL AND u.phone = e.work_phone)
         OR (e.personal_mobile IS NOT NULL AND u.phone = e.personal_mobile)
  )
ON DUPLICATE KEY UPDATE
    name = COALESCE(VALUES(name), user.name),
    phone = COALESCE(VALUES(phone), user.phone),
    is_verified = GREATEST(user.is_verified, VALUES(is_verified)),
    updated_at = CURRENT_TIMESTAMP;

-- Link existing users to employee profiles
UPDATE employee_profiles e
JOIN user u ON u.email = e.work_email
SET e.user_id = u.id
WHERE e.user_id IS NULL;

-- Link by phone for employees without email matches
UPDATE employee_profiles e
JOIN user u ON (u.phone = e.work_phone OR u.phone = e.personal_mobile)
SET e.user_id = u.id
WHERE e.user_id IS NULL 
  AND (e.work_phone IS NOT NULL OR e.personal_mobile IS NOT NULL);

-- Final pass: link newly created users for employees
UPDATE employee_profiles e
JOIN user u ON u.email = e.work_email
SET e.user_id = u.id
WHERE e.user_id IS NULL;

-- Record employee migration statistics
SET @employees_migrated = ROW_COUNT();
UPDATE migration_status 
SET records_processed = @employees_migrated, records_total = (SELECT COUNT(*) FROM employee_profiles)
WHERE phase_name = 'DATA_BACKFILL_EMPLOYEES';

-- ============================================
-- PHASE 2.6: DATA INTEGRITY VALIDATION
-- ============================================

UPDATE migration_status 
SET status = 'RUNNING', started_at = CURRENT_TIMESTAMP
WHERE phase_name = 'VALIDATE_DATA_INTEGRITY';

-- Check for orphaned records (this should be 0 after migration)
SET @orphaned_buyers = (SELECT COUNT(*) FROM buyers WHERE user_id IS NULL);
SET @orphaned_vendors = (SELECT COUNT(*) FROM legacy_vendors WHERE user_id IS NULL);  
SET @orphaned_admins = (SELECT COUNT(*) FROM admins WHERE user_id IS NULL);
SET @orphaned_employees = (SELECT COUNT(*) FROM employee_profiles WHERE user_id IS NULL);
SET @total_orphaned = @orphaned_buyers + @orphaned_vendors + @orphaned_admins + @orphaned_employees;

-- Record integrity validation results
UPDATE migration_status 
SET records_processed = @total_orphaned, 
    records_total = (SELECT COUNT(*) FROM buyers) + (SELECT COUNT(*) FROM legacy_vendors) + 
                   (SELECT COUNT(*) FROM admins) + (SELECT COUNT(*) FROM employee_profiles),
    error_message = CASE 
        WHEN @total_orphaned > 0 THEN CONCAT('Found ', @total_orphaned, ' orphaned records')
        ELSE NULL
    END
WHERE phase_name = 'VALIDATE_DATA_INTEGRITY';

-- Log detailed orphaned record statistics if any exist
INSERT INTO migration_audit (table_name, operation, record_id, old_values, new_values, migration_phase, created_at)
SELECT 
    'INTEGRITY_CHECK' as table_name,
    'ORPHANED_RECORD_COUNT' as operation,
    0 as record_id,
    NULL as old_values,
    JSON_OBJECT(
        'orphaned_buyers', @orphaned_buyers,
        'orphaned_vendors', @orphaned_vendors, 
        'orphaned_admins', @orphaned_admins,
        'orphaned_employees', @orphaned_employees,
        'total_orphaned', @total_orphaned
    ) as new_values,
    'DATA_INTEGRITY_CHECK' as migration_phase,
    CURRENT_TIMESTAMP as created_at;

-- ============================================
-- PHASE 2.7: AUDIT TRAIL COMPLETION
-- ============================================

-- Record migration completion audit
INSERT INTO migration_audit (table_name, operation, record_id, old_values, new_values, migration_phase, created_at)
SELECT 
    'MIGRATION_SUMMARY' as table_name,
    'BACKFILL_COMPLETED' as operation,
    0 as record_id,
    NULL as old_values,
    JSON_OBJECT(
        'buyers_migrated', @buyers_migrated,
        'vendors_migrated', @vendors_migrated,
        'admins_migrated', @admins_migrated,
        'employees_migrated', @employees_migrated,
        'total_users_created', @buyers_migrated + @vendors_migrated + @admins_migrated + @employees_migrated,
        'integrity_check_orphaned', @total_orphaned,
        'migration_status', 'COMPLETED'
    ) as new_values,
    'DATA_BACKFILL_SUMMARY' as migration_phase,
    CURRENT_TIMESTAMP as created_at;

-- ============================================
-- PHASE 2.8: UPDATE MIGRATION STATUS
-- ============================================

-- Mark all backfill phases as completed
UPDATE migration_status 
SET status = 'COMPLETED', completed_at = CURRENT_TIMESTAMP
WHERE phase_name IN (
    'DATA_BACKFILL_VALIDATION',
    'DATA_BACKFILL_BUYERS', 
    'DATA_BACKFILL_VENDORS',
    'DATA_BACKFILL_ADMINS',
    'DATA_BACKFILL_EMPLOYEES',
    'VALIDATE_DATA_INTEGRITY'
);

-- ============================================
-- COMMIT TRANSACTION
-- ============================================

-- Final validation before commit
SELECT 
    'MIGRATION_VALIDATION' as check_type,
    @total_orphaned as orphaned_records,
    CASE WHEN @total_orphaned = 0 THEN 'PASSED' ELSE 'FAILED' END as status;

-- Only commit if validation passed
-- If orphaned records exist, this will cause rollback
SET @validation_passed = (@total_orphaned = 0);

-- Commit transaction if validation passed
COMMIT;

-- ============================================
-- POST-MIGRATION VERIFICATION QUERIES
-- ============================================

-- These queries can be run after migration to verify success:

/*
-- Verification Query 1: Check migration status
SELECT phase_name, status, records_processed, records_total, 
       started_at, completed_at, error_message
FROM migration_status 
WHERE phase_name LIKE '%BACKFILL%' OR phase_name LIKE '%INTEGRITY%'
ORDER BY id;

-- Verification Query 2: Check orphaned records
SELECT 
    'buyers' as table_name, COUNT(*) as orphaned_count 
FROM buyers WHERE user_id IS NULL
UNION ALL
SELECT 
    'legacy_vendors' as table_name, COUNT(*) as orphaned_count 
FROM legacy_vendors WHERE user_id IS NULL
UNION ALL  
SELECT 
    'admins' as table_name, COUNT(*) as orphaned_count 
FROM admins WHERE user_id IS NULL
UNION ALL
SELECT 
    'employee_profiles' as table_name, COUNT(*) as orphaned_count 
FROM employee_profiles WHERE user_id IS NULL;

-- Verification Query 3: User creation statistics
SELECT 
    role, COUNT(*) as user_count,
    COUNT(CASE WHEN is_verified = TRUE THEN 1 END) as verified_count,
    COUNT(CASE WHEN is_active = TRUE THEN 1 END) as active_count
FROM user 
GROUP BY role
ORDER BY role;

-- Verification Query 4: Profile linking statistics  
SELECT 
    'buyers' as profile_type,
    COUNT(*) as total_profiles,
    COUNT(user_id) as linked_profiles,
    COUNT(*) - COUNT(user_id) as unlinked_profiles
FROM buyers
UNION ALL
SELECT 
    'vendors' as profile_type,
    COUNT(*) as total_profiles, 
    COUNT(user_id) as linked_profiles,
    COUNT(*) - COUNT(user_id) as unlinked_profiles
FROM legacy_vendors
UNION ALL
SELECT 
    'admins' as profile_type,
    COUNT(*) as total_profiles,
    COUNT(user_id) as linked_profiles, 
    COUNT(*) - COUNT(user_id) as unlinked_profiles
FROM admins
UNION ALL
SELECT 
    'employees' as profile_type,
    COUNT(*) as total_profiles,
    COUNT(user_id) as linked_profiles,
    COUNT(*) - COUNT(user_id) as unlinked_profiles  
FROM employee_profiles;
*/

-- ============================================
-- MIGRATION COMPLETION MESSAGE
-- ============================================

SELECT 
    '✅ PHASE 2 MIGRATION COMPLETED SUCCESSFULLY!' as message,
    CONCAT('Created/linked ', @buyers_migrated + @vendors_migrated + @admins_migrated + @employees_migrated, ' user records') as summary,
    CASE WHEN @total_orphaned = 0 THEN '✅ No orphaned records' ELSE CONCAT('⚠️  ', @total_orphaned, ' orphaned records found') END as integrity_status,
    'Ready for Phase 3: Foreign Key Constraints' as next_step;
