package com.itech.itech_backend.config;

import com.itech.itech_backend.service.SubdomainService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final SubdomainService subdomainService;
    
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
        // Build comprehensive allowed origins list including subdomains
        String[] baseOrigins = allowedOrigins.split(",");
        java.util.Set<String> allAllowedOrigins = new java.util.HashSet<>();
        java.util.Set<String> allAllowedOriginPatterns = new java.util.HashSet<>();
        
        // Add base configured origins (specific URLs)
        for (String origin : baseOrigins) {
            allAllowedOrigins.add(origin.trim());
        }
        
        // Add common subdomain patterns for development and production
        allAllowedOrigins.add("http://vendor.localhost:3000");
        allAllowedOrigins.add("http://admin.localhost:3000");
        allAllowedOrigins.add("http://www.localhost:3000");
        allAllowedOrigins.add("https://vendor.localhost:3000");
        allAllowedOrigins.add("https://admin.localhost:3000");
        allAllowedOrigins.add("https://www.localhost:3000");
        
        // Production domain patterns (if configured) - use patterns for wildcards
        if (subdomainService != null) {
            // Add wildcard support for subdomain routing using patterns
            allAllowedOriginPatterns.add("https://*.example.com");
            allAllowedOriginPatterns.add("http://*.example.com");
        }
        
        System.out.println("🌐 Configured CORS origins: " + allAllowedOrigins);
        
        var corsConfig = registry.addMapping("/**")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
        
        // Set specific origins
        if (!allAllowedOrigins.isEmpty()) {
            corsConfig.allowedOrigins(allAllowedOrigins.toArray(new String[0]));
        }
        
        // Set origin patterns for wildcards
        if (!allAllowedOriginPatterns.isEmpty()) {
            corsConfig.allowedOriginPatterns(allAllowedOriginPatterns.toArray(new String[0]));
        }
    }
}
