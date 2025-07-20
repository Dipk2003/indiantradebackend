# Email and SMS Setup Guide

## Current Issues:
1. ❌ Email authentication failed 
2. ❌ SMS authentication failed (Twilio 401 Unauthorized)

## Required Environment Variables

### For Email (Gmail SMTP):
You need to add these to your environment (Render/hosting platform):

```
# Gmail SMTP Configuration
SPRING_MAIL_USERNAME=kyc@indiantrademart.com
SPRING_MAIL_PASSWORD=your_gmail_app_password_here
```

**Important**: The password should be a Gmail App Password, not your regular Gmail password.

### How to Get Gmail App Password:
1. Go to https://myaccount.google.com/security
2. Enable 2-Step Verification (if not already enabled)
3. Go to "App passwords" section
4. Create a new app password for "Mail"
5. Copy the 16-character password (format: xxxx-xxxx-xxxx-xxxx)
6. Use this password in `SPRING_MAIL_PASSWORD`

### For SMS (Choose one option):

#### Option 1: Twilio (International SMS)
```
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=+1234567890
```

#### Option 2: MSG91 (Indian SMS - Recommended for India)
```
MSG91_API_KEY=your_msg91_api_key
MSG91_TEMPLATE_ID=your_msg91_template_id
```

#### Option 3: Textlocal (Alternative Indian SMS)
```
TEXTLOCAL_API_KEY=your_textlocal_api_key
```

## Updated Environment Variables

Your complete `.env` file should look like this:

```env
# Existing variables
ALLOWED_ORIGINS=https://itm-main-fronted-c4l8.vercel.app
DATABASE_URL=postgresql://itech_user_user:uPCQxPFY1lO77Ob0tR9MKDHUOXJGTqFc@dpg-d1sbevruibrs73a87mhg-a.oregon-postgres.render.com/itech_user
JWT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5
PORT=8080
SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.postgresql.Driver
SPRING_DATASOURCE_PASSWORD=uPCQxPFY1lO77Ob0tR9MKDHUOXJGTqFc
SPRING_DATASOURCE_URL="jdbc:postgresql://dpg-d1sbevruibrs73a87mhg-a.oregon-postgres.render.com:5432/itech_user?sslmode=require"
SPRING_DATASOURCE_USERNAME=itech_user_user
SPRING_PROFILES_ACTIVE=production
SPRING_SECURITY_ENABLED=false

# Email Configuration
SPRING_MAIL_HOST=smtp.gmail.com
SPRING_MAIL_PORT=587
SPRING_MAIL_USERNAME=kyc@indiantrademart.com
SPRING_MAIL_PASSWORD=YOUR_GMAIL_APP_PASSWORD_HERE
SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_ENABLE=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_REQUIRED=true
SPRING_MAIL_PROPERTIES_MAIL_SMTP_SSL_PROTOCOLS=TLSv1.2

# Disable simulation to enable real sending
EMAIL_SIMULATION_ENABLED=false
SMS_SIMULATION_ENABLED=false

# SMS Configuration - Choose one option:

# Option 1: Twilio (International)
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=+1234567890

# Option 2: MSG91 (Indian - Recommended)
MSG91_API_KEY=your_msg91_api_key
MSG91_TEMPLATE_ID=your_msg91_template_id

# Option 3: Textlocal (Indian alternative)
TEXTLOCAL_API_KEY=your_textlocal_api_key
```

## Setup Steps:

### Step 1: Fix Gmail Configuration
1. **Get Gmail App Password** (follow steps above)
2. **Update environment variable**: Set `SPRING_MAIL_PASSWORD=your_app_password`
3. **Verify email address**: Ensure `kyc@indiantrademart.com` is accessible

### Step 2: Fix SMS Configuration (Choose one):

#### For Indian SMS (MSG91 - Recommended):
1. Sign up at https://msg91.com/
2. Get API Key from dashboard
3. Create an OTP template
4. Set environment variables:
   ```
   MSG91_API_KEY=your_api_key
   MSG91_TEMPLATE_ID=your_template_id
   ```

#### For International SMS (Twilio):
1. Sign up at https://www.twilio.com/
2. Get Account SID and Auth Token from console
3. Buy a phone number
4. Set environment variables:
   ```
   TWILIO_ACCOUNT_SID=your_account_sid
   TWILIO_AUTH_TOKEN=your_auth_token
   TWILIO_PHONE_NUMBER=+1234567890
   ```

### Step 3: Deploy Changes
1. Update environment variables in your hosting platform (Render)
2. Restart your application
3. Test OTP sending

## Testing:
After updating the configuration:
1. Try sending an OTP
2. Check logs for "✅ Email OTP sent successfully" 
3. Check logs for "✅ SMS OTP sent successfully"

## Common Issues:

### Gmail Issues:
- ❌ **"Authentication failed"**: Wrong app password
- ❌ **"535 Username and Password not accepted"**: Need to enable 2FA and use App Password
- ❌ **Email not received**: Check spam folder, verify email address

### SMS Issues:
- ❌ **"401 Unauthorized"**: Wrong API credentials
- ❌ **"403 Forbidden"**: Account not verified or insufficient balance
- ❌ **Template issues**: MSG91 requires pre-approved templates

## Fallback:
If you can't configure real SMS/Email immediately, the application will fall back to console simulation, but you should see the OTPs in the logs.
