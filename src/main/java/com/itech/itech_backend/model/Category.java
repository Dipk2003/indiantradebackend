package com.itech.itech_backend.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    
    private String description;
    
    @Builder.Default
    private int displayOrder = 0;
    
    @Builder.Default
    private boolean isActive = true;
    
    private String metaTitle;
    
    private String metaDescription;
    
    private String slug;
}
