package com.itech.itech_backend.modules.core.service;

import com.itech.itech_backend.modules.shared.dto.JwtResponse;
import com.itech.itech_backend.modules.shared.dto.LoginRequestDto;
import com.itech.itech_backend.modules.shared.dto.RegisterRequestDto;
import com.itech.itech_backend.modules.shared.dto.VerifyOtpRequestDto;
import com.itech.itech_backend.modules.core.model.OtpVerification;
import com.itech.itech_backend.modules.core.model.User;
import com.itech.itech_backend.modules.admin.model.Admins;
import com.itech.itech_backend.modules.vendor.model.Vendors;
import com.itech.itech_backend.modules.core.repository.OtpVerificationRepository;
import com.itech.itech_backend.modules.core.repository.UserRepository;
import com.itech.itech_backend.modules.vendor.repository.VendorsRepository;
import com.itech.itech_backend.modules.admin.repository.AdminsRepository;
import com.itech.itech_backend.modules.shared.service.EmailService;
import com.itech.itech_backend.modules.shared.service.SmsService;
import com.itech.itech_backend.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class UnifiedAuthService {

    private final UserRepository userRepository;
    private final VendorsRepository vendorsRepository;
    private final AdminsRepository adminsRepository;
    private final OtpVerificationRepository otpRepo;
    private final EmailService emailService;
    private final SmsService smsService;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;
    
    private static final String ADMIN_ACCESS_CODE = "ADMIN2025";

    public String register(RegisterRequestDto dto) {
        System.out.println("🔧 REGISTRATION DEBUG - Starting registration for: " + dto.getEmail());
        System.out.println("🔧 Role requested: " + dto.getRole());
        
        // Check if user already exists in any table
        boolean userExists = userRepository.existsByEmail(dto.getEmail()) || userRepository.existsByPhone(dto.getPhone());
        boolean vendorExists = vendorsRepository.existsByEmail(dto.getEmail()) || vendorsRepository.existsByPhone(dto.getPhone());
        boolean adminExists = adminsRepository.existsByEmail(dto.getEmail()) || adminsRepository.existsByPhone(dto.getPhone());
        
        if (userExists || vendorExists || adminExists) {
            System.out.println("⚠️ User already exists with email: " + dto.getEmail());
            
            // Find existing user from appropriate table
            User existingUser = null;
            
            if (userExists) {
                Optional<User> userOpt = userRepository.findByEmailOrPhone(dto.getEmail(), dto.getPhone());
                if (userOpt.isPresent()) {
                    existingUser = userOpt.get();
                }
            } else if (vendorExists) {
                Optional<Vendors> vendorOpt = vendorsRepository.findByEmailOrPhone(dto.getEmail(), dto.getPhone());
                if (vendorOpt.isPresent()) {
                    Vendors vendor = vendorOpt.get();
                    existingUser = User.builder()
                        .id(vendor.getId())
                        .name(vendor.getName())
                        .email(vendor.getEmail())
                        .phone(vendor.getPhone())
                        .password(vendor.getPassword())
                        .role(User.UserRole.valueOf(vendor.getRole()))
                        .isVerified(vendor.isVerified())
                        .build();
                }
            } else if (adminExists) {
                Optional<Admins> adminOpt = adminsRepository.findByEmailOrPhone(dto.getEmail(), dto.getPhone());
                if (adminOpt.isPresent()) {
                    Admins admin = adminOpt.get();
                    existingUser = User.builder()
                        .id(admin.getId())
                        .name(admin.getName())
                        .email(admin.getEmail())
                        .phone(admin.getPhone())
                        .password(admin.getPassword())
                        .role(User.UserRole.valueOf(admin.getRole()))
                        .isVerified(admin.isVerified())
                        .build();
                }
            }
            
            if (existingUser != null) {
                // If user is not verified, resend OTP
                if (!existingUser.isVerified()) {
                    System.out.println("🔄 User exists but not verified, resending OTP...");
                    return sendRegistrationOtp(dto, existingUser);
                }
            }
            
            return "User already exists and is verified. Please login instead.";
        }
        
        System.out.println("✅ User does not exist, proceeding with registration");
        
        // Create user in User table
        User user = createUser(dto);
        System.out.println("✅ User created with ID: " + user.getId());
        
        // Send OTP
        System.out.println("📧 About to send registration OTP...");
        String result = sendRegistrationOtp(dto, user);
        System.out.println("🔧 Registration process completed: " + result);
        return result;
    }

    public JwtResponse directLogin(LoginRequestDto loginRequest) {
        return directLoginWithRoleValidation(loginRequest, null);
    }
    
    public JwtResponse directLoginWithRoleValidation(LoginRequestDto loginRequest, String expectedRole) {
        System.out.println("🚀 Direct Login request for: " + loginRequest.getEmailOrPhone() + 
                         (expectedRole != null ? " (Expected role: " + expectedRole + ")" : ""));
        
        // Find user across all tables
        User user = findUserAcrossAllTables(loginRequest.getEmailOrPhone());
        
        if (user == null) {
            System.out.println("❌ User not found in any table");
            throw new RuntimeException("Invalid email and password");
        }
        
        System.out.println("✅ User found: " + user.getEmail() + ", Role: " + user.getRole());
        
        // Validate role if expectedRole is specified
        if (expectedRole != null && !expectedRole.equals(user.getRoleAsString())) {
            System.out.println("❌ Role mismatch: Expected " + expectedRole + ", Found " + user.getRole());
            throw new RuntimeException("Invalid email and password");
        }
        
        // Check admin access code if admin
        if ("ADMIN".equals(user.getRole()) || "ROLE_ADMIN".equals(user.getRole())) {
            if (loginRequest.getAdminCode() == null || !ADMIN_ACCESS_CODE.equals(loginRequest.getAdminCode())) {
                System.out.println("❌ Invalid admin access code");
                return null;
            }
        }
        
        // Validate password - support both plain text and BCrypt
        if (!validatePassword(loginRequest.getPassword(), user.getPassword())) {
            System.out.println("❌ Invalid password");
            throw new RuntimeException("Invalid email/password");
        }
        
        System.out.println("✅ Password validated successfully");
        
        // Generate token directly with user ID
        String token = jwtUtil.generateToken(user.getEmail(), user.getRoleAsString(), user.getId());
        System.out.println("✅ Token generated successfully");
        
        // Create response with user info
        return JwtResponse.builder()
            .token(token)
            .message("Login successful!")
            .user(JwtResponse.UserInfo.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .role(user.getRoleWithReplace("ROLE_", ""))
                .isVerified(user.isVerified())
                .build())
            .build();
    }
    
    public String sendLoginOtp(LoginRequestDto loginRequest) {
        return sendLoginOtpWithRoleValidation(loginRequest, null);
    }
    
    public String sendLoginOtpWithRoleValidation(LoginRequestDto loginRequest, String expectedRole) {
        System.out.println("🔑 Unified Login OTP request for: " + loginRequest.getEmailOrPhone() + 
                         (expectedRole != null ? " (Expected role: " + expectedRole + ")" : ""));
        
        // Find user across all tables
        User user = findUserAcrossAllTables(loginRequest.getEmailOrPhone());
        
        if (user == null) {
            throw new RuntimeException("Invalid email and password");
        }
        
        // Validate role if expectedRole is specified
        if (expectedRole != null && !expectedRole.equals(user.getRole())) {
            System.out.println("❌ Role mismatch for OTP login: Expected " + expectedRole + ", Found " + user.getRole());
            throw new RuntimeException("This account is not registered as a " + 
                (expectedRole.equals("ROLE_USER") ? "user" : 
                 expectedRole.equals("ROLE_VENDOR") ? "vendor" : 
                 expectedRole.equals("ROLE_ADMIN") ? "admin" : "valid user") + 
                ". Please use the correct login portal.");
        }
        
        // Check admin access code if admin
        if ("ROLE_ADMIN".equals(user.getRole())) {
            if (loginRequest.getAdminCode() == null || !ADMIN_ACCESS_CODE.equals(loginRequest.getAdminCode())) {
                throw new RuntimeException("Invalid admin access code. Please contact system administrator.");
            }
        }
        
        // For OTP-based login, we don't validate the password here
        // We only validate that user exists and has correct role
        // The password will be validated during OTP verification
        System.out.println("✅ User validated for OTP login, sending OTP...");
        
        // Store the password temporarily for later validation during OTP verification
        // This is already handled in the generateAndSendOtp method
        
        // Generate and send OTP
        return generateAndSendOtp(loginRequest.getEmailOrPhone(), user.getRoleAsString());
    }

    public JwtResponse verifyOtpAndGenerateToken(VerifyOtpRequestDto dto) {
        System.out.println("🔥 Unified OTP Verification for: " + dto.getEmailOrPhone());
        
        // Find user across all tables
        User user = findUserAcrossAllTables(dto.getEmailOrPhone());
        
        if (user == null) {
            System.out.println("❌ User not found for: " + dto.getEmailOrPhone());
            return null;
        }
        
        // Verify OTP
        Optional<OtpVerification> otpOpt = otpRepo.findByEmailOrPhone(dto.getEmailOrPhone());
        if (!otpOpt.isPresent()) {
            System.out.println("❌ No OTP found for: " + dto.getEmailOrPhone());
            return null;
        }
        
        OtpVerification otp = otpOpt.get();
        if (!otp.getOtp().equals(dto.getOtp()) || !otp.getExpiryTime().isAfter(LocalDateTime.now())) {
            System.out.println("❌ Invalid or expired OTP for: " + dto.getEmailOrPhone());
            return null;
        }
        
        // Mark user as verified and save to the correct table
        updateUserVerificationStatus(user.getEmail(), true);
        otpRepo.delete(otp);
        
        String token = jwtUtil.generateToken(user.getEmail(), user.getRoleAsString(), user.getId());
        System.out.println("✅ OTP verification successful for: " + dto.getEmailOrPhone());
        
        return JwtResponse.builder()
            .token(token)
            .message("Login successful!")
            .user(JwtResponse.UserInfo.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .role(user.getRoleWithReplace("ROLE_", ""))
                .isVerified(user.isVerified())
                .build())
            .build();
    }

    // Helper methods
    private User createUser(RegisterRequestDto dto) {
        String encodedPassword = passwordEncoder.encode(dto.getPassword());
        
        if ("ROLE_VENDOR".equals(dto.getRole())) {
            // Create vendor in Vendors table
            Vendors vendor = Vendors.builder()
                .name(dto.getName())
                .email(dto.getEmail())
                .phone(dto.getPhone())
                .password(encodedPassword)
                .role(dto.getRole())
                .businessName(dto.getBusinessName())
                .businessAddress(dto.getBusinessAddress())
                .gstNumber(dto.getGstNumber())
                .panNumber(dto.getPanNumber())
                .verified(false)
                .build();
            
            Vendors savedVendor = vendorsRepository.save(vendor);
            
            // Return a User object for consistency with the rest of the method
            return User.builder()
                .id(savedVendor.getId())
                .name(savedVendor.getName())
                .email(savedVendor.getEmail())
                .phone(savedVendor.getPhone())
                .password(savedVendor.getPassword())
                .role(User.UserRole.valueOf(savedVendor.getRole()))
                .isVerified(savedVendor.isVerified())
                .build();
        } else if ("ROLE_ADMIN".equals(dto.getRole())) {
            // Create admin in Admins table
            Admins admin = Admins.builder()
                .name(dto.getName())
                .email(dto.getEmail())
                .phone(dto.getPhone())
                .password(encodedPassword)
                .role(dto.getRole())
                .department(dto.getDepartment())
                .designation(dto.getDesignation())
                .verified(false)
                .build();
            
            Admins savedAdmin = adminsRepository.save(admin);
            
            // Return a User object for consistency
            return User.builder()
                .id(savedAdmin.getId())
                .name(savedAdmin.getName())
                .email(savedAdmin.getEmail())
                .phone(savedAdmin.getPhone())
                .password(savedAdmin.getPassword())
                .role(User.UserRole.valueOf(savedAdmin.getRole()))
                .isVerified(savedAdmin.isVerified())
                .build();
        } else {
            // Create regular user in User table
            User.UserBuilder userBuilder = User.builder()
                .name(dto.getName())
                .email(dto.getEmail())
                .phone(dto.getPhone())
                .password(encodedPassword)
                .role(User.UserRole.valueOf(dto.getRole()))
                .isVerified(false);
            
            return userRepository.save(userBuilder.build());
        }
    }

    private String sendRegistrationOtp(RegisterRequestDto dto, User user) {
        String otp = generateOtp();
        LocalDateTime expiry = LocalDateTime.now().plusMinutes(5);
        
        // Clean up old OTPs
        if (dto.getEmail() != null) {
            otpRepo.deleteByEmailOrPhone(dto.getEmail());
        }
        if (dto.getPhone() != null) {
            otpRepo.deleteByEmailOrPhone(dto.getPhone());
        }
        
        // Store OTP
        if (dto.getEmail() != null) {
            otpRepo.save(OtpVerification.builder()
                .emailOrPhone(dto.getEmail())
                .otp(otp)
                .expiryTime(expiry)
                .build());
        }
        
        if (dto.getPhone() != null) {
            otpRepo.save(OtpVerification.builder()
                .emailOrPhone(dto.getPhone())
                .otp(otp)
                .expiryTime(expiry)
                .build());
        }
        
        // Send OTP
        if (dto.getEmail() != null) {
            System.out.println("✉️ Sending OTP to email: " + dto.getEmail());
            emailService.sendOtp(dto.getEmail(), otp);
        }
        if (dto.getPhone() != null) {
            System.out.println("📱 Sending OTP to phone: " + dto.getPhone());
            smsService.sendOtp(dto.getPhone(), otp);
        }
        
        return "OTP sent to your email and phone";
    }

    private boolean validatePassword(String inputPassword, String storedPassword) {
        System.out.println("🔍 Debug - Input password: " + inputPassword);
        System.out.println("🔍 Debug - Stored password: " + storedPassword);
        
        // Check if stored password is BCrypt hash
        if (storedPassword != null && storedPassword.startsWith("$2a$")) {
            // BCrypt validation
            boolean matches = passwordEncoder.matches(inputPassword, storedPassword);
            System.out.println("🔍 Debug - BCrypt password match: " + matches);
            return matches;
        } else {
            // Plain text validation (for backward compatibility)
            boolean matches = inputPassword != null && inputPassword.equals(storedPassword);
            System.out.println("🔍 Debug - Plain text password match: " + matches);
            return matches;
        }
    }

    private String generateAndSendOtp(String contact, String role) {
        String otp = generateOtp();
        LocalDateTime expiry = LocalDateTime.now().plusMinutes(5);
        
        otpRepo.deleteByEmailOrPhone(contact);
        otpRepo.save(OtpVerification.builder()
            .emailOrPhone(contact)
            .otp(otp)
            .expiryTime(expiry)
            .build());
        
        if (contact.contains("@")) {
            emailService.sendOtp(contact, otp);
            return "Password verified. OTP sent to your email.";
        } else {
            smsService.sendOtp(contact, otp);
            return "Password verified. OTP sent to your phone.";
        }
    }

    private String generateOtp() {
        Random rand = new Random();
        return String.format("%06d", rand.nextInt(999999));
    }
    
    /**
     * Find user across all tables (User, Vendors, Admins)
     */
    private User findUserAcrossAllTables(String emailOrPhone) {
        System.out.println("🔍 Searching for user across all tables: " + emailOrPhone);
        
        // Check User table first
        Optional<User> userOpt = userRepository.findByEmailOrPhone(emailOrPhone, emailOrPhone);
        if (userOpt.isPresent()) {
            System.out.println("✅ Found in User table");
            return userOpt.get();
        }
        
        // Check Vendors table
        Optional<Vendors> vendorOpt = vendorsRepository.findByEmailOrPhone(emailOrPhone, emailOrPhone);
        if (vendorOpt.isPresent()) {
            System.out.println("✅ Found in Vendors table");
            Vendors vendor = vendorOpt.get();
            return User.builder()
                .id(vendor.getId())
                .name(vendor.getName())
                .email(vendor.getEmail())
                .phone(vendor.getPhone())
                .password(vendor.getPassword())
                .role(User.UserRole.valueOf(vendor.getRole()))
                .isVerified(vendor.isVerified())
                .build();
        }
        
        // Check Admins table
        Optional<Admins> adminOpt = adminsRepository.findByEmailOrPhone(emailOrPhone, emailOrPhone);
        if (adminOpt.isPresent()) {
            System.out.println("✅ Found in Admins table");
            Admins admin = adminOpt.get();
            return User.builder()
                .id(admin.getId())
                .name(admin.getName())
                .email(admin.getEmail())
                .phone(admin.getPhone())
                .password(admin.getPassword())
                .role(User.UserRole.valueOf(admin.getRole()))
                .isVerified(admin.isVerified())
                .build();
        }
        
        System.out.println("❌ Not found in any table");
        return null;
    }
    
    /**
     * Update user verification status in the correct table
     */
    private void updateUserVerificationStatus(String email, boolean verified) {
        System.out.println("🔄 Updating verification status for: " + email + " to " + verified);
        
        // Check User table first
        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isPresent()) {
            System.out.println("✅ Updating in User table");
            User user = userOpt.get();
            user.setVerified(verified);
            userRepository.save(user);
            return;
        }
        
        // Check Vendors table
        Optional<Vendors> vendorOpt = vendorsRepository.findByEmail(email);
        if (vendorOpt.isPresent()) {
            System.out.println("✅ Updating in Vendors table");
            Vendors vendor = vendorOpt.get();
            vendor.setVerified(verified);
            vendorsRepository.save(vendor);
            return;
        }
        
        // Check Admins table
        Optional<Admins> adminOpt = adminsRepository.findByEmail(email);
        if (adminOpt.isPresent()) {
            System.out.println("✅ Updating in Admins table");
            Admins admin = adminOpt.get();
            admin.setVerified(verified);
            adminsRepository.save(admin);
            return;
        }
        
        System.out.println("❌ User not found in any table for verification update");
    }
    
    /**
     * Change user password
     */
    public String changePassword(String currentPassword, String newPassword) {
        System.out.println("🔒 Change password request received");
        
        // Get current user from JWT token (you'll need to implement this)
        // For now, we'll use a placeholder - you'll need to get the user from security context
        String currentUserEmail = getCurrentUserEmail();
        
        if (currentUserEmail == null) {
            throw new RuntimeException("User not authenticated");
        }
        
        // Find user across all tables
        User user = findUserAcrossAllTables(currentUserEmail);
        
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        
        // Validate current password
        if (!validatePassword(currentPassword, user.getPassword())) {
            throw new RuntimeException("Current password is incorrect");
        }
        
        // Encode new password
        String encodedNewPassword = passwordEncoder.encode(newPassword);
        
        // Update password in the correct table
        updateUserPassword(user.getEmail(), encodedNewPassword);
        
        System.out.println("✅ Password changed successfully for user: " + currentUserEmail);
        return "Password changed successfully";
    }
    
    /**
     * Update user profile
     */
    public Object updateProfile(Map<String, Object> profileData) {
        System.out.println("📝 Update profile request for data: " + profileData);
        
        String currentUserEmail = getCurrentUserEmail();
        
        if (currentUserEmail == null) {
            throw new RuntimeException("User not authenticated");
        }
        
        // Find user across all tables
        User user = findUserAcrossAllTables(currentUserEmail);
        
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        
        // Update profile in the correct table based on role
        return updateUserProfile(user, profileData);
    }
    
    /**
     * Get current user profile
     */
    public Object getCurrentUserProfile() {
        System.out.println("📋 Get current user profile request");
        
        String currentUserEmail = getCurrentUserEmail();
        
        if (currentUserEmail == null) {
            throw new RuntimeException("User not authenticated");
        }
        
        // Find user across all tables
        User user = findUserAcrossAllTables(currentUserEmail);
        
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        
        // Return user profile based on role
        return getUserProfileByRole(user);
    }
    
    /**
     * Helper method to get current user email from JWT token
     * You'll need to implement this based on your security configuration
     */
    private String getCurrentUserEmail() {
        // This is a placeholder - you'll need to implement getting the user from security context
        // For Spring Security with JWT, this would typically be:
        // Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        // return auth.getName();
        
        // For now, returning null - you'll need to implement this
        try {
            org.springframework.security.core.Authentication auth = 
                org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
            if (auth != null && auth.getName() != null) {
                return auth.getName();
            }
        } catch (Exception e) {
            System.out.println("❌ Error getting current user: " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Update password in the correct table
     */
    private void updateUserPassword(String email, String newPassword) {
        System.out.println("🔄 Updating password for: " + email);
        
        // Check User table first
        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isPresent()) {
            System.out.println("✅ Updating password in User table");
            User user = userOpt.get();
            user.setPassword(newPassword);
            userRepository.save(user);
            return;
        }
        
        // Check Vendors table
        Optional<Vendors> vendorOpt = vendorsRepository.findByEmail(email);
        if (vendorOpt.isPresent()) {
            System.out.println("✅ Updating password in Vendors table");
            Vendors vendor = vendorOpt.get();
            vendor.setPassword(newPassword);
            vendorsRepository.save(vendor);
            return;
        }
        
        // Check Admins table
        Optional<Admins> adminOpt = adminsRepository.findByEmail(email);
        if (adminOpt.isPresent()) {
            System.out.println("✅ Updating password in Admins table");
            Admins admin = adminOpt.get();
            admin.setPassword(newPassword);
            adminsRepository.save(admin);
            return;
        }
        
        System.out.println("❌ User not found in any table for password update");
    }
    
    /**
     * Update user profile in the correct table
     */
    private Object updateUserProfile(User user, Map<String, Object> profileData) {
        System.out.println("🔄 Updating profile for: " + user.getEmail() + ", Role: " + user.getRole());
        
        String name = (String) profileData.get("name");
        String phone = (String) profileData.get("phone");
        String address = (String) profileData.get("address");
        String companyName = (String) profileData.get("companyName");
        
        // Update based on role
        if ("ROLE_USER".equals(user.getRole())) {
            Optional<User> userOpt = userRepository.findByEmail(user.getEmail());
            if (userOpt.isPresent()) {
                User existingUser = userOpt.get();
                if (name != null) existingUser.setName(name);
                if (phone != null) existingUser.setPhone(phone);
                if (address != null) existingUser.setAddress(address);
                
                User savedUser = userRepository.save(existingUser);
                return createUserResponse(savedUser);
            }
        } else if ("ROLE_VENDOR".equals(user.getRole())) {
            Optional<Vendors> vendorOpt = vendorsRepository.findByEmail(user.getEmail());
            if (vendorOpt.isPresent()) {
                Vendors vendor = vendorOpt.get();
                if (name != null) vendor.setName(name);
                if (phone != null) vendor.setPhone(phone);
                if (address != null) vendor.setBusinessAddress(address);
                if (companyName != null) vendor.setBusinessName(companyName);
                
                Vendors savedVendor = vendorsRepository.save(vendor);
                return createVendorResponse(savedVendor);
            }
        } else if ("ROLE_ADMIN".equals(user.getRole())) {
            Optional<Admins> adminOpt = adminsRepository.findByEmail(user.getEmail());
            if (adminOpt.isPresent()) {
                Admins admin = adminOpt.get();
                if (name != null) admin.setName(name);
                if (phone != null) admin.setPhone(phone);
                
                Admins savedAdmin = adminsRepository.save(admin);
                return createAdminResponse(savedAdmin);
            }
        }
        
        throw new RuntimeException("Failed to update profile");
    }
    
    /**
     * Get user profile by role
     */
    private Object getUserProfileByRole(User user) {
        if ("ROLE_USER".equals(user.getRole())) {
            Optional<User> userOpt = userRepository.findByEmail(user.getEmail());
            if (userOpt.isPresent()) {
                return createUserResponse(userOpt.get());
            }
        } else if ("ROLE_VENDOR".equals(user.getRole())) {
            Optional<Vendors> vendorOpt = vendorsRepository.findByEmail(user.getEmail());
            if (vendorOpt.isPresent()) {
                return createVendorResponse(vendorOpt.get());
            }
        } else if ("ROLE_ADMIN".equals(user.getRole())) {
            Optional<Admins> adminOpt = adminsRepository.findByEmail(user.getEmail());
            if (adminOpt.isPresent()) {
                return createAdminResponse(adminOpt.get());
            }
        }
        
        throw new RuntimeException("User profile not found");
    }
    
    /**
     * Create user response object
     */
    private Object createUserResponse(User user) {
        return Map.of(
            "id", user.getId(),
            "name", user.getName(),
            "email", user.getEmail(),
            "phone", user.getPhone() != null ? user.getPhone() : "",
            "address", user.getAddress() != null ? user.getAddress() : "",
            "role", user.getRoleWithReplace("ROLE_", "").toLowerCase(),
            "userType", user.getRoleWithReplace("ROLE_", "").toLowerCase(),
            "isVerified", user.isVerified(),
            "createdAt", user.getCreatedAt() != null ? user.getCreatedAt().toString() : ""
        );
    }
    
    /**
     * Create vendor response object
     */
    private Object createVendorResponse(Vendors vendor) {
        return Map.of(
            "id", vendor.getId(),
            "name", vendor.getName(),
            "email", vendor.getEmail(),
            "phone", vendor.getPhone() != null ? vendor.getPhone() : "",
            "address", vendor.getBusinessAddress() != null ? vendor.getBusinessAddress() : "",
            "companyName", vendor.getBusinessName() != null ? vendor.getBusinessName() : "",
            "role", vendor.getRole().replace("ROLE_", "").toLowerCase(),
            "userType", vendor.getRole().replace("ROLE_", "").toLowerCase(),
            "isVerified", vendor.isVerified(),
            "createdAt", vendor.getCreatedAt() != null ? vendor.getCreatedAt().toString() : ""
        );
    }
    
    /**
     * Create admin response object
     */
    private Object createAdminResponse(Admins admin) {
        return Map.of(
            "id", admin.getId(),
            "name", admin.getName(),
            "email", admin.getEmail(),
            "phone", admin.getPhone() != null ? admin.getPhone() : "",
            "role", admin.getRole().replace("ROLE_", "").toLowerCase(),
            "userType", admin.getRole().replace("ROLE_", "").toLowerCase(),
            "isVerified", admin.isVerified(),
            "createdAt", admin.getCreatedAt() != null ? admin.getCreatedAt().toString() : ""
        );
    }
    
    /**
     * Send forgot password OTP
     */
    public String sendForgotPasswordOtp(String email) {
        System.out.println("📧 Forgot password OTP request for: " + email);
        
        // Find user across all tables (User, Vendors, Admins)
        User user = findUserAcrossAllTables(email);
        
        if (user == null) {
            System.out.println("❌ User not found with email: " + email);
            return "Email not found. Please check your email address.";
        }
        
        System.out.println("✅ User found: " + user.getEmail() + ", Role: " + user.getRole());
        
        // Generate and send OTP
        String otp = generateOtp();
        LocalDateTime expiry = LocalDateTime.now().plusMinutes(5);
        
        System.out.println("🔢 Generated OTP: " + otp + " for email: " + email);
        
        // Clean up old OTPs for this email
        otpRepo.deleteByEmailOrPhone(email);
        
        // Store new OTP
        otpRepo.save(OtpVerification.builder()
            .emailOrPhone(email)
            .otp(otp)
            .expiryTime(expiry)
            .build());
        
        // Send OTP via email
        System.out.println("✉️ Sending forgot password OTP to email: " + email);
        emailService.sendForgotPasswordOtp(email, otp);
        
        return "OTP sent to your email for password recovery.";
    }
    
    /**
     * Check if email exists and return its role
     */
    public Map<String, String> checkEmailRole(String email) {
        System.out.println("🔍 Checking email role for: " + email);
        
        // Find user across all tables
        User user = findUserAcrossAllTables(email);
        
        if (user == null) {
            System.out.println("❌ Email not found: " + email);
            return Map.of(
                "exists", "false",
                "message", "Email not found"
            );
        }
        
        System.out.println("✅ Email found with role: " + user.getRole());
        return Map.of(
            "exists", "true",
            "role", user.getRoleAsString(),
            "email", user.getEmail()
        );
    }
    
    /**
     * Verify forgot password OTP and login user
     */
    public JwtResponse verifyForgotPasswordOtp(String email, String otpCode, String newPassword) {
        System.out.println("🔐 Forgot password OTP verification for: " + email);
        
        // Find user in User table
        Optional<User> userOpt = userRepository.findByEmail(email);
        
        if (!userOpt.isPresent()) {
            System.out.println("❌ User not found with email: " + email);
            return null;
        }
        
        User user = userOpt.get();
        
        // Verify OTP
        Optional<OtpVerification> otpOpt = otpRepo.findByEmailOrPhone(email);
        if (!otpOpt.isPresent()) {
            System.out.println("❌ No OTP found for email: " + email);
            return null;
        }
        
        OtpVerification otp = otpOpt.get();
        if (!otp.getOtp().equals(otpCode) || !otp.getExpiryTime().isAfter(LocalDateTime.now())) {
            System.out.println("❌ Invalid or expired OTP");
            return null;
        }
        
        // If new password is provided, update the password
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            String encodedPassword = passwordEncoder.encode(newPassword);
            user.setPassword(encodedPassword);
            System.out.println("🔒 Password updated for user: " + email);
        }
        
        // Mark user as verified and save
        user.setVerified(true);
        userRepository.save(user);
        
        // Clean up OTP
        otpRepo.delete(otp);
        
        // Generate token and login the user
        String token = jwtUtil.generateToken(user.getEmail(), user.getRoleAsString(), user.getId());
        
        System.out.println("✅ Forgot password OTP verification successful, user logged in");
        
        return JwtResponse.builder()
            .token(token)
            .message("OTP verified successfully. You are now logged in.")
            .user(JwtResponse.UserInfo.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .role(user.getRoleWithReplace("ROLE_", ""))
                .isVerified(user.isVerified())
                .build())
            .build();
    }
}

