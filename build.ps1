#=============================================================================
# iTech Backend - Comprehensive Build Script
# Created: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
#=============================================================================

param(
    [Parameter()]
    [ValidateSet("clean", "compile", "test", "package", "docker", "full", "run", "docker-run", "help")]
    [string]$Target = "help",
    
    [Parameter()]
    [ValidateSet("development", "production", "test")]
    [string]$Profile = "development",
    
    [Parameter()]
    [switch]$SkipTests,
    
    [Parameter()]
    [switch]$CleanDocker,
    
    [Parameter()]
    [switch]$Verbose
)

# =============================================================================
# Configuration
# =============================================================================
$PROJECT_NAME = "itech-backend"
$JAR_NAME = "itech-backend-0.0.1-SNAPSHOT.jar"
$DOCKER_IMAGE = "itech-backend:latest"
$PROJECT_DIR = "D:\itech-backend\itech-backend"

# =============================================================================
# Utility Functions
# =============================================================================
function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host " $Message" -ForegroundColor Yellow
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-Host "→ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ ERROR: $Message" -ForegroundColor Red
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ SUCCESS: $Message" -ForegroundColor Green
}

function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Test-JavaVersion {
    try {
        $javaVersion = java -version 2>&1 | Select-String "version" | Select-Object -First 1
        if ($javaVersion -match '"(\d+)\.') {
            $majorVersion = [int]$matches[1]
            if ($majorVersion -ge 21) {
                Write-Step "Java version check passed: $javaVersion"
                return $true
            }
        } elseif ($javaVersion -match '"(\d+)"') {
            $majorVersion = [int]$matches[1]
            if ($majorVersion -ge 21) {
                Write-Step "Java version check passed: $javaVersion"
                return $true
            }
        }
        Write-Error "Java 21 or higher required. Current: $javaVersion"
        return $false
    }
    catch {
        Write-Error "Java not found in PATH"
        return $false
    }
}

# =============================================================================
# Build Functions
# =============================================================================
function Invoke-Clean {
    Write-Header "Cleaning Project"
    
    Write-Step "Cleaning Maven artifacts..."
    $mvnCleanResult = mvn clean
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Maven clean failed"
        exit 1
    }
    
    Write-Step "Removing target directory..."
    if (Test-Path "target") {
        Remove-Item "target" -Recurse -Force
    }
    
    Write-Step "Cleaning Docker artifacts..."
    if ($CleanDocker) {
        docker system prune -f 2>$null
        docker image rm $DOCKER_IMAGE -f 2>$null
    }
    
    Write-Success "Project cleaned successfully"
}

function Invoke-Compile {
    Write-Header "Compiling Project"
    
    Write-Step "Compiling source code..."
    $compileArgs = @("compile")
    if ($Verbose) { $compileArgs += "-X" }
    
    $mvnCompileResult = mvn @compileArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Compilation failed"
        exit 1
    }
    
    Write-Success "Compilation completed successfully"
}

function Invoke-Test {
    Write-Header "Running Tests"
    
    Write-Step "Running unit and integration tests..."
    $testArgs = @("test")
    if ($Verbose) { $testArgs += "-X" }
    if ($Profile -ne "test") { 
        $testArgs += "-Dspring.profiles.active=test"
    }
    
    $mvnTestResult = mvn @testArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Tests failed"
        exit 1
    }
    
    Write-Success "All tests passed"
}

function Invoke-Package {
    Write-Header "Packaging Application"
    
    Write-Step "Creating JAR package..."
    $packageArgs = @("package")
    if ($SkipTests) { $packageArgs += "-DskipTests" }
    if ($Verbose) { $packageArgs += "-X" }
    
    $mvnPackageResult = mvn @packageArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Packaging failed"
        exit 1
    }
    
    if (Test-Path "target\$JAR_NAME") {
        Write-Success "JAR created: target\$JAR_NAME"
        $jarSize = (Get-Item "target\$JAR_NAME").Length / 1MB
        Write-Host "   JAR size: $([math]::Round($jarSize, 2)) MB" -ForegroundColor Cyan
    } else {
        Write-Error "JAR file not found after packaging"
        exit 1
    }
}

function Invoke-DockerBuild {
    Write-Header "Building Docker Image"
    
    if (-not (Test-Command "docker")) {
        Write-Error "Docker not found. Please install Docker Desktop."
        exit 1
    }
    
    Write-Step "Building Docker image: $DOCKER_IMAGE"
    $dockerBuildResult = docker build -t $DOCKER_IMAGE .
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Docker build failed"
        exit 1
    }
    
    Write-Step "Checking image size..."
    $imageInfo = docker images $DOCKER_IMAGE --format "table {{.Size}}" | Select-Object -Skip 1
    Write-Success "Docker image built successfully"
    Write-Host "   Image size: $imageInfo" -ForegroundColor Cyan
}

function Invoke-Run {
    Write-Header "Running Application Locally"
    
    Write-Step "Starting Spring Boot application with profile: $Profile"
    $runArgs = @("spring-boot:run")
    $runArgs += "-Dspring-boot.run.profiles=$Profile"
    if ($Verbose) { $runArgs += "-X" }
    
    Write-Host "Starting application... (Press Ctrl+C to stop)" -ForegroundColor Yellow
    mvn @runArgs
}

function Invoke-DockerRun {
    Write-Header "Running Application with Docker Compose"
    
    if (-not (Test-Command "docker-compose")) {
        Write-Error "Docker Compose not found. Please install Docker Desktop."
        exit 1
    }
    
    Write-Step "Starting services with Docker Compose..."
    Write-Host "Services: MySQL, Redis, iTech Backend" -ForegroundColor Cyan
    
    docker-compose up --build
}

