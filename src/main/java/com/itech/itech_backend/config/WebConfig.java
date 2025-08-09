package com.itech.itech_backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${file.upload.directory:uploads}")
    private String uploadDirectory;
    
    @Value("${allowed.origins:http://localhost:3000,http://localhost:3001}")
    private String allowedOrigins;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Convert relative path to absolute path
        java.io.File uploadDir = new java.io.File(uploadDirectory);
        String absoluteUploadPath = uploadDir.getAbsolutePath().replace("\\", "/") + "/";
        
        System.out.println("📁 Upload directory: " + uploadDirectory);
        System.out.println("📁 Absolute upload path: " + absoluteUploadPath);
        System.out.println("📁 Directory exists: " + uploadDir.exists());
        System.out.println("📁 Directory readable: " + uploadDir.canRead());
        
        // Existing API files handler
        registry.addResourceHandler("/api/files/**")
                .addResourceLocations("file:" + absoluteUploadPath)
                .setCachePeriod(3600); // Cache for 1 hour
        
        // Add direct uploads handler for product images
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + absoluteUploadPath)
                .setCachePeriod(3600); // Cache for 1 hour
    }
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins(allowedOrigins.split(","))
                .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }
}
