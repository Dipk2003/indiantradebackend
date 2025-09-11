-- ============================================
-- Phase 3: Foreign Key Constraints Migration
-- File: V003__add_foreign_key_constraints.sql
-- ============================================
-- 
-- This script adds foreign key constraints after data integrity is confirmed.
-- This is the final phase of the migration to enforce referential integrity.
--
-- ⚠️  CRITICAL SAFETY MEASURES:
-- - Only executes if Phase 2 data integrity validation passed
-- - Comprehensive constraint validation before adding FKs
-- - Rollback procedures for constraint violations
-- - Performance considerations for large tables

-- Enable comprehensive error reporting
SET sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';

-- Transaction isolation for consistency
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Start transaction
START TRANSACTION;

-- ============================================
-- PHASE 3.1: PRE-CONSTRAINT VALIDATION
-- ============================================

UPDATE migration_status 
SET status = 'RUNNING', started_at = CURRENT_TIMESTAMP, records_processed = 0
WHERE phase_name = 'ADD_FK_CONSTRAINTS';

-- Validate that Phase 2 completed successfully
SET @phase2_success = (
    SELECT COUNT(*) 
    FROM migration_status 
    WHERE phase_name LIKE 'DATA_BACKFILL_%' 
      AND status = 'COMPLETED'
);

SET @expected_phase2_count = 5; -- VALIDATION, BUYERS, VENDORS, ADMINS, EMPLOYEES

-- Check if all Phase 2 steps completed
IF @phase2_success < @expected_phase2_count THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Phase 2 migration not completed successfully. Cannot proceed with Phase 3.';
END IF;

-- Validate data integrity before adding constraints
SET @orphaned_buyers = (SELECT COUNT(*) FROM buyers WHERE user_id IS NULL);
SET @orphaned_vendors = (SELECT COUNT(*) FROM legacy_vendors WHERE user_id IS NULL);
SET @orphaned_admins = (SELECT COUNT(*) FROM admins WHERE user_id IS NULL);
SET @orphaned_employees = (SELECT COUNT(*) FROM employee_profiles WHERE user_id IS NULL);
SET @total_orphaned = @orphaned_buyers + @orphaned_vendors + @orphaned_admins + @orphaned_employees;

-- Check for constraint violations before adding FKs
SET @invalid_user_refs = (
    SELECT COUNT(*) FROM (
        SELECT b.user_id FROM buyers b WHERE b.user_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM user u WHERE u.id = b.user_id)
        UNION ALL
        SELECT v.user_id FROM legacy_vendors v WHERE v.user_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM user u WHERE u.id = v.user_id)
        UNION ALL
        SELECT a.user_id FROM admins a WHERE a.user_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM user u WHERE u.id = a.user_id)
        UNION ALL
        SELECT e.user_id FROM employee_profiles e WHERE e.user_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM user u WHERE u.id = e.user_id)
    ) invalid_refs
);

-- Fail if there are orphaned records or invalid references
IF @total_orphaned > 0 OR @invalid_user_refs > 0 THEN
    UPDATE migration_status 
    SET status = 'FAILED', 
        error_message = CONCAT('Data integrity check failed. Orphaned: ', @total_orphaned, ', Invalid refs: ', @invalid_user_refs),
        completed_at = CURRENT_TIMESTAMP
    WHERE phase_name = 'ADD_FK_CONSTRAINTS';
    
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Data integrity validation failed. Cannot add foreign key constraints.';
END IF;

-- ============================================
-- PHASE 3.2: ADD FOREIGN KEY CONSTRAINTS
-- ============================================

-- Add foreign key constraint for buyers table
ALTER TABLE buyers 
ADD CONSTRAINT fk_buyers_user 
FOREIGN KEY (user_id) REFERENCES user(id) 
ON DELETE SET NULL 
ON UPDATE CASCADE;

-- Create index for performance (if not exists)
CREATE INDEX IF NOT EXISTS idx_buyers_user_id ON buyers(user_id);

