# =============================================================================
# iTech Backend - AWS Deployment PowerShell Script for Windows  
# =============================================================================

Write-Host "🚀 Starting AWS Backend Deployment..." -ForegroundColor Green

# Check if Maven is available
if (!(Get-Command mvn -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Maven not found. Please install Maven first." -ForegroundColor Red
    exit 1
}

# Build the application
Write-Host "📦 Building Spring Boot application..." -ForegroundColor Yellow
mvn clean package -DskipTests

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Maven build failed!" -ForegroundColor Red
    exit 1
}

# Create deployment directory
Write-Host "📁 Creating deployment directory..." -ForegroundColor Yellow
if (Test-Path "deployment-backend") {
    Remove-Item -Recurse -Force "deployment-backend"
}
New-Item -ItemType Directory -Name "deployment-backend"
Set-Location "deployment-backend"

# Copy JAR file
Write-Host "📋 Copying JAR file..." -ForegroundColor Yellow
$jarFile = Get-ChildItem -Path "..\target" -Filter "*.jar" | Select-Object -First 1
if ($jarFile) {
    Copy-Item $jarFile.FullName -Destination "application.jar"
    Write-Host "✅ JAR file copied: $($jarFile.Name)" -ForegroundColor Green
} else {
    Write-Host "❌ No JAR file found in target directory!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Backend deployment files ready!" -ForegroundColor Green
Write-Host "📁 Files created in: deployment-backend/" -ForegroundColor Cyan

# List created files
Write-Host "📋 Created files:" -ForegroundColor Yellow
Get-ChildItem -Name

Set-Location ".."
Write-Host "🎉 Backend preparation completed!" -ForegroundColor Green
