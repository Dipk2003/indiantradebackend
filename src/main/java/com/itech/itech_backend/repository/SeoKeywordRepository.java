package com.itech.itech_backend.repository;

import com.itech.itech_backend.model.SeoKeyword;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SeoKeywordRepository extends JpaRepository<SeoKeyword, Long> {
    List<SeoKeyword> findByTargetPageAndIsActiveTrue(String targetPage);
    List<SeoKeyword> findByTargetPageAndTargetIdAndIsActiveTrue(String targetPage, Long targetId);
}
