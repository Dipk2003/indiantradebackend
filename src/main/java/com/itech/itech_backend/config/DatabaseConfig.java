package com.itech.itech_backend.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;

import javax.sql.DataSource;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.net.URI;
import java.net.URISyntaxException;

@Configuration
@Profile("!render")
public class DatabaseConfig {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseConfig.class);
    private final Environment env;

    public DatabaseConfig(Environment env) {
        this.env = env;
    }

    @Bean
    @Primary
    public DataSource dataSource() {
        String databaseUrl = env.getProperty("DATABASE_URL");
        
        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            logger.info("Configuring DataSource from DATABASE_URL");
            // Parse DATABASE_URL for Render/Heroku style URLs
            return createDataSourceFromUrl(databaseUrl);
        } else {
            logger.info("Configuring DataSource from individual properties");
            // Use standard Spring Boot configuration
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(env.getProperty("spring.datasource.url"));
            config.setUsername(env.getProperty("spring.datasource.username"));
            config.setPassword(env.getProperty("spring.datasource.password"));
            config.setDriverClassName(env.getProperty("spring.datasource.driver-class-name"));
            
            // Connection pool settings - reduced for stability
            config.setMaximumPoolSize(5);
            config.setMinimumIdle(2);
            config.setConnectionTimeout(30000);
            config.setIdleTimeout(300000);
            config.setMaxLifetime(600000);
            
            return new HikariDataSource(config);
        }
    }

    private DataSource createDataSourceFromUrl(String databaseUrl) {
        try {
            URI uri = new URI(databaseUrl);
            String scheme = uri.getScheme();
            String host = uri.getHost();
            int port = uri.getPort();
            String path = uri.getPath();
            String userInfo = uri.getUserInfo();
            
            String username = "";
            String password = "";
            
            if (userInfo != null) {
                String[] credentials = userInfo.split(":");
                username = credentials[0];
                if (credentials.length > 1) {
                    password = credentials[1];
                }
            }
            
            String jdbcUrl;
            String driverClassName;
            
            if ("postgres".equals(scheme) || "postgresql".equals(scheme)) {
                // Use default PostgreSQL port 5432 if not specified
                int actualPort = port != -1 ? port : 5432;
                jdbcUrl = String.format("jdbc:postgresql://%s:%d%s?sslmode=require", host, actualPort, path);
                driverClassName = "org.postgresql.Driver";
            } else if ("mysql".equals(scheme)) {
                // Use default MySQL port 3306 if not specified
                int actualPort = port != -1 ? port : 3306;
                jdbcUrl = String.format("jdbc:mysql://%s:%d%s", host, actualPort, path);
                driverClassName = "com.mysql.cj.jdbc.Driver";
            } else {
                throw new IllegalArgumentException("Unsupported database scheme: " + scheme);
            }
            
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(jdbcUrl);
            config.setUsername(username);
            config.setPassword(password);
            config.setDriverClassName(driverClassName);
            
            // Connection pool settings
            config.setMaximumPoolSize(20);
            config.setMinimumIdle(5);
            config.setConnectionTimeout(60000);
            config.setIdleTimeout(300000);
            config.setMaxLifetime(900000);
            
            return new HikariDataSource(config);
            
        } catch (URISyntaxException e) {
            throw new RuntimeException("Invalid DATABASE_URL format", e);
        }
    }
}