-- Add foreign key constraint for legacy_vendors table
ALTER TABLE legacy_vendors 
ADD CONSTRAINT fk_legacy_vendors_user 
FOREIGN KEY (user_id) REFERENCES user(id) 
ON DELETE SET NULL 
ON UPDATE CASCADE;

-- Create index for performance (if not exists) 
CREATE INDEX IF NOT EXISTS idx_legacy_vendors_user_id ON legacy_vendors(user_id);

-- Add foreign key constraint for admins table
ALTER TABLE admins 
ADD CONSTRAINT fk_admins_user 
FOREIGN KEY (user_id) REFERENCES user(id) 
ON DELETE SET NULL 
ON UPDATE CASCADE;

-- Create index for performance (if not exists)
CREATE INDEX IF NOT EXISTS idx_admins_user_id ON admins(user_id);

-- Add foreign key constraint for employee_profiles table
ALTER TABLE employee_profiles 
ADD CONSTRAINT fk_employee_profiles_user 
FOREIGN KEY (user_id) REFERENCES user(id) 
ON DELETE SET NULL 
ON UPDATE CASCADE;

-- Create index for performance (if not exists)
CREATE INDEX IF NOT EXISTS idx_employee_profiles_user_id ON employee_profiles(user_id);

-- ============================================
-- PHASE 3.3: CONSTRAINT VALIDATION
-- ============================================

-- Test all constraints by attempting sample operations
SET @constraint_test_passed = 1;

-- Test buyers constraint
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET @constraint_test_passed = 0;
    
    -- Try to insert buyer with invalid user_id (should fail)
    INSERT INTO buyers (buyer_name, email, password, user_id, created_at) 
    VALUES ('Test_Constraint', 'test_constraint@example.com', 'password', 999999, NOW());
    
    -- If we reach here, constraint failed
    SET @constraint_test_passed = 0;
    DELETE FROM buyers WHERE email = 'test_constraint@example.com';
END;

-- Test vendors constraint  
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET @constraint_test_passed = 0;
    
    -- Try to insert vendor with invalid user_id (should fail)
    INSERT INTO legacy_vendors (name, email, password, user_id, created_at) 
    VALUES ('Test_Constraint', 'test_constraint_vendor@example.com', 'password', 999999, NOW());
    
    -- If we reach here, constraint failed
    SET @constraint_test_passed = 0;
    DELETE FROM legacy_vendors WHERE email = 'test_constraint_vendor@example.com';
END;

-- Test admins constraint
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET @constraint_test_passed = 0;
    
    -- Try to insert admin with invalid user_id (should fail)
    INSERT INTO admins (name, email, password, user_id, created_at) 
    VALUES ('Test_Constraint', 'test_constraint_admin@example.com', 'password', 999999, NOW());
    
    -- If we reach here, constraint failed
    SET @constraint_test_passed = 0;
    DELETE FROM admins WHERE email = 'test_constraint_admin@example.com';
END;

-- Test employee_profiles constraint
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET @constraint_test_passed = 0;
    
    -- Try to insert employee with invalid user_id (should fail)
    INSERT INTO employee_profiles (first_name, last_name, work_email, department, designation, joining_date, user_id, created_at) 
    VALUES ('Test', 'Constraint', 'test_constraint_employee@example.com', 'IT', 'Developer', CURDATE(), 999999, NOW());
    
    -- If we reach here, constraint failed
    SET @constraint_test_passed = 0;
    DELETE FROM employee_profiles WHERE work_email = 'test_constraint_employee@example.com';
END;

-- ============================================
-- PHASE 3.4: PERFORMANCE OPTIMIZATION
-- ============================================

-- Analyze tables for query optimization after adding constraints
ANALYZE TABLE user, buyers, legacy_vendors, admins, employee_profiles;

-- Update table statistics for better query planning
-- This helps MySQL optimize queries involving the new foreign keys

-- ============================================
-- PHASE 3.5: AUDIT TRAIL
-- ============================================

