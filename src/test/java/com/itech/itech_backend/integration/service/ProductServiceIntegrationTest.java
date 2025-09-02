package com.itech.itech_backend.integration.service;

import com.itech.itech_backend.integration.IntegrationTestBase;
import com.itech.itech_backend.modules.product.model.Product;
import com.itech.itech_backend.modules.product.repository.ProductRepository;
import com.itech.itech_backend.modules.product.service.ProductService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.*;

class ProductServiceIntegrationTest extends IntegrationTestBase {

    @Autowired
    private ProductService productService;

    @Autowired
    private ProductRepository productRepository;

    @Test
    void shouldCreateProduct() {
        // given
        Product product = createTestProduct();

        // when
        Product savedProduct = productService.createProduct(product);

        // then
        assertNotNull(savedProduct.getId());
        assertEquals(product.getName(), savedProduct.getName());
        assertEquals(product.getPrice(), savedProduct.getPrice());
        assertEquals(product.getDescription(), savedProduct.getDescription());
    }

    @Test
    void shouldUpdateProduct() {
        // given
        Product product = productService.createProduct(createTestProduct());
        String updatedName = "Updated Product";
        BigDecimal updatedPrice = new BigDecimal("199.99");
        
        product.setName(updatedName);
        product.setPrice(updatedPrice);

        // when
        Product updatedProduct = productService.updateProduct(product.getId(), product);

        // then
        assertEquals(updatedName, updatedProduct.getName());
        assertEquals(updatedPrice, updatedProduct.getPrice());
    }

    @Test
    void shouldDeleteProduct() {
        // given
        Product product = productService.createProduct(createTestProduct());

        // when
        productService.deleteProduct(product.getId());

        // then
        Optional<Product> deletedProduct = productRepository.findById(product.getId());
        assertTrue(deletedProduct.isEmpty());
    }

    @Test
    void shouldFindProductsByCategory() {
        // given
        String category = "Electronics";
        createTestProductsWithCategory(category, 3);

        // when
        Page<Product> products = productService.findByCategory(
            category, PageRequest.of(0, 10)
        );

        // then
        assertThat(products.getContent())
            .hasSize(3)
            .allMatch(p -> p.getCategory().equals(category));
    }

    @Test
    void shouldSearchProducts() {
        // given
        String searchTerm = "iphone";
        createTestProductsWithName(searchTerm, 2);

        // when
        List<Product> products = productService.searchProducts(searchTerm);

        // then
        assertThat(products)
            .hasSize(2)
            .allMatch(p -> p.getName().toLowerCase().contains(searchTerm));
    }

    @Test
    void shouldFindProductsByPriceRange() {
        // given
        BigDecimal minPrice = new BigDecimal("100");
        BigDecimal maxPrice = new BigDecimal("200");
        createTestProductsWithPriceRange(5);

        // when
        List<Product> products = productService.findByPriceRange(minPrice, maxPrice);

        // then
        assertThat(products)
            .allMatch(p -> p.getPrice().compareTo(minPrice) >= 0 
                && p.getPrice().compareTo(maxPrice) <= 0);
    }

    @Test
    void shouldHandleProductNotFound() {
        // given
        String nonExistentId = "non-existent-id";

        // when/then
        assertThrows(
            RuntimeException.class,
            () -> productService.getProduct(nonExistentId)
        );
    }

    @Test
    void shouldValidateProductData() {
        // given
        Product invalidProduct = new Product();

        // when/then
        assertThrows(
            RuntimeException.class,
            () -> productService.createProduct(invalidProduct)
        );
    }

    private Product createTestProduct() {
        Product product = new Product();
        product.setName("Test Product");
        product.setDescription("Test Description");
        product.setPrice(new BigDecimal("99.99"));
        product.setCategory("Test Category");
        product.setStockQuantity(100);
        return product;
    }

    private void createTestProductsWithCategory(String category, int count) {
        for (int i = 0; i < count; i++) {
            Product product = createTestProduct();
            product.setCategory(category);
            productService.createProduct(product);
        }
    }

    private void createTestProductsWithName(String namePart, int count) {
        for (int i = 0; i < count; i++) {
            Product product = createTestProduct();
            product.setName("Test " + namePart + " " + i);
            productService.createProduct(product);
        }
    }

    private void createTestProductsWithPriceRange(int count) {
        for (int i = 0; i < count; i++) {
            Product product = createTestProduct();
            product.setPrice(new BigDecimal(100 + i * 20));
            productService.createProduct(product);
        }
    }
}
