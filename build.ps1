# Clean build script for itech-backend
param(
    [switch]$Run
)

Write-Host "Cleaning previous build..." -ForegroundColor Yellow

# Remove target directory if it exists
if (Test-Path "target") {
    Remove-Item -Recurse -Force "target"
    Write-Host "Removed target directory" -ForegroundColor Green
}

# Clean and compile
Write-Host "Running Maven clean compile..." -ForegroundColor Yellow
./mvnw clean compile

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build completed successfully!" -ForegroundColor Green
    
    if ($Run) {
        Write-Host "Starting application..." -ForegroundColor Blue
        ./mvnw spring-boot:run
    } else {
        Write-Host "To run the application, use: ./build.ps1 -Run" -ForegroundColor Cyan
        Write-Host "Or use: ./mvnw spring-boot:run" -ForegroundColor Cyan
    }
} else {
    Write-Host "Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
