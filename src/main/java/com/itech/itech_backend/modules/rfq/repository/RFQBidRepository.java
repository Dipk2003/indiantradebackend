package com.itech.itech_backend.modules.rfq.repository;

import com.itech.itech_backend.modules.rfq.model.RFQBid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RFQBidRepository extends JpaRepository<RFQBid, Long> {
    
    List<RFQBid> findByRfq_IdOrderByCreatedAtDesc(Long rfqId);
    
    List<RFQBid> findByVendorIdOrderByCreatedAtDesc(String vendorId);
    
    Page<RFQBid> findByVendorId(String vendorId, Pageable pageable);
    
    Page<RFQBid> findByRfq_Id(Long rfqId, Pageable pageable);
    
    @Query("SELECT rb FROM RFQBid rb WHERE rb.rfq.id = :rfqId AND rb.vendorId = :vendorId")
    Optional<RFQBid> findByRfqIdAndVendorId(@Param("rfqId") Long rfqId, 
                                           @Param("vendorId") String vendorId);
    
    @Query("SELECT COUNT(rb) FROM RFQBid rb WHERE rb.rfq.id = :rfqId")
    Long countBidsByRfqId(@Param("rfqId") Long rfqId);
    
    @Query("SELECT rb FROM RFQBid rb WHERE rb.rfq.id = :rfqId AND rb.status = :status " +
           "ORDER BY rb.unitPrice ASC")
    List<RFQBid> findByRfqIdAndStatusOrderByBidAmount(@Param("rfqId") Long rfqId,
                                                     @Param("status") RFQBid.BidStatus status);
    
    @Query("SELECT COUNT(rb) FROM RFQBid rb WHERE rb.vendorId = :vendorId AND rb.status = :status")
    Long countByVendorIdAndStatus(@Param("vendorId") String vendorId, 
                                 @Param("status") RFQBid.BidStatus status);
}
