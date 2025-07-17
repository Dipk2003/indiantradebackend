package com.itech.itech_backend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.env.Environment;

import javax.sql.DataSource;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.net.URI;
import java.net.URISyntaxException;

@Configuration
public class DatabaseConfig {

    private final Environment env;

    public DatabaseConfig(Environment env) {
        this.env = env;
    }

    @Bean
    @Primary
    @ConfigurationProperties("spring.datasource.hikari")
    public DataSource dataSource() {
        String databaseUrl = env.getProperty("DATABASE_URL");
        
        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            // Parse DATABASE_URL for Render/Heroku style URLs
            return createDataSourceFromUrl(databaseUrl);
        } else {
            // Use standard Spring Boot configuration
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(env.getProperty("spring.datasource.url"));
            config.setUsername(env.getProperty("spring.datasource.username"));
            config.setPassword(env.getProperty("spring.datasource.password"));
            config.setDriverClassName(env.getProperty("spring.datasource.driver-class-name"));
            
            // Connection pool settings
            config.setMaximumPoolSize(20);
            config.setMinimumIdle(5);
            config.setConnectionTimeout(60000);
            config.setIdleTimeout(300000);
            config.setMaxLifetime(900000);
            
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
                jdbcUrl = String.format("jdbc:postgresql://%s:%d%s", host, port, path);
                driverClassName = "org.postgresql.Driver";
            } else if ("mysql".equals(scheme)) {
                jdbcUrl = String.format("jdbc:mysql://%s:%d%s", host, port, path);
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
