package com.itech.itech_backend.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;

import javax.sql.DataSource;

@Configuration
@Profile("render")
public class RenderDataSourceConfig {

    private static final Logger logger = LoggerFactory.getLogger(RenderDataSourceConfig.class);
    
    private final Environment env;

    public RenderDataSourceConfig(Environment env) {
        this.env = env;
    }

    @Bean
    @Primary
    public DataSource dataSource() {
        logger.info("Configuring DataSource for Render deployment");
        
        String jdbcUrl = env.getProperty("JDBC_DATABASE_URL");
        String username = env.getProperty("JDBC_DATABASE_USERNAME");
        String password = env.getProperty("JDBC_DATABASE_PASSWORD");
        
        // Validate required properties
        if (jdbcUrl == null || username == null || password == null) {
            throw new IllegalStateException("Missing required database environment variables");
        }
        
        // Ensure SSL is configured for PostgreSQL
        if (jdbcUrl.contains("postgresql") && !jdbcUrl.contains("sslmode=")) {
            jdbcUrl = jdbcUrl + (jdbcUrl.contains("?") ? "&" : "?") + "sslmode=require";
        }
        
        logger.info("Database URL: {}", jdbcUrl.replaceAll("password=[^&]*", "password=***"));
        logger.info("Database Username: {}", username);
        
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(jdbcUrl);
        config.setUsername(username);
        config.setPassword(password);
        config.setDriverClassName("org.postgresql.Driver");
        
        // Optimized connection pool settings for Render free tier
        config.setMaximumPoolSize(3);
        config.setMinimumIdle(1);
        config.setConnectionTimeout(30000);
        config.setValidationTimeout(5000);
        config.setIdleTimeout(300000);
        config.setMaxLifetime(1800000);
        config.setLeakDetectionThreshold(60000);
        config.setConnectionTestQuery("SELECT 1");
        config.setPoolName("RenderHikariCP");
        
        // Additional stability settings
        config.addDataSourceProperty("ApplicationName", "itech-backend");
        config.addDataSourceProperty("stringtype", "unspecified");
        
        logger.info("HikariCP configuration completed successfully");
        return new HikariDataSource(config);
    }
}
