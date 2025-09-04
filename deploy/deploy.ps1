# iTech B2B Marketplace - AWS Deployment Script (PowerShell)
# This script automates the deployment process for both backend and frontend on Windows

param(
    [switch]$SkipInfra,
    [switch]$SkipBackend,
    [switch]$SkipFrontend,
    [switch]$InfraOnly,
    [switch]$BackendOnly,
    [switch]$FrontendOnly,
    [switch]$Help
)

# Color functions
function Write-Info($message) {
    Write-Host "[INFO] $message" -ForegroundColor Blue
}

function Write-Success($message) {
    Write-Host "[SUCCESS] $message" -ForegroundColor Green
}

function Write-Warning($message) {
    Write-Host "[WARNING] $message" -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

# Configuration
$BackendDir = "D:\itech-backend\itech-backend"
$FrontendDir = "C:\Users\Dipanshu pandey\OneDrive\Desktop\itm-main-fronted-main"
$TerraformDir = "$BackendDir\terraform"
$BuildDir = "$BackendDir\build"
$DeploymentBucket = "itech-deployment-artifacts"

function Show-Help {
    Write-Host "Usage: .\deploy.ps1 [OPTIONS]"
    Write-Host "Options:"
    Write-Host "  -SkipInfra       Skip infrastructure deployment"
    Write-Host "  -SkipBackend     Skip backend deployment"
    Write-Host "  -SkipFrontend    Skip frontend deployment"
    Write-Host "  -InfraOnly       Deploy only infrastructure"
    Write-Host "  -BackendOnly     Deploy only backend"
    Write-Host "  -FrontendOnly    Deploy only frontend"
    Write-Host "  -Help            Show this help message"
}

function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    # Check if AWS CLI is installed and configured
    if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
        Write-Error "AWS CLI is not installed. Please install it first."
        exit 1
    }
    
    # Check AWS credentials
    try {
        aws sts get-caller-identity | Out-Null
    }
    catch {
        Write-Error "AWS credentials are not configured. Run 'aws configure' first."
        exit 1
    }
    
    # Check if Terraform is installed
    if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
        Write-Error "Terraform is not installed. Please install it first."
        exit 1
    }
    
    # Check if Java is installed
    if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
        Write-Error "Java is not installed. Please install Java 17 or higher."
        exit 1
    }
    
    # Check if Maven wrapper exists
    if (-not (Test-Path "$BackendDir\mvnw.cmd")) {
        Write-Error "Maven wrapper not found in backend directory."
        exit 1
    }
    
    # Check if Node.js is installed
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Error "Node.js is not installed. Please install Node.js first."
        exit 1
    }
    
    Write-Success "All prerequisites are met!"
}

function Initialize-TerraformBackend {
    Write-Info "Setting up Terraform backend..."
    
    # Create S3 bucket for Terraform state if it doesn't exist
    try {
        aws s3 ls s3://itech-terraform-state | Out-Null
        Write-Info "Terraform state bucket already exists."
    }
    catch {
        Write-Info "Creating Terraform state bucket..."
        aws s3 mb s3://itech-terraform-state --region ap-south-1
        aws s3api put-bucket-versioning --bucket itech-terraform-state --versioning-configuration Status=Enabled
        Write-Success "Terraform state bucket created!"
    }
}

function Deploy-Infrastructure {
    Write-Info "Deploying AWS infrastructure with Terraform..."
    
    Push-Location $TerraformDir
    
    try {
        # Initialize Terraform
        terraform init
        
        # Plan the deployment
        terraform plan -out=tfplan
        
        # Apply the infrastructure
        Write-Info "Applying Terraform configuration..."
        terraform apply tfplan
        
        # Get outputs
        terraform output > ..\terraform-outputs.txt
        
        Write-Success "Infrastructure deployed successfully!"
    }
    finally {
        Pop-Location
    }
}

function Build-Backend {
    Write-Info "Building backend application..."
    
    Push-Location $BackendDir
    
    try {
        # Clean and build the project
        .\mvnw.cmd clean package -DskipTests
        
        # Create build directory if it doesn't exist
        New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
        
        # Copy the built JAR
        $jarFile = Get-ChildItem -Path "target" -Name "itech_backend-*.jar" | Select-Object -First 1
        if ($jarFile) {
            Copy-Item "target\$jarFile" "$BuildDir\application.jar"
        } else {
            Write-Error "Built JAR file not found!"
            exit 1
        }
        
        # Copy Elastic Beanstalk configuration if it exists
        if (Test-Path ".ebextensions") {
            Copy-Item -Recurse ".ebextensions" $BuildDir
        } else {
            Write-Warning ".ebextensions directory not found"
        }
        
        Write-Success "Backend build completed!"
    }
    finally {
        Pop-Location
    }
}

