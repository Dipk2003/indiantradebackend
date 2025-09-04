package com.itech.itech_backend.config;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.test.context.TestPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.containers.RedisContainer;
import org.testcontainers.utility.DockerImageName;

@TestConfiguration
@TestPropertySource(locations = "classpath:application-test.properties")
public class IntegrationTestConfig {

    @Bean(initMethod = "start", destroyMethod = "stop")
    public PostgreSQLContainer<?> postgreSQLContainer() {
        return new PostgreSQLContainer<>(DockerImageName.parse("postgres:13"))
                .withDatabaseName("testdb")
                .withUsername("test")
                .withPassword("test");
    }

    @Bean(initMethod = "start", destroyMethod = "stop")
    public RedisContainer redisContainer() {
        return new RedisContainer(DockerImageName.parse("redis:6"));
    }

    @Bean
    public TestRestTemplate testRestTemplate(RestTemplateBuilder builder) {
        return new TestRestTemplate(builder);
    }
}
