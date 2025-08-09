package com.itech.itech_backend.repository;

import com.itech.itech_backend.model.SystemMetrics;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SystemMetricsRepository extends JpaRepository<SystemMetrics, Long> {
}