function Deploy-Backend {
    Write-Info "Deploying backend to Elastic Beanstalk..."
    
    Push-Location $BuildDir
    
    try {
        # Create deployment package
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $zipFile = "..\itech-backend-$timestamp.zip"
        
        # Use PowerShell's Compress-Archive
        Compress-Archive -Path ".\*" -DestinationPath $zipFile -Force
        
        # Upload to S3
        aws s3 cp $zipFile s3://$DeploymentBucket/backend/
        
        # Deploy to Elastic Beanstalk
        $ebAppName = "itech-backend"
        $ebEnvName = "itech-backend-prod"
        $versionLabel = "v$timestamp"
        $zipFileName = Split-Path $zipFile -Leaf
        
        # Create application version
        aws elasticbeanstalk create-application-version `
            --application-name $ebAppName `
            --version-label $versionLabel `
            --source-bundle "S3Bucket=$DeploymentBucket,S3Key=backend/$zipFileName"
        
        # Deploy to environment
        aws elasticbeanstalk update-environment `
            --environment-name $ebEnvName `
            --version-label $versionLabel
        
        Write-Success "Backend deployment initiated!"
    }
    finally {
        Pop-Location
    }
}

function Build-Frontend {
    Write-Info "Building frontend application..."
    
    Push-Location $FrontendDir
    
    try {
        # Install dependencies
        npm ci
        
        # Build the application
        npm run build:production
        
        Write-Success "Frontend build completed!"
    }
    finally {
        Pop-Location
    }
}

function Deploy-Frontend {
    Write-Info "Deploying frontend to AWS Amplify..."
    
    Push-Location $FrontendDir
    
    try {
        # Check if Amplify CLI is installed
        if (-not (Get-Command amplify -ErrorAction SilentlyContinue)) {
            Write-Warning "Amplify CLI not found. Please deploy frontend manually through AWS Console."
            Write-Info "Or install Amplify CLI: npm install -g @aws-amplify/cli"
            return
        }
        
        # Initialize Amplify if not already done
        if (-not (Test-Path "amplify\.config\project-config.json")) {
            Write-Info "Initializing Amplify project..."
            amplify init --yes
        }
        
        # Deploy to Amplify
        amplify publish --yes
        
        Write-Success "Frontend deployment completed!"
    }
    finally {
        Pop-Location
    }
}

function Initialize-DatabaseMigrations {
    Write-Info "Setting up database migrations..."
    
    # Get RDS endpoint from Terraform outputs
    Push-Location $TerraformDir
    try {
        $rdsEndpoint = terraform output -raw rds_endpoint 2>$null
        if (-not $rdsEndpoint) {
            Write-Warning "RDS endpoint not found. Skipping database migrations."
            return
        }
        
        Write-Info "Database migrations will run automatically when backend starts up (Flyway)."
        Write-Success "Migration setup completed!"
    }
    finally {
        Pop-Location
    }
}

function Initialize-Monitoring {
    Write-Info "Setting up monitoring and logging..."
    
    # CloudWatch logs are automatically configured via Elastic Beanstalk
    # Additional monitoring setup can be added here
    
    Write-Success "Monitoring setup completed!"
}

function Show-SSLDomainInstructions {
    Write-Info "Configuring SSL and domain..."
    
    Write-Warning "Please configure your domain and SSL certificate manually:"
    Write-Info "1. Add your domain to Route 53"
    Write-Info "2. Request SSL certificate from AWS Certificate Manager"
    Write-Info "3. Configure custom domain in Elastic Beanstalk and Amplify"
    Write-Info "4. Update DNS records to point to AWS resources"
}

# Main execution
function Main {
    if ($Help) {
        Show-Help
        exit 0
    }
    
    Write-Info "Starting iTech B2B Marketplace deployment..."
    
    # Set deployment flags based on parameters
    $deployInfra = -not ($SkipInfra -or $BackendOnly -or $FrontendOnly)
    $deployBackend = -not ($SkipBackend -or $InfraOnly -or $FrontendOnly)
    $deployFrontend = -not ($SkipFrontend -or $InfraOnly -or $BackendOnly)
    
    # Start deployment process
    Test-Prerequisites
    
    if ($deployInfra) {
        Initialize-TerraformBackend
        Deploy-Infrastructure
        Start-Sleep -Seconds 30  # Wait for infrastructure to be ready
    }
    
    if ($deployBackend) {
        Build-Backend
        Deploy-Backend
    }
    
    if ($deployFrontend) {
        Build-Frontend
        Deploy-Frontend
    }
    
    Initialize-DatabaseMigrations
    Initialize-Monitoring
    Show-SSLDomainInstructions
    
    Write-Success "Deployment completed successfully!"
    Write-Info "Please check the AWS Console to verify all services are running correctly."
    Write-Info "Don't forget to configure your custom domain and SSL certificates."
}

# Execute main function
Main
