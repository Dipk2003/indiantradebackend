package com.itech.itech_backend.modules.buyer.service;

import com.itech.itech_backend.modules.buyer.model.Category;
import com.itech.itech_backend.modules.buyer.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepo;

@Transactional
    public Category addCategory(String name) {
        if (!categoryRepo.existsByName(name)) {
            return categoryRepo.save(Category.builder().name(name).build());
        }
        return null; // Already exists
    }

@Cacheable("categories")
    public List<Category> getAllCategories() {
        return categoryRepo.findAll();
    }
}

