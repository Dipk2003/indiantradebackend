package com.itech.itech_backend.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.properties.ConfigurationProperties;
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
    @ConfigurationProperties("spring.datasource.hikari")
    public DataSource dataSource() {
        logger.info("Configuring DataSource for Render deployment");
        
        String jdbcUrl = env.getProperty("JDBC_DATABASE_URL");
        String username = env.getProperty("JDBC_DATABASE_USERNAME");
        String password = env.getProperty("JDBC_DATABASE_PASSWORD");
        
        // Ensure SSL is configured
        if (jdbcUrl != null && !jdbcUrl.contains("sslmode=")) {
            jdbcUrl = jdbcUrl + (jdbcUrl.contains("?") ? "&" : "?") + "sslmode=require";
        }
        
        logger.info("Database URL: {}", jdbcUrl);
        logger.info("Database Username: {}", username);
        
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(jdbcUrl);
        config.setUsername(username);
        config.setPassword(password);
        config.setDriverClassName("org.postgresql.Driver");
        
        // Connection pool settings optimized for Render
        config.setMaximumPoolSize(3);
        config.setMinimumIdle(1);
        config.setConnectionTimeout(30000);
        config.setValidationTimeout(5000);
        config.setIdleTimeout(300000);
        config.setMaxLifetime(1800000);
        config.setLeakDetectionThreshold(60000);
        config.setConnectionTestQuery("SELECT 1");
        config.setConnectionInitSql("SELECT 1");
        config.setPoolName("RenderHikariCP");
        
        return new HikariDataSource(config);
    }
}
