package com.itech.itech_backend.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
public class HealthCheckController {

    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", LocalDateTime.now());
        response.put("message", "iTech Backend is running successfully!");
        return response;
    }

    @GetMapping("/")
    public Map<String, Object> root() {
        Map<String, Object> response = new HashMap<>();
        response.put("application", "iTech Backend");
        response.put("version", "1.0.0");
        response.put("status", "Running");
        response.put("timestamp", LocalDateTime.now());
        return response;
    }
}
