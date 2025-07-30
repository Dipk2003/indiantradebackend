package com.itech.itech_backend.repository;

import com.itech.itech_backend.model.Category;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CategoryRepository extends JpaRepository<Category, Long> {
    boolean existsByName(String name);
    Optional<Category> findByName(String name);
    
    Page<Category> findByNameContainingIgnoreCaseOrDescriptionContainingIgnoreCase(
        String name, String description, Pageable pageable);
    
    List<Category> findByIsActiveTrue();
    
    Page<Category> findByIsActive(boolean isActive, Pageable pageable);
    
    @Query("SELECT c FROM Category c ORDER BY c.displayOrder ASC, c.name ASC")
    List<Category> findAllOrderByDisplayOrder();
    
    @Query("SELECT COUNT(sc) FROM SubCategory sc WHERE sc.category.id = :categoryId")
    long countSubCategoriesByCategoryId(@Param("categoryId") Long categoryId);
    
    @Query("SELECT COUNT(p) FROM Product p JOIN p.microCategory mc JOIN mc.subCategory sc WHERE sc.category.id = :categoryId")
    long countProductsByCategoryId(@Param("categoryId") Long categoryId);
    
    @Query("SELECT c FROM Category c WHERE c.isActive = true ORDER BY c.displayOrder ASC, c.name ASC")
    List<Category> findAllActive();
}
