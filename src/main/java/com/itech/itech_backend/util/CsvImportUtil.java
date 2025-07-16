package com.itech.itech_backend.util;

import com.itech.itech_backend.dto.ProductDto;
import com.itech.itech_backend.model.Category;
import com.itech.itech_backend.model.Product;
import com.itech.itech_backend.model.User;
import com.itech.itech_backend.repository.CategoryRepository;
import com.itech.itech_backend.service.ProductService;
import com.itech.itech_backend.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
@Slf4j
public class CsvImportUtil {

    private final ProductService productService;
    private final CategoryRepository categoryRepository;
    private final UserService userService;

    @Transactional
    public List<Product> importProductsFromCsvData(String csvData, Long vendorId) {
        List<Product> createdProducts = new ArrayList<>();
        
        try {
            // Validate vendor exists
            User vendor = userService.getUserById(vendorId)
                    .orElseThrow(() -> new RuntimeException("Vendor not found with ID: " + vendorId));

            String[] lines = csvData.split("\n");
            
            // Skip header row
            for (int i = 1; i < lines.length; i++) {
                String line = lines[i].trim();
                if (line.isEmpty()) continue;
                
                try {
                    Product product = processLine(line, vendor, i + 1);
                    if (product != null) {
                        createdProducts.add(product);
                        log.info("Successfully imported product: {} (Row {})", product.getName(), i + 1);
                    }
                } catch (Exception e) {
                    log.error("Failed to import product at row {}: {}", i + 1, e.getMessage());
                }
            }
            
            log.info("Successfully imported {} products for vendor {}", createdProducts.size(), vendorId);
            return createdProducts;
            
        } catch (Exception e) {
            log.error("Error importing CSV data for vendor {}: {}", vendorId, e.getMessage());
            throw new RuntimeException("Failed to import CSV data: " + e.getMessage());
        }
    }

    private Product processLine(String line, User vendor, int rowNumber) {
        String[] columns = parseCsvLine(line);
        
        if (columns.length < 6) {
            throw new RuntimeException("Invalid CSV format at row " + rowNumber + ". Expected 6 columns.");
        }
        
        // Expected columns: category,subcategory,miner category,product/services,description,price
        String category = columns[0].trim();
        String subcategory = columns[1].trim();
        String minorCategory = columns[2].trim();
        String productName = columns[3].trim();
        String description = columns[4].trim();
        String priceStr = columns[5].trim();
        
        // Validate required fields
        if (category.isEmpty() || productName.isEmpty() || priceStr.isEmpty()) {
            throw new RuntimeException("Missing required fields (category, product name, price) at row " + rowNumber);
        }
        
        // Parse price
        BigDecimal price;
        try {
            // Remove currency symbols and commas
            priceStr = priceStr.replaceAll("[₹$,]", "");
            price = new BigDecimal(priceStr);
        } catch (NumberFormatException e) {
            throw new RuntimeException("Invalid price format at row " + rowNumber + ": " + priceStr);
        }
        
        // Find or create category
        Category categoryEntity = findOrCreateCategory(category, subcategory);
        
        // Create product DTO
        ProductDto productDto = ProductDto.builder()
                .name(productName)
                .description(description.isEmpty() ? productName : description)
                .price(price.doubleValue())
                .categoryId(categoryEntity.getId())
                .vendorId(vendor.getId())
                .minOrderQuantity(1)
                .unit("piece")
                .gstRate(18.0)
                .freeShipping(false)
                .isActive(true)
                .specifications(minorCategory.isEmpty() ? null : "Minor Category: " + minorCategory)
                .build();
        
        // Create product
        return productService.addProduct(productDto);
    }

    private Category findOrCreateCategory(String categoryName, String subcategoryName) {
        // Try to find existing category
        Optional<Category> existingCategory = categoryRepository.findByName(categoryName);
        
        if (existingCategory.isPresent()) {
            return existingCategory.get();
        }

        // Create new category
        Category category = new Category();
        category.setName(categoryName);
        // You can add subcategory logic here if needed
        
        return categoryRepository.save(category);
    }

    private String[] parseCsvLine(String line) {
        List<String> result = new ArrayList<>();
        boolean inQuotes = false;
        StringBuilder currentField = new StringBuilder();
        
        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            
            if (c == '"') {
                inQuotes = !inQuotes;
            } else if (c == ',' && !inQuotes) {
                result.add(currentField.toString());
                currentField = new StringBuilder();
            } else {
                currentField.append(c);
            }
        }
        
        result.add(currentField.toString());
        return result.toArray(new String[0]);
    }
}
