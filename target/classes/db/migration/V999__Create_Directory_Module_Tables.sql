-- Directory Module Tables Migration
-- Creates tables for service providers, their images, reviews, and contact inquiries

-- Service Providers table
CREATE TABLE IF NOT EXISTS `service_providers` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `business_name` VARCHAR(255) NOT NULL,
    `owner_name` VARCHAR(255) NOT NULL,
    `category` VARCHAR(255) NOT NULL,
    `description` TEXT,
    `rating` DOUBLE DEFAULT 0.00,
    `review_count` INT DEFAULT 0,
    `years_of_experience` INT,
    `completed_projects` INT,
    `response_time` VARCHAR(100),
    `verified` BOOLEAN DEFAULT FALSE,
    
    -- Location Information
    `address` TEXT,
    `city` VARCHAR(255) NOT NULL,
    `state` VARCHAR(255) NOT NULL,
    `pincode` VARCHAR(10),
    `area` VARCHAR(255),
    `latitude` DOUBLE,
    `longitude` DOUBLE,
    
    -- Contact Information
    `mobile` VARCHAR(20) NOT NULL,
    `phone` VARCHAR(20),
    `email` VARCHAR(255),
    `website` VARCHAR(500),
    `whatsapp` VARCHAR(20),
    
    -- Services (JSON array stored as string)
    `services` TEXT,
    
    -- Business Hours
    `business_hours` VARCHAR(500),
    
    -- Additional Information
    `certifications` TEXT,
    `specializations` TEXT,
    `languages_spoken` VARCHAR(500),
    `service_areas` TEXT,
    `min_project_value` DOUBLE,
    `max_project_value` DOUBLE,
    
    -- Status and Verification
    `status` ENUM('ACTIVE', 'INACTIVE', 'PENDING', 'SUSPENDED', 'REJECTED') DEFAULT 'PENDING',
    `kyc_verified` BOOLEAN DEFAULT FALSE,
    `gst_number` VARCHAR(50),
    `pan_number` VARCHAR(50),
    
    -- SEO and Marketing
    `slug` VARCHAR(255) UNIQUE,
    `meta_title` VARCHAR(255),
    `meta_description` TEXT,
    `keywords` TEXT,
    
    -- Analytics
    `profile_views` BIGINT DEFAULT 0,
    `contact_requests` BIGINT DEFAULT 0,
    `last_active` TIMESTAMP NULL,
    
    -- Timestamps
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX `idx_category` (`category`),
    INDEX `idx_city_state` (`city`, `state`),
    INDEX `idx_status` (`status`),
    INDEX `idx_verified` (`verified`),
    INDEX `idx_rating` (`rating`),
    INDEX `idx_location` (`latitude`, `longitude`),
    INDEX `idx_slug` (`slug`)
);

-- Service Provider Images table
CREATE TABLE IF NOT EXISTS `service_provider_images` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `service_provider_id` BIGINT NOT NULL,
    `image_url` VARCHAR(1000) NOT NULL,
    `image_type` ENUM('PROFILE', 'GALLERY', 'WORK_SAMPLE', 'CERTIFICATE', 'PROJECT') NOT NULL,
    `title` VARCHAR(255),
    `description` TEXT,
    `display_order` INT DEFAULT 0,
    `is_primary` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (`service_provider_id`) REFERENCES `service_providers`(`id`) ON DELETE CASCADE,
    
    -- Indexes
    INDEX `idx_service_provider_id` (`service_provider_id`),
    INDEX `idx_image_type` (`image_type`),
    INDEX `idx_is_primary` (`is_primary`)
);

-- Service Provider Reviews table
CREATE TABLE IF NOT EXISTS `service_provider_reviews` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `service_provider_id` BIGINT NOT NULL,
    `reviewer_name` VARCHAR(255) NOT NULL,
    `reviewer_email` VARCHAR(255),
    `reviewer_phone` VARCHAR(20),
    `rating` INT NOT NULL CHECK (`rating` >= 1 AND `rating` <= 5),
    `title` VARCHAR(255),
    `review_text` TEXT,
    `service_used` VARCHAR(255),
    `project_value` DOUBLE,
    `completion_date` TIMESTAMP NULL,
    `verified` BOOLEAN DEFAULT FALSE,
    `helpful_count` INT DEFAULT 0,
    `status` ENUM('PENDING', 'APPROVED', 'REJECTED', 'FLAGGED') DEFAULT 'PENDING',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (`service_provider_id`) REFERENCES `service_providers`(`id`) ON DELETE CASCADE,
    
    -- Indexes
    INDEX `idx_service_provider_id` (`service_provider_id`),
    INDEX `idx_rating` (`rating`),
    INDEX `idx_status` (`status`),
    INDEX `idx_verified` (`verified`)
);

-- Contact Inquiries table
CREATE TABLE IF NOT EXISTS `contact_inquiries` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `service_provider_id` BIGINT NOT NULL,
    
    -- Contact Information
    `name` VARCHAR(255) NOT NULL,
    `mobile` VARCHAR(20) NOT NULL,
    `email` VARCHAR(255),
    `company` VARCHAR(255),
    
    -- Inquiry Details
    `service_required` VARCHAR(500),
    `message` TEXT,
    `location` VARCHAR(255),
    `timeline` VARCHAR(255),
    `budget` VARCHAR(255),
    
    -- Status and Tracking
    `status` ENUM('NEW', 'CONTACTED', 'IN_PROGRESS', 'QUOTED', 'CONVERTED', 'CLOSED', 'REJECTED') DEFAULT 'NEW',
    `priority` ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
    `source` VARCHAR(100),
    `ip_address` VARCHAR(45),
    `user_agent` TEXT,
    
    -- Response Tracking
    `responded_at` TIMESTAMP NULL,
    `response_message` TEXT,
    `follow_up_date` TIMESTAMP NULL,
    
    -- Additional Fields
    `urgent` BOOLEAN DEFAULT FALSE,
    `rating` INT CHECK (`rating` >= 1 AND `rating` <= 5),
    `feedback` TEXT,
    
    -- Timestamps
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (`service_provider_id`) REFERENCES `service_providers`(`id`) ON DELETE CASCADE,
    
    -- Indexes
    INDEX `idx_service_provider_id` (`service_provider_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_priority` (`priority`),
    INDEX `idx_created_at` (`created_at`)
);