-- Record constraint addition audit
INSERT INTO migration_audit (table_name, operation, record_id, old_values, new_values, migration_phase, created_at)
SELECT 
    'FOREIGN_KEYS' as table_name,
    'CONSTRAINTS_ADDED' as operation,
    0 as record_id,
    NULL as old_values,
    JSON_OBJECT(
        'buyers_fk', 'fk_buyers_user',
        'vendors_fk', 'fk_legacy_vendors_user',
        'admins_fk', 'fk_admins_user', 
        'employees_fk', 'fk_employee_profiles_user',
        'constraint_test_passed', @constraint_test_passed,
        'orphaned_records_check', @total_orphaned,
        'invalid_references_check', @invalid_user_refs
    ) as new_values,
    'ADD_FK_CONSTRAINTS' as migration_phase,
    CURRENT_TIMESTAMP as created_at;

-- ============================================
-- PHASE 3.6: FINAL VALIDATION
-- ============================================

-- Count constraints added
SET @constraints_added = (
    SELECT COUNT(*) 
    FROM information_schema.table_constraints tc
    WHERE tc.table_schema = DATABASE()
      AND tc.constraint_type = 'FOREIGN KEY'
      AND tc.constraint_name IN (
          'fk_buyers_user', 
          'fk_legacy_vendors_user', 
          'fk_admins_user', 
          'fk_employee_profiles_user'
      )
);

-- Final validation - should have 4 constraints
SET @expected_constraints = 4;

-- Update migration status with results
UPDATE migration_status 
SET 
    records_processed = @constraints_added,
    records_total = @expected_constraints,
    status = CASE 
        WHEN @constraints_added = @expected_constraints AND @constraint_test_passed = 1 THEN 'COMPLETED'
        ELSE 'FAILED' 
    END,
    error_message = CASE 
        WHEN @constraints_added != @expected_constraints THEN CONCAT('Expected ', @expected_constraints, ' constraints, but added ', @constraints_added)
        WHEN @constraint_test_passed != 1 THEN 'Constraint validation tests failed'
        ELSE NULL
    END,
    completed_at = CURRENT_TIMESTAMP
WHERE phase_name = 'ADD_FK_CONSTRAINTS';

-- ============================================
-- PHASE 3.7: MIGRATION COMPLETION
-- ============================================

-- Mark overall migration as completed
UPDATE migration_status 
SET status = 'COMPLETED', completed_at = CURRENT_TIMESTAMP
WHERE phase_name = 'MIGRATION_COMPLETE';

