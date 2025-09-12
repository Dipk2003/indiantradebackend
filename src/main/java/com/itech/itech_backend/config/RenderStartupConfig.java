package com.itech.itech_backend.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import lombok.extern.slf4j.Slf4j;

/**
 * Render-specific startup configuration to optimize boot time and memory usage
 */
@Slf4j
@Configuration
@Profile("render")
@ConditionalOnProperty(value = "spring.profiles.active", havingValue = "render")
public class RenderStartupConfig {

    @EventListener(ApplicationReadyEvent.class)
    public void onApplicationReady(ApplicationReadyEvent event) {
        log.info("🚀 Indian Trade Mart Backend successfully started on Render!");
        log.info("💾 Memory usage optimized for 512MB limit");
        log.info("🌐 Service is ready to accept connections on port 10000");
        
        // Force garbage collection to free up startup memory
        System.gc();
        
        // Log memory usage
        Runtime runtime = Runtime.getRuntime();
        long maxMemory = runtime.maxMemory() / 1024 / 1024;
        long totalMemory = runtime.totalMemory() / 1024 / 1024;
        long freeMemory = runtime.freeMemory() / 1024 / 1024;
        long usedMemory = totalMemory - freeMemory;
        
        log.info("📊 Memory Status - Max: {}MB, Used: {}MB, Free: {}MB", 
                maxMemory, usedMemory, freeMemory);
    }
}
