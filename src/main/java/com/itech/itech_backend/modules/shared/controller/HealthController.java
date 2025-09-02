package com.itech.itech_backend.modules.shared.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.sql.DataSource;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * Enhanced Health Controller for iTech Backend
 * ===========================================
 * 
 * Provides comprehensive health monitoring for:
 * - Database connectivity and performance
 * - Application status and metrics
 * - System resources and JVM info
 * - Integration endpoints for frontend
 */
@RestController
public class HealthController {

    @Autowired
    private DataSource dataSource;
    
    @Autowired
    private Environment env;

    /**
     * Root health endpoint for simple frontend checks
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> rootHealth() {
        return health();
    }

    /**
     * Main health endpoint - Frontend compatible
     */
    @GetMapping("/api/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> healthInfo = new HashMap<>();
        
        try {
            // Basic system info
            healthInfo.put("status", "healthy");
            healthInfo.put("timestamp", LocalDateTime.now().toString());
            healthInfo.put("application", "iTech Backend");
            healthInfo.put("version", "2.0.0");
            healthInfo.put("environment", env.getProperty("spring.profiles.active", "development"));
            healthInfo.put("port", env.getProperty("server.port", "8080"));
            
            // System resources
            Runtime runtime = Runtime.getRuntime();
            Map<String, Object> memory = new HashMap<>();
            memory.put("total", runtime.totalMemory());
            memory.put("free", runtime.freeMemory());
            memory.put("used", runtime.totalMemory() - runtime.freeMemory());
            memory.put("max", runtime.maxMemory());
            healthInfo.put("memory", memory);
            
            // JVM info
            Map<String, Object> jvm = new HashMap<>();
            jvm.put("version", System.getProperty("java.version"));
            jvm.put("vendor", System.getProperty("java.vendor"));
            jvm.put("uptime", java.lang.management.ManagementFactory.getRuntimeMXBean().getUptime());
            healthInfo.put("jvm", jvm);
            
            // Database health
            Map<String, Object> database = checkDatabaseHealth();
            healthInfo.put("database", database);
            
            // Check overall health status
            boolean isHealthy = "healthy".equals(database.get("status"));
            healthInfo.put("status", isHealthy ? "healthy" : "degraded");
            
            return ResponseEntity.ok(healthInfo);
            
        } catch (Exception e) {
            healthInfo.put("status", "unhealthy");
            healthInfo.put("error", e.getMessage());
            healthInfo.put("timestamp", LocalDateTime.now().toString());
            
            return ResponseEntity.status(503).body(healthInfo);
        }
    }

    /**
     * API status endpoint for backend status
     */
    @GetMapping("/api/status")
    public ResponseEntity<Map<String, Object>> apiStatus() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Test database connection
            Connection connection = dataSource.getConnection();
            boolean isValid = connection.isValid(5);
            connection.close();
            
            response.put("status", "UP");
            response.put("database", isValid ? "UP" : "DOWN");
            response.put("profiles", env.getActiveProfiles());
            response.put("port", env.getProperty("server.port"));
            response.put("app", "itech-backend");
            
        } catch (Exception e) {
            response.put("status", "DOWN");
            response.put("database", "DOWN");
            response.put("error", e.getMessage());
            response.put("profiles", env.getActiveProfiles());
            response.put("port", env.getProperty("server.port"));
            response.put("app", "itech-backend");
        }
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/db")
    public ResponseEntity<Map<String, Object>> databaseHealth() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Connection connection = dataSource.getConnection();
            boolean isValid = connection.isValid(5);
            
            response.put("database", isValid ? "UP" : "DOWN");
            response.put("url", env.getProperty("spring.datasource.url"));
            response.put("username", env.getProperty("spring.datasource.username"));
            response.put("driver", env.getProperty("spring.datasource.driver-class-name"));
            
            connection.close();
            
        } catch (Exception e) {
            response.put("database", "DOWN");
            response.put("error", e.getMessage());
            response.put("url", env.getProperty("spring.datasource.url"));
            response.put("username", env.getProperty("spring.datasource.username"));
            response.put("driver", env.getProperty("spring.datasource.driver-class-name"));
        }
        
        return ResponseEntity.ok(response);
    }

    /**
     * Additional health endpoints for monitoring
     */
    @GetMapping("/health/ready")
    public ResponseEntity<Map<String, String>> ready() {
        try {
            // Quick database connectivity check
            try (Connection connection = dataSource.getConnection()) {
                if (connection.isValid(5)) {
                    return ResponseEntity.ok(Map.of(
                        "status", "ready",
                        "timestamp", LocalDateTime.now().toString()
                    ));
                }
            }
            
            return ResponseEntity.status(503).body(Map.of(
                "status", "not ready",
                "reason", "Database connection failed",
                "timestamp", LocalDateTime.now().toString()
            ));
            
        } catch (Exception e) {
            return ResponseEntity.status(503).body(Map.of(
                "status", "not ready",
                "reason", e.getMessage(),
                "timestamp", LocalDateTime.now().toString()
            ));
        }
    }

    @GetMapping("/health/alive")
    public ResponseEntity<Map<String, String>> alive() {
        return ResponseEntity.ok(Map.of(
            "status", "alive",
            "timestamp", LocalDateTime.now().toString(),
            "uptime", String.valueOf(java.lang.management.ManagementFactory.getRuntimeMXBean().getUptime())
        ));
    }

    /**
     * Check database connectivity and performance
     */
    private Map<String, Object> checkDatabaseHealth() {
        Map<String, Object> dbHealth = new HashMap<>();
        
        try {
            long startTime = System.currentTimeMillis();
            
            try (Connection connection = dataSource.getConnection()) {
                boolean isValid = connection.isValid(5); // 5 second timeout
                long responseTime = System.currentTimeMillis() - startTime;
                
                if (isValid) {
                    dbHealth.put("status", "healthy");
                    dbHealth.put("responseTime", responseTime + "ms");
                    dbHealth.put("driver", connection.getMetaData().getDriverName());
                    dbHealth.put("url", connection.getMetaData().getURL());
                    dbHealth.put("autoCommit", connection.getAutoCommit());
                } else {
                    dbHealth.put("status", "unhealthy");
                    dbHealth.put("error", "Connection validation failed");
                    dbHealth.put("responseTime", responseTime + "ms");
                }
            }
            
        } catch (Exception e) {
            dbHealth.put("status", "unhealthy");
            dbHealth.put("error", e.getMessage());
            dbHealth.put("errorType", e.getClass().getSimpleName());
        }
        
        return dbHealth;
    }
}
