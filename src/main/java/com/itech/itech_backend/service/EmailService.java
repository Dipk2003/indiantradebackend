package com.itech.itech_backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import lombok.extern.slf4j.Slf4j;

import jakarta.mail.internet.MimeMessage;

@Service
@Slf4j
public class EmailService {
    
    @Autowired(required = false)
    private JavaMailSender mailSender;
    
    @Value("${spring.mail.username:noreply@indiantradeMart.com}")
    private String fromEmail;
    
    @Value("${email.simulation.enabled:true}")
    private boolean simulationEnabled;
    
    @Value("${spring.profiles.active:default}")
    private String activeProfile;
    
    public void sendOtp(String email, String otp) {
        try {
            log.info("🔧 EMAIL SERVICE DEBUG - Profile: {}, Simulation: {}, MailSender: {}", 
                    activeProfile, simulationEnabled, (mailSender != null ? "Available" : "NULL"));
            
            if (mailSender != null && !simulationEnabled) {
                log.info("📧 Attempting to send REAL email to: {}", email);
                sendRealEmail(email, otp);
            } else {
                log.warn("📧 Sending SIMULATED email - MailSender: {}, Simulation: {}", 
                        (mailSender != null), simulationEnabled);
                sendSimulatedEmail(email, otp);
            }
        } catch (Exception e) {
            log.error("❌ Failed to send email to: {} - Error: {}", email, e.getMessage(), e);
            // Fallback to console for debugging
            sendSimulatedEmail(email, otp);
        }
    }
    
