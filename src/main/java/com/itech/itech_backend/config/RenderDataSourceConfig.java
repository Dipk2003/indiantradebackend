package com.itech.itech_backend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;

import javax.sql.DataSource;

/**
 * DataSource configuration specifically for Render deployment
 * This ensures proper PostgreSQL connection handling
 */
@Configuration
@Profile("render")
public class RenderDataSourceConfig {

    /**
     * Primary DataSource for Render PostgreSQL
     * Uses environment variables set by Render
     */
    @Bean
    @Primary
    @ConfigurationProperties(prefix = "spring.datasource")
    public DataSource dataSource() {
        return DataSourceBuilder.create()
                .driverClassName("org.postgresql.Driver")
                .build();
    }
}
