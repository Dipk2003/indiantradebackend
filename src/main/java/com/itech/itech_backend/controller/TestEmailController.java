package com.itech.itech_backend.controller;

import com.itech.itech_backend.service.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/test")
@CrossOrigin
@RequiredArgsConstructor
public class TestEmailController {

    private final EmailService emailService;
    
    @Value("${email.simulation.enabled:true}")
    private boolean simulationEnabled;
    
    @Value("${spring.mail.username:not-configured}")
    private String mailUsername;
    
    private final JavaMailSender mailSender;

    @PostMapping("/send-test-email")
    public String testEmail(@RequestParam String email) {
        System.out.println("=".repeat(50));
        System.out.println("🧪 TEST EMAIL CONFIGURATION");
        System.out.println("Target Email: " + email);
        System.out.println("Mail Username: " + mailUsername);
        System.out.println("Simulation Enabled: " + simulationEnabled);
        System.out.println("Mail Sender Available: " + (mailSender != null));
        System.out.println("=".repeat(50));
        
        try {
            // Generate a test OTP
            String testOtp = "123456";
            
            // Send test email
            emailService.sendOtp(email, testOtp);
            
            return "Test email sent to " + email + ". Check console for details.";
        } catch (Exception e) {
            System.out.println("❌ Email test failed: " + e.getMessage());
            e.printStackTrace();
            return "Email test failed: " + e.getMessage();
        }
    }
    
    @GetMapping("/email-config")
    public String getEmailConfig() {
        return String.format(
            "Email Configuration:\n" +
            "- Simulation Enabled: %s\n" +
            "- Mail Username: %s\n" +
            "- Mail Sender Available: %s\n",
            simulationEnabled,
            mailUsername,
            (mailSender != null)
        );
    }
}
