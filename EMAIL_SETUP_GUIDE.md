# Email/OTP Setup and Troubleshooting Guide

## Current Issue
Your OTP emails are only showing in the console and not being sent to actual email addresses.

## Root Causes and Solutions

### 1. Email Simulation Mode
**Problem**: Your application might be running in email simulation mode.

**Solution**: 
- Ensure `email.simulation.enabled=false` in your Render environment variables
- Check your Spring Mail configuration

### 2. Gmail App Password Configuration
**Current Setup**: You're using `tqvipqgkpnxyuef` as the password.

**Verification Steps**:
1. Go to Google Account Settings → Security → 2-Step Verification → App Passwords
2. Generate a new 16-character app password if needed
3. Use this app password instead of your regular Gmail password

### 3. Required Render Environment Variables

Set these exactly in your Render dashboard:

```bash
# Email Configuration
SPRING_MAIL_HOST=smtp.gmail.com
SPRING_MAIL_PORT=587
SPRING_MAIL_USERNAME=ultimate.itech4@gmail.com
SPRING_MAIL_PASSWORD=tqvipqgkpnxyuef
SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_ENABLE=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_SSL_TRUST=smtp.gmail.com

# Disable Email Simulation
EMAIL_SIMULATION_ENABLED=false
email.simulation.enabled=false

# Email Debug (remove after fixing)
SPRING_MAIL_PROPERTIES_MAIL_DEBUG=true
```

### 4. Spring Boot Configuration Check

Ensure your `application.properties` or `application.yml` includes:

```properties
# Email Configuration
spring.mail.host=${SPRING_MAIL_HOST:smtp.gmail.com}
spring.mail.port=${SPRING_MAIL_PORT:587}
spring.mail.username=${SPRING_MAIL_USERNAME}
spring.mail.password=${SPRING_MAIL_PASSWORD}
spring.mail.properties.mail.smtp.auth=${SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH:true}
spring.mail.properties.mail.smtp.starttls.enable=${SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_ENABLE:true}
spring.mail.properties.mail.smtp.ssl.trust=${SPRING_MAIL_PROPERTIES_MAIL_SMTP_SSL_TRUST:smtp.gmail.com}

# Disable email simulation for production
email.simulation.enabled=${EMAIL_SIMULATION_ENABLED:false}
```

### 5. Java Code Configuration

Check your email service implementation:

```java
@Service
public class EmailService {
    
    @Autowired
    private JavaMailSender mailSender;
    
    @Value("${email.simulation.enabled:false}")
    private boolean emailSimulationEnabled;
    
    public void sendOtpEmail(String to, String otp) {
        if (emailSimulationEnabled) {
            log.info("Email simulation enabled. OTP for {}: {}", to, otp);
            return; // This is why emails aren't being sent!
        }
        
        // Actual email sending code
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);
            
            helper.setTo(to);
            helper.setSubject("Your OTP Code");
            helper.setText("Your OTP is: " + otp);
            helper.setFrom("ultimate.itech4@gmail.com");
            
            mailSender.send(message);
            log.info("OTP email sent successfully to: {}", to);
            
        } catch (Exception e) {
            log.error("Failed to send OTP email to: {}", to, e);
            throw new RuntimeException("Failed to send email", e);
        }
    }
}
```

## Debugging Steps

### Step 1: Check Current Environment Variables
Add these logs to your application:

```java
@PostConstruct
public void logEmailConfig() {
    log.info("Email simulation enabled: {}", emailSimulationEnabled);
    log.info("SMTP Host: {}", smtpHost);
    log.info("SMTP Port: {}", smtpPort);
    log.info("SMTP Username: {}", smtpUsername);
    log.info("SMTP Password configured: {}", smtpPassword != null && !smtpPassword.isEmpty());
}
```

### Step 2: Test Email Configuration
Create a test endpoint:

```java
@RestController
public class EmailTestController {
    
    @Autowired
    private EmailService emailService;
    
    @PostMapping("/test-email")
    public ResponseEntity<String> testEmail(@RequestParam String email) {
        try {
            emailService.sendOtpEmail(email, "123456");
            return ResponseEntity.ok("Test email sent successfully");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Failed to send email: " + e.getMessage());
        }
    }
}
```

## Deployment Instructions

### For Render (Backend):
1. Go to your Render dashboard
2. Select your backend service
3. Go to Environment variables
4. Add/update these variables:
   - `EMAIL_SIMULATION_ENABLED=false`
   - `email.simulation.enabled=false`
   - All the SPRING_MAIL_* variables listed above
5. Deploy the changes

### For Netlify (Frontend):
1. Go to your Netlify dashboard
2. Select your site
3. Go to Site settings → Environment variables
4. Add the variables from your frontend `.env` file
5. Redeploy the site

## Quick Fix Checklist

- [ ] Set `EMAIL_SIMULATION_ENABLED=false` in Render
- [ ] Set `email.simulation.enabled=false` in Render
- [ ] Verify Gmail app password is correct
- [ ] Check Spring Mail properties are set in Render
- [ ] Enable debug logging temporarily
- [ ] Test with a simple email endpoint
- [ ] Check application logs for actual error messages
- [ ] Verify CORS settings allow your frontend domain

## Common Issues

1. **Gmail blocks the connection**: Enable "Less secure app access" or use App Password
2. **Firewall issues**: Render should handle this, but check if port 587 is accessible
3. **Spring profile**: Make sure you're not running in a test profile that disables emails
4. **Environment variable precedence**: Application properties might override environment variables

## Final Notes

The most likely issue is that `email.simulation.enabled=true` somewhere in your configuration. Find and disable this setting in your Render environment variables.
