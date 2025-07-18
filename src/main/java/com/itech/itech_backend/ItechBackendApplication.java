package com.itech.itech_backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories(basePackages = "com.itech.itech_backend.repository")
public class ItechBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(ItechBackendApplication.class, args);
	}

}