function Show-Help {
    Write-Header "iTech Backend Build Script Help"
    
    Write-Host "Usage: .\build.ps1 -Target <target> [-Profile <profile>] [-SkipTests] [-CleanDocker] [-Verbose]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Targets:" -ForegroundColor Cyan
    Write-Host "  clean        - Clean all build artifacts" -ForegroundColor White
    Write-Host "  compile      - Compile source code only" -ForegroundColor White
    Write-Host "  test         - Run tests only" -ForegroundColor White
    Write-Host "  package      - Create JAR package" -ForegroundColor White
    Write-Host "  docker       - Build Docker image" -ForegroundColor White
    Write-Host "  full         - Clean + Compile + Test + Package + Docker" -ForegroundColor White
    Write-Host "  run          - Run application locally with Maven" -ForegroundColor White
    Write-Host "  docker-run   - Run application with Docker Compose" -ForegroundColor White
    Write-Host "  help         - Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Profiles:" -ForegroundColor Cyan
    Write-Host "  development  - Development profile (default)" -ForegroundColor White
    Write-Host "  production   - Production profile" -ForegroundColor White
    Write-Host "  test         - Test profile" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -SkipTests   - Skip running tests during package/full build" -ForegroundColor White
    Write-Host "  -CleanDocker - Clean Docker artifacts during clean target" -ForegroundColor White
    Write-Host "  -Verbose     - Enable verbose Maven output" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  .\build.ps1 -Target full                    # Full build with tests" -ForegroundColor Gray
    Write-Host "  .\build.ps1 -Target package -SkipTests      # Quick package without tests" -ForegroundColor Gray
    Write-Host "  .\build.ps1 -Target run -Profile production # Run in production mode" -ForegroundColor Gray
    Write-Host "  .\build.ps1 -Target docker-run              # Run with Docker Compose" -ForegroundColor Gray
    Write-Host ""
}

# =============================================================================
# Pre-flight Checks
# =============================================================================
function Test-Prerequisites {
    Write-Header "Checking Prerequisites"
    
    $allGood = $true
    
    # Check Java
    if (-not (Test-Command "java")) {
        Write-Error "Java not found in PATH"
        $allGood = $false
    } elseif (-not (Test-JavaVersion)) {
        $allGood = $false
    }
    
    # Check Maven
    if (-not (Test-Command "mvn")) {
        Write-Error "Maven not found in PATH"
        $allGood = $false
    } else {
        Write-Step "Maven found"
    }
    
    # Check Docker (only if docker targets)
    if ($Target -in @("docker", "docker-run", "full")) {
        if (-not (Test-Command "docker")) {
            Write-Error "Docker not found in PATH (required for docker targets)"
            $allGood = $false
        } else {
            Write-Step "Docker found"
        }
    }
    
    # Check project structure
    if (-not (Test-Path "pom.xml")) {
        Write-Error "pom.xml not found. Are you in the correct directory?"
        $allGood = $false
    } else {
        Write-Step "Project structure verified"
    }
    
    if (-not $allGood) {
        Write-Error "Prerequisites not met. Exiting."
        exit 1
    }
    
    Write-Success "All prerequisites met"
}

# =============================================================================
# Main Execution
# =============================================================================
function Main {
    # Change to project directory
    Set-Location $PROJECT_DIR
    
    Write-Header "iTech Backend Build System"
    Write-Host "Target: $Target" -ForegroundColor Cyan
    Write-Host "Profile: $Profile" -ForegroundColor Cyan
    Write-Host "Directory: $(Get-Location)" -ForegroundColor Cyan
    
    # Check prerequisites for non-help targets
    if ($Target -ne "help") {
        Test-Prerequisites
    }
    
    # Execute target
    $startTime = Get-Date
    
    switch ($Target) {
        "clean" {
            Invoke-Clean
        }
        "compile" {
            Invoke-Compile
        }
        "test" {
            Invoke-Test
        }
        "package" {
            Invoke-Package
        }
        "docker" {
            Invoke-DockerBuild
        }
        "full" {
            Invoke-Clean
            Invoke-Compile
            if (-not $SkipTests) {
                Invoke-Test
            }
            Invoke-Package
            Invoke-DockerBuild
        }
        "run" {
            Invoke-Run
        }
        "docker-run" {
            Invoke-DockerRun
        }
        "help" {
            Show-Help
            return
        }
        default {
            Write-Error "Unknown target: $Target"
            Show-Help
            exit 1
        }
    }
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Header "Build Completed"
    Write-Success "Target '$Target' completed in $($duration.TotalSeconds) seconds"
    
    # Show next steps
    if ($Target -eq "package") {
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "  • Run application: .\build.ps1 -Target run -Profile $Profile" -ForegroundColor Gray
        Write-Host "  • Build Docker image: .\build.ps1 -Target docker" -ForegroundColor Gray
        Write-Host "  • Run with Docker: .\build.ps1 -Target docker-run" -ForegroundColor Gray
    }
    elseif ($Target -eq "docker") {
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "  • Run with Docker Compose: .\build.ps1 -Target docker-run" -ForegroundColor Gray
        Write-Host "  • Run Docker image directly: docker run -p 8080:8080 $DOCKER_IMAGE" -ForegroundColor Gray
    }
    elseif ($Target -eq "full") {
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "  • Run with Docker Compose: .\build.ps1 -Target docker-run" -ForegroundColor Gray
        Write-Host "  • Run locally: .\build.ps1 -Target run -Profile $Profile" -ForegroundColor Gray
    }
}

# =============================================================================
# Error Handling
# =============================================================================
trap {
    Write-Error "Build script failed: $_"
    exit 1
}

# =============================================================================
# Execute Main Function
# =============================================================================
try {
    Main
}
catch {
    Write-Error "Unexpected error: $_"
    exit 1
}
