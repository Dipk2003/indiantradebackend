# iTech Backend - Database Schema Deployment Script
# PowerShell version for modern Windows environments

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "iTech Backend - Database Schema Deployment" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will deploy the complete database schema to your AWS PostgreSQL database." -ForegroundColor Yellow
Write-Host ""

# Check if psql is available
try {
    $null = Get-Command psql -ErrorAction Stop
    Write-Host "✓ PostgreSQL client found" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: PostgreSQL client (psql) is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install PostgreSQL client tools first." -ForegroundColor Red
    Write-Host "Download from: https://www.postgresql.org/download/windows/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Please provide your AWS PostgreSQL database connection details:" -ForegroundColor Cyan
Write-Host ""

$DB_HOST = Read-Host "Enter database host (e.g., your-db.xxxxx.ap-south-1.rds.amazonaws.com)"
$DB_PORT = Read-Host "Enter database port [5432]"
$DB_NAME = Read-Host "Enter database name"
$DB_USER = Read-Host "Enter database username"

if ([string]::IsNullOrWhiteSpace($DB_PORT)) {
    $DB_PORT = "5432"
}

Write-Host ""
Write-Host "Connection Details:" -ForegroundColor Yellow
Write-Host "Host: $DB_HOST" -ForegroundColor White
Write-Host "Port: $DB_PORT" -ForegroundColor White
Write-Host "Database: $DB_NAME" -ForegroundColor White
Write-Host "User: $DB_USER" -ForegroundColor White
Write-Host ""
Write-Host "WARNING: This will create/modify database tables. Make sure you have a backup!" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Do you want to continue? (y/N)"

if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host ""
Write-Host "Deploying database schema..." -ForegroundColor Green
Write-Host ""

# Set environment variable for password prompt
$env:PGPASSWORD = Read-Host "Enter database password" -AsSecureString | ConvertFrom-SecureString -AsPlainText

try {
    # Execute the SQL script
    & psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "database_schema_initialization.sql"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "================================================" -ForegroundColor Green
        Write-Host "SUCCESS: Database schema deployed successfully!" -ForegroundColor Green
        Write-Host "================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Your Spring Boot application should now start without errors." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Restart your AWS Elastic Beanstalk application" -ForegroundColor White
        Write-Host "2. Check the application logs to confirm it starts properly" -ForegroundColor White
        Write-Host "3. Test your application endpoints" -ForegroundColor White
        Write-Host ""
        Write-Host "AWS EB CLI commands to restart:" -ForegroundColor Cyan
        Write-Host "eb restart" -ForegroundColor Gray
        Write-Host "eb logs --all" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "================================================" -ForegroundColor Red
        Write-Host "ERROR: Database schema deployment failed!" -ForegroundColor Red
        Write-Host "================================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please check the error messages above and fix any issues." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Common issues:" -ForegroundColor Yellow
        Write-Host "1. Incorrect database credentials" -ForegroundColor White
        Write-Host "2. Network connectivity issues" -ForegroundColor White
        Write-Host "3. Insufficient database permissions" -ForegroundColor White
        Write-Host "4. Database connection timeout" -ForegroundColor White
        Write-Host ""
    }
} finally {
    # Clear password from environment
    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
}

Read-Host "Press Enter to exit"
