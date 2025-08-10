package com.itech.itech_backend.modules.core.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "\"user\"")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(unique = true)
    private String phone;
    
    @Column(length = 500)
    private String address;
    
    private String city;
    
    private String state;
    
    private String pincode;
    
    private String country;
    
    @Column(nullable = false)
    private String password;

    @Builder.Default
    private boolean verified = false;
    
    @Column(name = "is_verified")
    @Builder.Default
    private boolean isVerified = false;
    
    public boolean isVerified() {
        return isVerified;
    }
    
    public void setVerified(boolean verified) {
        this.verified = verified;
        this.isVerified = verified;
    }
    
    public void setIsVerified(boolean isVerified) {
        this.isVerified = isVerified;
        this.verified = isVerified;
    }

    @Builder.Default
    private String role = "ROLE_USER";
    
    @Builder.Default
    private boolean isActive = true;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}

