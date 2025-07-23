package com.itech.itech_backend.controller;

import com.itech.itech_backend.dto.JwtResponse;
import com.itech.itech_backend.dto.LoginRequestDto;
import com.itech.itech_backend.dto.RegisterRequestDto;
import com.itech.itech_backend.dto.SetPasswordDto;
import com.itech.itech_backend.dto.VerifyOtpRequestDto;
import com.itech.itech_backend.dto.ForgotPasswordRequestDto;
import com.itech.itech_backend.dto.VerifyForgotPasswordOtpDto;
import com.itech.itech_backend.service.AuthService;
import com.itech.itech_backend.service.UnifiedAuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@CrossOrigin
@RequiredArgsConstructor
public class AuthController {

    private final UnifiedAuthService unifiedAuthService;
    private final AuthService authService; // Keep for backward compatibility

    // User registration
    @PostMapping("/register")
    public String register(@RequestBody RegisterRequestDto dto) {
        dto.setRole("ROLE_USER");
        dto.setUserType("user");
        return unifiedAuthService.register(dto);
    }
    
    // Vendor registration
    @PostMapping("/vendor/register")
    public String vendorRegister(@RequestBody RegisterRequestDto dto) {
        dto.setRole("ROLE_VENDOR");
        dto.setUserType("vendor");
        return unifiedAuthService.register(dto);
    }
    
    // Admin registration
    @PostMapping("/admin/register")
    public String adminRegister(@RequestBody RegisterRequestDto dto) {
        dto.setRole("ROLE_ADMIN");
        dto.setUserType("admin");
        return unifiedAuthService.register(dto);
    }
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequestDto loginRequest) {
        if (loginRequest.getEmailOrPhone() == null || loginRequest.getPassword() == null) {
            return ResponseEntity.badRequest().body("Email/Phone and Password are required");
        }
        
        try {
            System.out.println("🔐 Login attempt for: " + loginRequest.getEmailOrPhone());
            
            // Try direct login first
            JwtResponse directLogin = unifiedAuthService.directLogin(loginRequest);
            if (directLogin != null) {
                System.out.println("✅ Direct login successful for: " + loginRequest.getEmailOrPhone());
                return ResponseEntity.ok(directLogin);
            }
            
            System.out.println("ℹ️ Direct login failed, trying OTP-based login");
            // If direct login fails, fall back to OTP-based login
            String result = unifiedAuthService.sendLoginOtp(loginRequest);
            return ResponseEntity.ok(result);
        } catch (RuntimeException e) {
            System.out.println("❌ Login error: " + e.getMessage());
            // Handle specific login errors
            if (e.getMessage().contains("Invalid email/password")) {
                return ResponseEntity.badRequest().body("Invalid email/password");
            }
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
    
    @PostMapping("/login-otp")
    public ResponseEntity<String> loginOtp(@RequestBody LoginRequestDto loginRequest) {
        if (loginRequest.getEmailOrPhone() == null || loginRequest.getPassword() == null) {
            return ResponseEntity.badRequest().body("Email/Phone and Password are required");
        }
        
        String result = unifiedAuthService.sendLoginOtp(loginRequest);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/verify")
    public ResponseEntity<?> verifyOtp(@RequestBody VerifyOtpRequestDto dto) {
        System.out.println("🔍 OTP Verification Request Received");
        JwtResponse response = unifiedAuthService.verifyOtpAndGenerateToken(dto);
        System.out.println(response);
        if (response == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid or Expired OTP!");
        }
        return ResponseEntity.ok(response);
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtpAlternate(@RequestBody VerifyOtpRequestDto dto) {
        System.out.println("🔍 OTP Verification Request Received");
        System.out.println("📱 Contact: " + dto.getEmailOrPhone());
        System.out.println("🔢 OTP: " + dto.getOtp());
        
        JwtResponse response = unifiedAuthService.verifyOtpAndGenerateToken(dto);
        
        if (response == null) {
            System.out.println("❌ OTP Verification Failed");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid or Expired OTP!");
        }
        
        System.out.println("✅ OTP Verification Successful");
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/set-password")
    public ResponseEntity<String> setPassword(@RequestBody SetPasswordDto dto) {
        String result = authService.setPassword(dto);
        return ResponseEntity.ok(result);
    }
    
    // Forgot Password - Send OTP
    @PostMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword(@RequestBody ForgotPasswordRequestDto dto) {
        if (dto.getEmail() == null || dto.getEmail().trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Email is required");
        }
        
        try {
            System.out.println("📧 Forgot password request for: " + dto.getEmail());
            String result = unifiedAuthService.sendForgotPasswordOtp(dto.getEmail());
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            System.out.println("❌ Forgot password error: " + e.getMessage());
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
    
    // Verify Forgot Password OTP and Login
    @PostMapping("/verify-forgot-password-otp")
    public ResponseEntity<?> verifyForgotPasswordOtp(@RequestBody VerifyForgotPasswordOtpDto dto) {
        if (dto.getEmail() == null || dto.getOtp() == null) {
            return ResponseEntity.badRequest().body("Email and OTP are required");
        }
        
        try {
            System.out.println("🔐 Forgot password OTP verification request for: " + dto.getEmail());
            
            JwtResponse response = unifiedAuthService.verifyForgotPasswordOtp(
                dto.getEmail(), 
                dto.getOtp(), 
                dto.getNewPassword()
            );
            
            if (response == null) {
                System.out.println("❌ Forgot password OTP verification failed");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid or expired OTP");
            }
            
            System.out.println("✅ Forgot password OTP verification successful, user logged in");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("❌ Forgot password OTP verification error: " + e.getMessage());
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
    
    @GetMapping("/debug/user/{email}")
    public ResponseEntity<String> debugUser(@PathVariable String email) {
        return ResponseEntity.ok(authService.debugUser(email));
    }
}
