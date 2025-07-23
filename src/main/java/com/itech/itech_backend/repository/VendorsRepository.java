package com.itech.itech_backend.repository;

import com.itech.itech_backend.model.Vendors;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VendorsRepository extends JpaRepository<Vendors, Long> {
    Optional<Vendors> findByEmail(String email);
    Optional<Vendors> findByPhone(String phone);
    Optional<Vendors> findByEmailOrPhone(String email, String phone);
    boolean existsByEmail(String email);
    boolean existsByPhone(String phone);
    Optional<Vendors> findByGstNumber(String gstNumber);
    Optional<Vendors> findByPanNumber(String panNumber);
    
    // City-based queries
    List<Vendors> findByCityIgnoreCase(String city);
    List<Vendors> findByStateIgnoreCase(String state);
    List<Vendors> findByCityIgnoreCaseAndVerifiedTrue(String city);
    List<Vendors> findByStateIgnoreCaseAndVerifiedTrue(String state);
    
    @Query("SELECT DISTINCT v.city FROM Vendors v WHERE v.city IS NOT NULL ORDER BY v.city")
    List<String> findAllDistinctCities();
    
    @Query("SELECT DISTINCT v.state FROM Vendors v WHERE v.state IS NOT NULL ORDER BY v.state")
    List<String> findAllDistinctStates();
    
    @Query("SELECT COUNT(v) FROM Vendors v WHERE v.city = :city AND v.verified = true")
    Long countVerifiedVendorsByCity(@Param("city") String city);
}
