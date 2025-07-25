package com.itech.itech_backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateMicroCategoryDto {
    
    @NotBlank(message = "MicroCategory name is required")
    @Size(max = 255, message = "MicroCategory name must not exceed 255 characters")
    private String name;
    
    @Size(max = 1000, message = "Description must not exceed 1000 characters")
    private String description;
    
    private int displayOrder;
    
    private boolean isActive;
    
    @Size(max = 255, message = "Meta title must not exceed 255 characters")
    private String metaTitle;
    
    @Size(max = 500, message = "Meta description must not exceed 500 characters")
    private String metaDescription;
    
    @Size(max = 255, message = "Slug must not exceed 255 characters")
    private String slug;
    
    @NotNull(message = "SubCategory ID is required")
    private Long subCategoryId;
}
