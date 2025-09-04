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
mvn clean package -DskipTests -Pproduction

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
Copy-Item $jarFile.FullName -Destination "application.jar"

# Create Dockerfile for AWS
Write-Host "🐳 Creating Dockerfile..." -ForegroundColor Yellow
@"
FROM openjdk:21-jdk-slim

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy JAR file
COPY application.jar app.jar

# Expose port
EXPOSE 8080

# Set JVM options for AWS
ENV JAVA_OPTS="-Xmx1g -Xms512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -server"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Start application
ENTRYPOINT ["sh", "-c", "java `$JAVA_OPTS -jar app.jar"]
"@ | Out-File -FilePath "Dockerfile" -Encoding UTF8

# Create Dockerrun.aws.json for Elastic Beanstalk
Write-Host "⚙️ Creating Dockerrun.aws.json..." -ForegroundColor Yellow
@"
{
  "AWSEBDockerrunVersion": "1",
  "Image": {
    "Name": "itech-backend",
    "Update": "true"
  },
  "Ports": [
    {
      "ContainerPort": "8080"
    }
  ],
  "Logging": "/var/log/itech-backend"
}
"@ | Out-File -FilePath "Dockerrun.aws.json" -Encoding UTF8

Write-Host "✅ Backend deployment files ready!" -ForegroundColor Green
Write-Host "📁 Files created in: deployment-backend/" -ForegroundColor Cyan

# List created files
Write-Host "📋 Created files:" -ForegroundColor Yellow
Get-ChildItem -Name

Set-Location ".."
Write-Host "🎉 Backend preparation completed!" -ForegroundColor Green
