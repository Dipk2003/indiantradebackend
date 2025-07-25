package com.itech.itech_backend.repository;

import com.itech.itech_backend.model.VendorTaxProfile;
import com.itech.itech_backend.model.Vendors;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface VendorTaxProfileRepository extends JpaRepository<VendorTaxProfile, Long> {
    Optional<VendorTaxProfile> findByVendor(Vendors vendor);
}
