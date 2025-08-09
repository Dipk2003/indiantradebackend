package com.itech.itech_backend.repository;

import com.itech.itech_backend.model.Banner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BannerRepository extends JpaRepository<Banner, Long> {
    List<Banner> findByIsActiveTrueOrderByDisplayOrder();
    List<Banner> findByPositionAndIsActiveTrueOrderByDisplayOrder(String position);
}
