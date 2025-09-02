package com.itech.itech_backend.modules.core.controller;

import com.itech.itech_backend.modules.shared.dto.JwtResponse;
import com.itech.itech_backend.modules.shared.dto.LoginRequestDto;
import com.itech.itech_backend.modules.shared.dto.RegisterRequestDto;
import com.itech.itech_backend.modules.shared.dto.SetPasswordDto;
import com.itech.itech_backend.modules.shared.dto.VerifyOtpRequestDto;
import com.itech.itech_backend.modules.shared.dto.ForgotPasswordRequestDto;
import com.itech.itech_backend.modules.shared.dto.VerifyForgotPasswordOtpDto;
import com.itech.itech_backend.modules.core.service.AuthService;
import com.itech.itech_backend.modules.core.service.UnifiedAuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
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
        return handleRoleSpecificLogin(loginRequest, null); // Generic login (backward compatibility)
    }
    
    // User-specific login endpoint
    @PostMapping("/user/login")
    public ResponseEntity<?> userLogin(@RequestBody LoginRequestDto loginRequest) {
        return handleRoleSpecificLogin(loginRequest, "ROLE_USER");
    }
    
    // Vendor-specific login endpoint
    @PostMapping("/vendor/login")
    public ResponseEntity<?> vendorLogin(@RequestBody LoginRequestDto loginRequest) {
        return handleRoleSpecificLogin(loginRequest, "ROLE_VENDOR");
    }
    
    // Admin-specific login endpoint
    @PostMapping("/admin/login")
    public ResponseEntity<?> adminLogin(@RequestBody LoginRequestDto loginRequest) {
        return handleRoleSpecificLogin(loginRequest, "ROLE_ADMIN");
    }
    
    private ResponseEntity<?> handleRoleSpecificLogin(LoginRequestDto loginRequest, String expectedRole) {
        if (loginRequest.getEmailOrPhone() == null || loginRequest.getPassword() == null) {
            return ResponseEntity.badRequest().body("Email/Phone and Password are required");
        }
        
        try {
            System.out.println("🔐 Login attempt for: " + loginRequest.getEmailOrPhone() + 
                             (expectedRole != null ? " (Expected role: " + expectedRole + ")" : ""));
            
            // Try direct login first with role validation
            JwtResponse directLogin = unifiedAuthService.directLoginWithRoleValidation(loginRequest, expectedRole);
            if (directLogin != null) {
                System.out.println("✅ Direct login successful for: " + loginRequest.getEmailOrPhone());
                return ResponseEntity.ok(directLogin);
            }
            
            System.out.println("ℹ️ Direct login failed, trying OTP-based login");
            // If direct login fails, fall back to OTP-based login with role validation
            String result = unifiedAuthService.sendLoginOtpWithRoleValidation(loginRequest, expectedRole);
            return ResponseEntity.ok(result);
        } catch (RuntimeException e) {
            System.out.println("❌ Login error: " + e.getMessage());
            // Handle specific login errors
            if (e.getMessage().contains("Invalid email/password") || 
                e.getMessage().contains("Invalid credentials") ||
                e.getMessage().contains("User not found")) {
                return ResponseEntity.badRequest().body("Invalid email and password");
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
    
    @PostMapping("/check-email-role")
    public ResponseEntity<?> checkEmailRole(@RequestBody Map<String, String> request) {
        try {
            String email = request.get("email");
            if (email == null || email.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Email is required"));
            }
            
            Map<String, String> result = unifiedAuthService.checkEmailRole(email);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            System.out.println("Error in check email role: " + e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/debug/user/{email}")
    public ResponseEntity<String> debugUser(@PathVariable String email) {
        return ResponseEntity.ok(authService.debugUser(email));
    }
    
    // Change Password
    @PostMapping("/change-password")
    public ResponseEntity<String> changePassword(@RequestBody Map<String, String> request) {
        try {
            String currentPassword = request.get("currentPassword");
            String newPassword = request.get("newPassword");
            
            if (currentPassword == null || newPassword == null) {
                return ResponseEntity.badRequest().body("Current password and new password are required");
            }
            
            if (newPassword.length() < 6) {
                return ResponseEntity.badRequest().body("New password must be at least 6 characters long");
            }
            
            String result = unifiedAuthService.changePassword(currentPassword, newPassword);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            System.out.println("❌ Change password error: " + e.getMessage());
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
    
    // Update Profile
    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(@RequestBody Map<String, Object> profileData) {
        try {
            System.out.println("📝 Update profile request received: " + profileData);
            
            Object updatedUser = unifiedAuthService.updateProfile(profileData);
            System.out.println("✅ Profile updated successfully");
            
            return ResponseEntity.ok(updatedUser);
        } catch (Exception e) {
            System.out.println("❌ Update profile error: " + e.getMessage());
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
    
    // Get Profile
    @GetMapping("/profile")
    public ResponseEntity<?> getProfile() {
        try {
            Object userProfile = unifiedAuthService.getCurrentUserProfile();
            return ResponseEntity.ok(userProfile);
        } catch (Exception e) {
            System.out.println("❌ Get profile error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
        }
    }
}