-- Insert migration completion record if not exists
INSERT IGNORE INTO migration_status (phase_name, status, started_at, completed_at, records_processed, records_total)
VALUES ('MIGRATION_COMPLETE', 'COMPLETED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, @constraints_added, @expected_constraints);

-- Final audit entry
INSERT INTO migration_audit (table_name, operation, record_id, old_values, new_values, migration_phase, created_at)
SELECT 
    'MIGRATION_COMPLETE' as table_name,
    'FULL_MIGRATION_COMPLETED' as operation,
    0 as record_id,
    NULL as old_values,
    JSON_OBJECT(
        'phase_1_schema', 'COMPLETED',
        'phase_2_data_backfill', 'COMPLETED',
        'phase_3_foreign_keys', 'COMPLETED',
        'total_constraints_added', @constraints_added,
        'data_integrity_validated', @total_orphaned = 0 AND @invalid_user_refs = 0,
        'migration_status', 'SUCCESS'
    ) as new_values,
    'MIGRATION_COMPLETE' as migration_phase,
    CURRENT_TIMESTAMP as created_at;

-- ============================================
-- COMMIT TRANSACTION
-- ============================================

-- Final check before commit
SELECT 
    'FINAL_MIGRATION_CHECK' as check_type,
    @constraints_added as constraints_added,
    @expected_constraints as expected_constraints,
    @constraint_test_passed as tests_passed,
    CASE 
        WHEN @constraints_added = @expected_constraints AND @constraint_test_passed = 1 THEN 'SUCCESS'
        ELSE 'FAILED'
    END as status;

-- Commit if all validations passed
IF @constraints_added = @expected_constraints AND @constraint_test_passed = 1 THEN
    COMMIT;
ELSE
    ROLLBACK;
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Phase 3 validation failed. Transaction rolled back.';
END IF;

-- ============================================
-- POST-MIGRATION VERIFICATION QUERIES
-- ============================================

-- These queries can be run after migration to verify success:

/*
-- Verification Query 1: Check all foreign key constraints
SELECT 
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    kcu.referenced_table_name,
    kcu.referenced_column_name,
    rc.update_rule,
    rc.delete_rule
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.referential_constraints rc ON tc.constraint_name = rc.constraint_name
WHERE tc.table_schema = DATABASE()
  AND tc.constraint_type = 'FOREIGN KEY'
  AND tc.constraint_name LIKE 'fk_%_user'
ORDER BY tc.table_name;

-- Verification Query 2: Check migration status summary
SELECT 
    phase_name,
    status,
    records_processed,
    records_total,
    TIMESTAMPDIFF(SECOND, started_at, completed_at) as duration_seconds,
    error_message
FROM migration_status 
ORDER BY 
    CASE phase_name
        WHEN 'SCHEMA_CREATION' THEN 1
        WHEN 'DATA_BACKFILL_VALIDATION' THEN 2
        WHEN 'DATA_BACKFILL_BUYERS' THEN 3
        WHEN 'DATA_BACKFILL_VENDORS' THEN 4
        WHEN 'DATA_BACKFILL_ADMINS' THEN 5
        WHEN 'DATA_BACKFILL_EMPLOYEES' THEN 6
        WHEN 'VALIDATE_DATA_INTEGRITY' THEN 7
        WHEN 'ADD_FK_CONSTRAINTS' THEN 8
        WHEN 'MIGRATION_COMPLETE' THEN 9
        ELSE 99
    END;

-- Verification Query 3: Data integrity final check
SELECT 
    'Final Data Integrity Check' as check_name,
    (SELECT COUNT(*) FROM buyers WHERE user_id IS NULL) as orphaned_buyers,
    (SELECT COUNT(*) FROM legacy_vendors WHERE user_id IS NULL) as orphaned_vendors,
    (SELECT COUNT(*) FROM admins WHERE user_id IS NULL) as orphaned_admins,
    (SELECT COUNT(*) FROM employee_profiles WHERE user_id IS NULL) as orphaned_employees,
    (SELECT COUNT(*) FROM user) as total_users,
    (SELECT COUNT(*) FROM buyers WHERE user_id IS NOT NULL) as linked_buyers,
    (SELECT COUNT(*) FROM legacy_vendors WHERE user_id IS NOT NULL) as linked_vendors,
    (SELECT COUNT(*) FROM admins WHERE user_id IS NOT NULL) as linked_admins,
    (SELECT COUNT(*) FROM employee_profiles WHERE user_id IS NOT NULL) as linked_employees;

-- Verification Query 4: Performance check on new constraints
SELECT 
    table_name,
    index_name,
    cardinality,
    sub_part,
    nullable
FROM information_schema.statistics 
WHERE table_schema = DATABASE()
  AND (index_name LIKE 'idx_%_user_id' OR index_name LIKE 'fk_%_user')
ORDER BY table_name, index_name;
*/

-- ============================================
-- MIGRATION COMPLETION MESSAGE
-- ============================================

SELECT 
    '🎉 COMPLETE MIGRATION FINISHED SUCCESSFULLY! 🎉' as message,
    CONCAT('Added ', @constraints_added, ' foreign key constraints') as constraints_summary,
    CASE 
        WHEN @constraint_test_passed = 1 THEN '✅ All constraint tests passed' 
        ELSE '❌ Some constraint tests failed' 
    END as validation_status,
    'Migration is now complete with full referential integrity!' as final_status;
