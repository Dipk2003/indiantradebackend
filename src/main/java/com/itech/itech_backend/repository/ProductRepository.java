package com.itech.itech_backend.repository;

import com.itech.itech_backend.model.Product;
import com.itech.itech_backend.model.Vendors;
import com.itech.itech_backend.model.MicroCategory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Long> {
    // Basic finders
    List<Product> findByVendor(Vendors vendor);
    Page<Product> findByIsActiveTrue(Pageable pageable);
    @Query("SELECT p FROM Product p WHERE p.stock > 0")
    Page<Product> findByInStockTrue(Pageable pageable);
    
    // Count methods
    long countByIsActiveTrue();
    @Query("SELECT COUNT(p) FROM Product p WHERE p.stock > 0")
    long countByInStockTrue();
    Long countByMicroCategory(MicroCategory microCategory);
    
    // Additional analytics methods
    long countByIsApprovedTrue();
    long countByVendorId(Long vendorId);
    long countByVendorIdAndIsActiveTrue(Long vendorId);
    @Query("SELECT p FROM Product p WHERE p.vendor.id = :vendorId ORDER BY p.createdAt DESC")
    List<Product> findTop10ByVendorIdOrderByCreatedAtDesc(@Param("vendorId") Long vendorId);
    
    // Category-based finders
    @Query("SELECT p FROM Product p WHERE p.microCategory.id = :microCategoryId")
    Page<Product> findByMicroCategoryId(@Param("microCategoryId") Long microCategoryId, Pageable pageable);
    
    @Query("SELECT p FROM Product p JOIN p.microCategory mc JOIN mc.subCategory sc WHERE sc.category.id = :categoryId")
    Page<Product> findByCategoryId(@Param("categoryId") Long categoryId, Pageable pageable);
    
    @Query("SELECT p FROM Product p WHERE p.vendor.id = :vendorId")
    Page<Product> findByVendorId(@Param("vendorId") Long vendorId, Pageable pageable);
    
    // Count queries
    @Query("SELECT COUNT(p) FROM Product p WHERE p.microCategory.id = :microCategoryId")
    Long countByMicroCategoryId(@Param("microCategoryId") Long microCategoryId);
    
    @Query("SELECT COUNT(p) FROM Product p LEFT JOIN p.microCategory mc LEFT JOIN mc.subCategory sc WHERE p.category.id = :categoryId OR sc.category.id = :categoryId")
    long countByCategoryId(@Param("categoryId") Long categoryId);
    
    @Query("SELECT COUNT(p) FROM Product p LEFT JOIN p.microCategory mc LEFT JOIN mc.subCategory sc WHERE (p.category.id = :categoryId OR sc.category.id = :categoryId) AND p.isActive = true")
    long countByIsActiveTrueAndCategoryId(@Param("categoryId") Long categoryId);
    
    long countByUpdatedAtAfter(LocalDateTime updatedAt);
    long countByCreatedAtAfter(LocalDateTime createdAt);
    
    // Special queries
    @Query("SELECT p FROM Product p WHERE p.isApproved = false ORDER BY p.createdAt DESC")
    Page<Product> findPendingApproval(Pageable pageable);
    
    @Query("SELECT p FROM Product p WHERE p.isFeatured = true AND p.isApproved = true AND p.isActive = true")
    Page<Product> findFeaturedProducts(Pageable pageable);
    
    @Query("SELECT p FROM Product p ORDER BY p.createdAt DESC")
    Page<Product> findRecentProducts(Pageable pageable);
    
    @Query("SELECT p FROM Product p WHERE p.name LIKE %:search% OR p.description LIKE %:search%")
    Page<Product> findByNameContainingOrDescriptionContaining(@Param("search") String search, Pageable pageable);
    
    @Query("SELECT p FROM Product p WHERE " +
            "(:category IS NULL OR p.microCategory.subCategory.category.name LIKE %:category%) AND " +
            "(:subCategory IS NULL OR p.microCategory.subCategory.name LIKE %:subCategory%) AND " +
            "(:microCategory IS NULL OR p.microCategory.name LIKE %:microCategory%) AND " +
            "(:minPrice IS NULL OR p.price >= :minPrice) AND " +
            "(:maxPrice IS NULL OR p.price <= :maxPrice)")
    List<Product> findByVariousFilters(@Param("category") String category,
                             @Param("subCategory") String subCategory,
                             @Param("microCategory") String microCategory,
                             @Param("minPrice") Double minPrice,
                             @Param("maxPrice") Double maxPrice,
                             @Param("location") String location);
    
    // Enhanced search method
    @Query("SELECT p FROM Product p WHERE " +
            "(:query IS NULL OR p.name ILIKE %:query% OR p.description ILIKE %:query%) AND " +
            "(:categoryId IS NULL OR p.microCategory.subCategory.category.id = :categoryId) AND " +
            "(:subcategoryId IS NULL OR p.microCategory.subCategory.id = :subcategoryId) AND " +
            "(:microcategoryId IS NULL OR p.microCategory.id = :microcategoryId) AND " +
            "(:city IS NULL OR p.vendor.city ILIKE %:city%) AND " +
            "(:state IS NULL OR p.vendor.state ILIKE %:state%) AND " +
            "(:minPrice IS NULL OR p.price >= :minPrice) AND " +
            "(:maxPrice IS NULL OR p.price <= :maxPrice) AND " +
            "(:vendorId IS NULL OR p.vendor.id = :vendorId) AND " +
            "(:isActive IS NULL OR p.isActive = :isActive)")
    Page<Product> searchProducts(@Param("query") String query,
                               @Param("categoryId") Long categoryId,
                               @Param("subcategoryId") Long subcategoryId,
                               @Param("microcategoryId") Long microcategoryId,
                               @Param("city") String city,
                               @Param("state") String state,
                               @Param("minPrice") Double minPrice,
                               @Param("maxPrice") Double maxPrice,
                               @Param("vendorId") Long vendorId,
                               @Param("isActive") Boolean isActive,
                               Pageable pageable);
    
    // Featured products
    @Query("SELECT p FROM Product p WHERE p.isFeatured = true AND p.isApproved = true AND p.isActive = true ORDER BY p.createdAt DESC")
    Page<Product> findTopFeaturedProducts(Pageable pageable);
    
    // Recent products
    @Query("SELECT p FROM Product p WHERE p.isApproved = true AND p.isActive = true ORDER BY p.createdAt DESC")
    Page<Product> findTopRecentProducts(Pageable pageable);
    
    // Search suggestions
    @Query("SELECT DISTINCT p.name FROM Product p WHERE p.name ILIKE %:query% AND p.isActive = true")
    List<String> findDistinctByNameContainingIgnoreCase(@Param("query") String query, Pageable pageable);
    
    // Additional methods for OpenAI integration
    List<Product> findByNameContainingIgnoreCase(String name);
    
    @Query("SELECT p FROM Product p WHERE p.isActive = true ORDER BY p.orderCount DESC")
    List<Product> findTopRatedProducts(Pageable pageable);
    
    // Additional methods for enhanced search
    @Query("SELECT MIN(p.price), MAX(p.price) FROM Product p WHERE p.isActive = true")
    Object[] findPriceRange();
    
    @Query("SELECT DISTINCT p.brand FROM Product p WHERE p.brand IS NOT NULL AND p.isActive = true ORDER BY p.brand")
    List<String> findDistinctBrands();
    
    Page<Product> findByIsActiveTrueAndIsApprovedTrue(Pageable pageable);
    
    Page<Product> findByCategoryIdAndIdNotAndIsActiveTrueAndIsApprovedTrue(
        Long categoryId, Long excludeId, Pageable pageable);
    
    Page<Product> findByVendorIdAndIdNotAndIsActiveTrueAndIsApprovedTrue(
        Long vendorId, Long excludeId, Pageable pageable);
}
