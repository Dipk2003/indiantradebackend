# PowerShell Script for Elastic Beanstalk Deployment
# Indian Trade Mart - Backend Deployment Script

Write-Host "🚀 Starting Indian Trade Mart Backend Deployment to Elastic Beanstalk" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green

# Configuration
$BACKEND_DIR = "D:\itech-backend\itech-backend"
$FRONTEND_DIR = "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main"
$APP_NAME = "indiantrademart-backend"
$ENV_NAME = "indianmart-prod"
$REGION = "ap-south-1"

# Function to check if command exists
function Test-CommandExists {
    param($cmdName)
    return [bool](Get-Command -Name $cmdName -ErrorAction SilentlyContinue)
}

Write-Host "📋 Pre-deployment Checks" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow

# Check AWS CLI
if (Test-CommandExists "aws") {
    Write-Host "✅ AWS CLI found" -ForegroundColor Green
    aws --version
} else {
    Write-Host "❌ AWS CLI not found. Please install it first." -ForegroundColor Red
    Write-Host "Download from: https://aws.amazon.com/cli/" -ForegroundColor Yellow
    exit 1
}

# Check EB CLI
if (Test-CommandExists "eb") {
    Write-Host "✅ EB CLI found" -ForegroundColor Green
    eb --version
} else {
    Write-Host "❌ EB CLI not found. Installing..." -ForegroundColor Yellow
    try {
        pip install awsebcli
        Write-Host "✅ EB CLI installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to install EB CLI. Please install manually: pip install awsebcli" -ForegroundColor Red
        exit 1
    }
}

# Check Java
if (Test-CommandExists "java") {
    Write-Host "✅ Java found" -ForegroundColor Green
    java -version
} else {
    Write-Host "❌ Java not found. Please install Java 21" -ForegroundColor Red
    exit 1
}

# Check Maven
if (Test-CommandExists "mvn") {
    Write-Host "✅ Maven found" -ForegroundColor Green
    mvn -version
} else {
    Write-Host "⚠️ Maven not found globally. Using Maven Wrapper" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🏗️ Building Application" -ForegroundColor Yellow
Write-Host "=======================" -ForegroundColor Yellow

# Navigate to backend directory
Set-Location $BACKEND_DIR

# Clean and build
Write-Host "Building Spring Boot application..." -ForegroundColor Cyan
try {
    if (Test-CommandExists "mvn") {
        mvn clean package -DskipTests
    } else {
        .\mvnw clean package -DskipTests
    }
    Write-Host "✅ Application built successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Build failed. Please check errors above." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 Elastic Beanstalk Setup" -ForegroundColor Yellow
Write-Host "==========================" -ForegroundColor Yellow

# Check if .elasticbeanstalk directory exists
if (Test-Path ".elasticbeanstalk") {
    Write-Host "✅ EB already initialized" -ForegroundColor Green
} else {
    Write-Host "Initializing Elastic Beanstalk..." -ForegroundColor Cyan
    Write-Host "Please follow the prompts:" -ForegroundColor Yellow
    Write-Host "- Region: $REGION (Asia Pacific Mumbai)" -ForegroundColor Yellow
    Write-Host "- Application name: $APP_NAME" -ForegroundColor Yellow
    Write-Host "- Platform: Java" -ForegroundColor Yellow
    Write-Host "- Platform version: Java 21 running on 64bit Amazon Linux 2023" -ForegroundColor Yellow
    Write-Host "- CodeCommit: No" -ForegroundColor Yellow
    Write-Host "- SSH: Yes (recommended)" -ForegroundColor Yellow
    
    eb init
}

Write-Host ""
Write-Host "🚀 Deploying to Elastic Beanstalk" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

# Check if environment exists
$ebStatus = eb status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Environment not found. Creating new environment..." -ForegroundColor Cyan
    Write-Host "Environment name: $ENV_NAME" -ForegroundColor Yellow
    Write-Host "DNS CNAME: indianmart" -ForegroundColor Yellow
    
    eb create $ENV_NAME --region $REGION
} else {
    Write-Host "Environment found. Deploying..." -ForegroundColor Cyan
    eb deploy
}

Write-Host ""
Write-Host "🔍 Post-Deployment Checks" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow

# Check application health
Write-Host "Checking application health..." -ForegroundColor Cyan
eb health

# Show application URL
Write-Host "Getting application URL..." -ForegroundColor Cyan
$appUrl = eb status | Select-String "CNAME:" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
if ($appUrl) {
    Write-Host "✅ Application URL: https://$appUrl" -ForegroundColor Green
} else {
    Write-Host "⚠️ Could not retrieve application URL. Check EB console." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📊 Environment Status" -ForegroundColor Yellow
Write-Host "=====================" -ForegroundColor Yellow
eb status

Write-Host ""
Write-Host "📝 Next Steps" -ForegroundColor Yellow
Write-Host "=============" -ForegroundColor Yellow
Write-Host "1. Configure RDS database:" -ForegroundColor Cyan
Write-Host "   - Go to EB Console → Configuration → Database" -ForegroundColor White
Write-Host "   - Engine: postgres, Version: 15.4, Class: db.t3.micro" -ForegroundColor White

Write-Host "2. Set environment variables:" -ForegroundColor Cyan
Write-Host "   - Go to EB Console → Configuration → Software → Environment Properties" -ForegroundColor White
Write-Host "   - Copy variables from .env.elastic-beanstalk file" -ForegroundColor White

Write-Host "3. Update frontend configuration:" -ForegroundColor Cyan
Write-Host "   - Update NEXT_PUBLIC_API_URL in .env.production" -ForegroundColor White
Write-Host "   - Deploy frontend with new backend URL" -ForegroundColor White

Write-Host "4. Configure S3 bucket:" -ForegroundColor Cyan
Write-Host "   - Create S3 bucket: indiantrademart-storage" -ForegroundColor White
Write-Host "   - Set CORS policy and environment variables" -ForegroundColor White

Write-Host "5. Set up SSL certificate:" -ForegroundColor Cyan
Write-Host "   - Use AWS Certificate Manager" -ForegroundColor White
Write-Host "   - Configure in Load Balancer settings" -ForegroundColor White

Write-Host ""
Write-Host "🎉 Deployment Complete!" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green
Write-Host "Application deployed successfully to Elastic Beanstalk!" -ForegroundColor Green

if ($appUrl) {
    Write-Host "🌐 Backend URL: https://$appUrl" -ForegroundColor Green
    Write-Host "🏥 Health Check: https://$appUrl/api/health" -ForegroundColor Green
}

Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Cyan
Write-Host "- Full deployment guide: ELASTIC_BEANSTALK_RDS_DEPLOYMENT.md" -ForegroundColor White
Write-Host "- Environment variables: .env.elastic-beanstalk" -ForegroundColor White

Write-Host ""
Write-Host "🔧 Useful Commands:" -ForegroundColor Cyan
Write-Host "- View logs: eb logs --all" -ForegroundColor White
Write-Host "- Open app: eb open" -ForegroundColor White
Write-Host "- SSH to instance: eb ssh" -ForegroundColor White
Write-Host "- Environment status: eb status" -ForegroundColor White

Write-Host ""
Write-Host "Happy coding! 🚀" -ForegroundColor Green
