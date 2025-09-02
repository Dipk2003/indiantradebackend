-- Fix Directory Module Tables - Change DECIMAL to DOUBLE
-- This fixes the precision/scale issue with Hibernate and MySQL

-- Fix service_providers table
ALTER TABLE `service_providers` 
MODIFY COLUMN `rating` DOUBLE DEFAULT 0.00,
MODIFY COLUMN `latitude` DOUBLE,
MODIFY COLUMN `longitude` DOUBLE,
MODIFY COLUMN `min_project_value` DOUBLE,
MODIFY COLUMN `max_project_value` DOUBLE;

-- Fix service_provider_reviews table
ALTER TABLE `service_provider_reviews` 
MODIFY COLUMN `project_value` DOUBLE;
