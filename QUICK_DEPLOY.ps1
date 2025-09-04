# =============================================================================
# iTech Quick AWS Deployment Script
# =============================================================================

Write-Host "🚀 iTech AWS Quick Deployment Started!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Yellow

# Check prerequisites
Write-Host "`n🔍 Checking prerequisites..." -ForegroundColor Cyan

# Check AWS CLI
if (!(Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "❌ AWS CLI not found. Please install: winget install Amazon.AWSCLI" -ForegroundColor Red
    Write-Host "After installation, run: aws configure" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "✅ AWS CLI found" -ForegroundColor Green
}

# Check EB CLI
if (!(Get-Command eb -ErrorAction SilentlyContinue)) {
    Write-Host "❌ EB CLI not found. Installing..." -ForegroundColor Yellow
    pip install awsebcli
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install EB CLI. Please install pip first." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ EB CLI found" -ForegroundColor Green
}

# Deployment options
Write-Host "`n🎯 Select deployment option:" -ForegroundColor Cyan
Write-Host "1. Deploy Backend Only" -ForegroundColor Yellow
Write-Host "2. Deploy Frontend Only" -ForegroundColor Yellow  
Write-Host "3. Deploy Both Backend + Frontend" -ForegroundColor Yellow
Write-Host "4. Create RDS Database" -ForegroundColor Yellow
Write-Host "5. Show Deployment Status" -ForegroundColor Yellow

$choice = Read-Host "Enter your choice (1-5)"

switch ($choice) {
    "1" {
        Write-Host "`n🔧 Deploying Backend to Elastic Beanstalk..." -ForegroundColor Green
        
        # Navigate to deployment directory
        cd "D:\itech-backend\itech-backend\deployment-backend"
        
        # Initialize EB (if not already done)
        if (!(Test-Path ".elasticbeanstalk")) {
            Write-Host "Initializing Elastic Beanstalk..." -ForegroundColor Yellow
            eb init -p docker itech-backend --region ap-south-1
        }
        
        # Deploy
        Write-Host "Deploying to production..." -ForegroundColor Yellow
        eb create itech-backend-prod --instance-type t3.medium 2>$null
        eb deploy itech-backend-prod
        
        # Get URL
        $ebUrl = eb status itech-backend-prod | Select-String "CNAME" | ForEach-Object {$_.ToString().Split(":")[1].Trim()}
        Write-Host "✅ Backend deployed successfully!" -ForegroundColor Green
        Write-Host "🌐 Backend URL: $ebUrl" -ForegroundColor Cyan
        
        cd ..
    }
    
    "2" {
        Write-Host "`n🎨 Frontend deployment requires GitHub repository." -ForegroundColor Yellow
        Write-Host "Please follow these steps:" -ForegroundColor Cyan
        Write-Host "1. Push your frontend code to GitHub" -ForegroundColor White
        Write-Host "2. Go to AWS Amplify Console" -ForegroundColor White
        Write-Host "3. Create new app → Connect GitHub repo" -ForegroundColor White
        Write-Host "4. Build settings will auto-detect from amplify.yml" -ForegroundColor White
        Write-Host "5. Add environment variables from production-env-frontend.properties" -ForegroundColor White
    }
    
    "3" {
        Write-Host "`n🚀 Deploying both Backend and Frontend..." -ForegroundColor Green
        # Call both deployment functions
        # Backend first
        & $MyInvocation.MyCommand.Path "1"
        # Then show frontend instructions
        & $MyInvocation.MyCommand.Path "2"
    }
    
    "4" {
        Write-Host "`n🗄️ Creating RDS MySQL Database..." -ForegroundColor Green
        
        $dbPassword = Read-Host "Enter database password (min 8 characters)" -AsSecureString
        $dbPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPassword))
        
        aws rds create-db-instance `
            --db-instance-identifier itech-mysql-prod `
            --db-instance-class db.t3.micro `
            --engine mysql `
            --engine-version 8.0 `
            --allocated-storage 20 `
            --db-name itech_db `
            --master-username admin `
            --master-user-password $dbPasswordPlain `
            --region ap-south-1
            
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ RDS Database creation started!" -ForegroundColor Green
            Write-Host "⏳ Database will be ready in 10-15 minutes." -ForegroundColor Yellow
        } else {
            Write-Host "❌ Failed to create database." -ForegroundColor Red
        }
    }
    
    "5" {
        Write-Host "`n📊 Checking deployment status..." -ForegroundColor Green
        
        # Check EB status
        cd "D:\itech-backend\itech-backend\deployment-backend"
        if (Test-Path ".elasticbeanstalk") {
            Write-Host "`n🔧 Backend Status:" -ForegroundColor Cyan
            eb status 2>$null
        } else {
            Write-Host "❌ No backend deployment found." -ForegroundColor Red
        }
        
        # Check RDS status
        Write-Host "`n🗄️ Database Status:" -ForegroundColor Cyan
        aws rds describe-db-instances --db-instance-identifier itech-mysql-prod --region ap-south-1 2>$null
        
        cd ..
    }
    
    default {
        Write-Host "❌ Invalid choice. Please run the script again." -ForegroundColor Red
    }
}

Write-Host "`n🎉 Deployment script completed!" -ForegroundColor Green
Write-Host "📖 For detailed instructions, check AWS_DEPLOYMENT_INSTRUCTIONS.md" -ForegroundColor Cyan