    private void sendRealEmail(String email, String otp) {
        try {
            System.out.println("\n🔧 PRODUCTION EMAIL DEBUG INFO:");
            System.out.println("Profile: " + activeProfile);
            System.out.println("From Email: " + fromEmail);
            System.out.println("To Email: " + email);
            System.out.println("MailSender null? " + (mailSender == null));
            System.out.println("Simulation Enabled: " + simulationEnabled);
            System.out.println("OTP: " + otp);
            
            if (mailSender == null) {
                log.error("❌ JavaMailSender is NULL - Mail configuration failed!");
                throw new RuntimeException("JavaMailSender not configured properly");
            }
            
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail);
            helper.setTo(email);
            helper.setSubject("Indian Trade Mart - OTP Verification");
            helper.setText(buildOtpEmailContentHtml(otp), true);
            
            System.out.println("📧 Attempting to send email via SMTP...");
            
            // Test connection first in production
            if ("production".equals(activeProfile)) {
                System.out.println("🔧 Testing SMTP connection...");
                mailSender.testConnection();
                System.out.println("✅ SMTP connection successful");
            }
            
            mailSender.send(message);
            
            log.info("✅ Production Email OTP sent successfully to: {}", email);
            System.out.println("✅ PRODUCTION Email sent to: " + email + " with OTP: " + otp);
            System.out.println("🔧 PRODUCTION EMAIL DEBUG END\n");
            
        } catch (Exception e) {
            System.out.println("❌ PRODUCTION EMAIL ERROR DETAILS:");
            System.out.println("Error Type: " + e.getClass().getSimpleName());
            System.out.println("Error Message: " + e.getMessage());
            if (e.getCause() != null) {
                System.out.println("Root Cause: " + e.getCause().getMessage());
            }
            System.out.println("Stack Trace:");
            e.printStackTrace();
            System.out.println("🔧 PRODUCTION EMAIL ERROR END\n");
            
            log.error("❌ Failed to send production email to {}: {}", email, e.getMessage(), e);
            
            // In production, fallback to simulation instead of throwing exception
            if ("production".equals(activeProfile)) {
                log.warn("🔄 Production email failed, falling back to simulation for user: {}", email);
                sendSimulatedEmail(email, otp);
            } else {
                throw new RuntimeException("Email sending failed", e);
            }
        }
    }
    
    private void sendSimulatedEmail(String email, String otp) {
        // Enhanced console display for development
        System.out.println("\n" + "=".repeat(80));
        System.out.println("📧 SIMULATED EMAIL SENT TO: " + email);
        System.out.println("From: " + fromEmail);
        System.out.println("Subject: Indian Trade Mart - OTP Verification");
        System.out.println("\n" + "-".repeat(80));
        System.out.println("EMAIL CONTENT:");
        System.out.println("-".repeat(80));
        System.out.println(buildOtpEmailContent(otp));
        System.out.println("-".repeat(80));
        System.out.println("\n🔑 YOUR OTP IS: " + otp);
        System.out.println("⏰ Valid for 5 minutes only!");
        System.out.println("\n💡 To enable real email sending:");
        System.out.println("1. Configure Gmail SMTP in application.properties");
        System.out.println("2. Set email.simulation.enabled=false");
        System.out.println("=".repeat(80) + "\n");
        
        log.info("📧 Simulated email sent to: {} with OTP: {}", email, otp);
    }
    
    private String buildOtpEmailContent(String otp) {
        return String.format(
            "Dear User,\n\n" +
            "Welcome to Indian Trade Mart!\n\n" +
            "Your One-Time Password (OTP) for verification is: %s\n\n" +
            "This OTP is valid for 5 minutes only.\n\n" +
            "If you didn't request this OTP, please ignore this email.\n\n" +
            "Best regards,\n" +
            "Indian Trade Mart Team\n" +
            "\n" +
            "Note: Please do not reply to this email as it is auto-generated.",
            otp
        );
    }
    
    private String buildOtpEmailContentHtml(String otp) {
        return String.format(
            "<!DOCTYPE html>" +
            "<html>" +
            "<head>" +
            "    <meta charset='UTF-8'>" +
            "    <meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
            "    <title>Indian Trade Mart - OTP Verification</title>" +
            "</head>" +
            "<body style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;'>" +
            "    <div style='background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);'>" +
            "        <div style='text-align: center; margin-bottom: 30px;'>" +
            "            <h1 style='color: #1890ff; margin-bottom: 10px;'>Indian Trade Mart</h1>" +
            "            <p style='color: #666; margin: 0;'>India's Premier B2B Marketplace</p>" +
            "        </div>" +
            "        " +
            "        <h2 style='color: #333; margin-bottom: 20px;'>Verification Required</h2>" +
            "        " +
            "        <p style='color: #666; font-size: 16px; line-height: 1.6;'>" +
            "            Dear User,<br><br>" +
            "            Welcome to Indian Trade Mart! To complete your authentication, please use the following One-Time Password (OTP):" +
            "        </p>" +
            "        " +
            "        <div style='background-color: #f0f8ff; border: 2px dashed #1890ff; padding: 20px; text-align: center; margin: 30px 0; border-radius: 8px;'>" +
            "            <h1 style='color: #1890ff; font-size: 36px; margin: 0; letter-spacing: 8px;'>%s</h1>" +
            "        </div>" +
            "        " +
            "        <p style='color: #666; font-size: 14px; text-align: center;'>" +
            "            <strong>⏰ This OTP is valid for 5 minutes only</strong>" +
            "        </p>" +
            "        " +
            "        <p style='color: #666; font-size: 14px; line-height: 1.6; margin-top: 30px;'>" +
            "            If you didn't request this OTP, please ignore this email. Your account remains secure." +
            "        </p>" +
            "        " +
            "        <div style='border-top: 1px solid #eee; padding-top: 20px; margin-top: 30px;'>" +
            "            <p style='color: #999; font-size: 12px; margin: 0;'>" +
            "                Best regards,<br>" +
            "                <strong>Indian Trade Mart Team</strong><br><br>" +
            "                Note: This is an auto-generated email. Please do not reply." +
            "            </p>" +
            "        </div>" +
            "    </div>" +
            "</body>" +
            "</html>",
            otp
        );
    }
}
