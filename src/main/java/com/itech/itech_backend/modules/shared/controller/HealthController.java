package com.itech.itech_backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/health")
public class HealthController {

    @Autowired
    private DataSource dataSource;
    
    @Autowired
    private Environment env;

    @GetMapping
    public ResponseEntity<Map<String, Object>> health() {
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
}
