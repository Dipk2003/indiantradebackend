# Clean build script for itech-backend
Write-Host "Cleaning previous build..." -ForegroundColor Yellow

# Remove target directory if it exists
if (Test-Path "target") {
    Remove-Item -Recurse -Force "target"
    Write-Host "Removed target directory" -ForegroundColor Green
}

# Clean and package
Write-Host "Running Maven clean compile..." -ForegroundColor Yellow
./mvnw clean compile

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build completed successfully!" -ForegroundColor Green
} else {
    Write-Host "Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
