package com.itech.itech_backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VerifyForgotPasswordOtpDto {
    private String email;
    private String otp;
    private String newPassword; // Optional - for future password reset functionality
}
