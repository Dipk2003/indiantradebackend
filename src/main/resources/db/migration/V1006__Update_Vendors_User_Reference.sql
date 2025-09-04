-- Migration script to update vendors table foreign key reference
-- Version: V1006
-- Description: Update vendors table to reference the new user table instead of users

-- Drop the existing foreign key constraint
ALTER TABLE vendors DROP FOREIGN KEY vendors_ibfk_1;

-- Add new foreign key constraint referencing the user table
ALTER TABLE vendors 
ADD CONSTRAINT vendors_user_fk 
FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE;
