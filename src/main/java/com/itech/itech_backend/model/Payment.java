package com.itech.itech_backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "payments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "vendor_id", nullable = false)
    private Vendors vendor;

    @ManyToOne
    @JoinColumn(name = "subscription_plan_id", nullable = false)
    private SubscriptionPlan subscriptionPlan;

    @Column(nullable = false)
    private BigDecimal amount;

    @Column(nullable = false)
    private String paymentStatus; // PENDING, PAID, FAILED, REFUNDED

    private String razorpayPaymentId;
    private String razorpayOrderId;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
