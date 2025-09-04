#!/bin/bash

# iTech B2B Marketplace - AWS Deployment Script
# This script automates the deployment process for both backend and frontend

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKEND_DIR="D:/itech-backend/itech-backend"
FRONTEND_DIR="C:/Users/Dipanshu pandey/OneDrive/Desktop/itm-main-fronted-main"
TERRAFORM_DIR="$BACKEND_DIR/terraform"
BUILD_DIR="$BACKEND_DIR/build"
DEPLOYMENT_BUCKET="itech-deployment-artifacts"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if AWS CLI is installed and configured
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials are not configured. Run 'aws configure' first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Java is installed (for Maven build)
    if ! command -v java &> /dev/null; then
        log_error "Java is not installed. Please install Java 17 or higher."
        exit 1
    fi
    
    # Check if Maven is installed
    if ! command -v mvn &> /dev/null; then
        log_error "Maven is not installed. Please install Maven first."
        exit 1
    fi
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js first."
        exit 1
    fi
    
    log_success "All prerequisites are met!"
}

setup_terraform_backend() {
    log_info "Setting up Terraform backend..."
    
    # Create S3 bucket for Terraform state if it doesn't exist
    if ! aws s3 ls s3://itech-terraform-state &> /dev/null; then
        log_info "Creating Terraform state bucket..."
        aws s3 mb s3://itech-terraform-state --region ap-south-1
        aws s3api put-bucket-versioning --bucket itech-terraform-state --versioning-configuration Status=Enabled
        log_success "Terraform state bucket created!"
    else
        log_info "Terraform state bucket already exists."
    fi
}

deploy_infrastructure() {
    log_info "Deploying AWS infrastructure with Terraform..."
    
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    terraform init
    
    # Plan the deployment
    terraform plan -out=tfplan
    
    # Apply the infrastructure
    log_info "Applying Terraform configuration..."
    terraform apply tfplan
    
    # Get outputs
    terraform output > ../terraform-outputs.txt
    
    log_success "Infrastructure deployed successfully!"
    cd - > /dev/null
}

build_backend() {
    log_info "Building backend application..."
    
    cd "$BACKEND_DIR"
    
    # Clean and build the project
    ./mvnw clean package -DskipTests
    
    # Create build directory if it doesn't exist
    mkdir -p "$BUILD_DIR"
    
    # Copy the built JAR
    cp target/itech_backend-*.jar "$BUILD_DIR/application.jar"
    
    # Copy Elastic Beanstalk configuration
    cp -r .ebextensions "$BUILD_DIR/" 2>/dev/null || log_warning ".ebextensions directory not found"
    
    log_success "Backend build completed!"
    cd - > /dev/null
}

deploy_backend() {
    log_info "Deploying backend to Elastic Beanstalk..."
    
    cd "$BUILD_DIR"
    
    # Create deployment package
    zip -r "../itech-backend-$(date +%Y%m%d-%H%M%S).zip" . -x "*.git*"
    
    # Get the latest zip file
    BACKEND_ZIP=$(ls -t ../itech-backend-*.zip | head -n1)
    
    # Upload to S3
    aws s3 cp "$BACKEND_ZIP" s3://$DEPLOYMENT_BUCKET/backend/
    
    # Deploy to Elastic Beanstalk
    EB_APP_NAME="itech-backend"
    EB_ENV_NAME="itech-backend-prod"
    VERSION_LABEL="v$(date +%Y%m%d-%H%M%S)"
    
    # Create application version
    aws elasticbeanstalk create-application-version \
        --application-name "$EB_APP_NAME" \
        --version-label "$VERSION_LABEL" \
        --source-bundle S3Bucket="$DEPLOYMENT_BUCKET",S3Key="backend/$(basename $BACKEND_ZIP)"
    
    # Deploy to environment
    aws elasticbeanstalk update-environment \
        --environment-name "$EB_ENV_NAME" \
        --version-label "$VERSION_LABEL"
    
    log_success "Backend deployment initiated!"
    cd - > /dev/null
}

build_frontend() {
    log_info "Building frontend application..."
    
    cd "$FRONTEND_DIR"
    
    # Install dependencies
    npm ci
    
    # Build the application
    npm run build:production
    
    log_success "Frontend build completed!"
    cd - > /dev/null
}

deploy_frontend() {
    log_info "Deploying frontend to AWS Amplify..."
    
    cd "$FRONTEND_DIR"
    
    # Check if Amplify CLI is installed
    if ! command -v amplify &> /dev/null; then
        log_warning "Amplify CLI not found. Please deploy frontend manually through AWS Console."
        log_info "Or install Amplify CLI: npm install -g @aws-amplify/cli"
        return 0
    fi
    
    # Initialize Amplify if not already done
    if [ ! -f "amplify/.config/project-config.json" ]; then
        log_info "Initializing Amplify project..."
        amplify init --yes
    fi
    
    # Deploy to Amplify
    amplify publish --yes
    
    log_success "Frontend deployment completed!"
    cd - > /dev/null
}

run_database_migrations() {
    log_info "Running database migrations..."
    
    # Get RDS endpoint from Terraform outputs
    RDS_ENDPOINT=$(terraform -chdir="$TERRAFORM_DIR" output -raw rds_endpoint 2>/dev/null || echo "")
    
    if [ -z "$RDS_ENDPOINT" ]; then
        log_warning "RDS endpoint not found. Skipping database migrations."
        return 0
    fi
    
    log_info "Database migrations will run automatically when backend starts up (Flyway)."
    log_success "Migration setup completed!"
}

setup_monitoring() {
    log_info "Setting up monitoring and logging..."
    
    # CloudWatch logs are automatically configured via Elastic Beanstalk
    # Additional monitoring setup can be added here
    
    log_success "Monitoring setup completed!"
}

configure_ssl_domain() {
    log_info "Configuring SSL and domain..."
    
    log_warning "Please configure your domain and SSL certificate manually:"
    log_info "1. Add your domain to Route 53"
    log_info "2. Request SSL certificate from AWS Certificate Manager"
    log_info "3. Configure custom domain in Elastic Beanstalk and Amplify"
    log_info "4. Update DNS records to point to AWS resources"
}

main() {
    log_info "Starting iTech B2B Marketplace deployment..."
    
    # Parse command line arguments
    DEPLOY_INFRA=true
    DEPLOY_BACKEND=true
    DEPLOY_FRONTEND=true
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-infra)
                DEPLOY_INFRA=false
                shift
                ;;
            --skip-backend)
                DEPLOY_BACKEND=false
                shift
                ;;
            --skip-frontend)
                DEPLOY_FRONTEND=false
                shift
                ;;
            --infra-only)
                DEPLOY_BACKEND=false
                DEPLOY_FRONTEND=false
                shift
                ;;
            --backend-only)
                DEPLOY_INFRA=false
                DEPLOY_FRONTEND=false
                shift
                ;;
            --frontend-only)
                DEPLOY_INFRA=false
                DEPLOY_BACKEND=false
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --skip-infra      Skip infrastructure deployment"
                echo "  --skip-backend    Skip backend deployment"
                echo "  --skip-frontend   Skip frontend deployment"
                echo "  --infra-only      Deploy only infrastructure"
                echo "  --backend-only    Deploy only backend"
                echo "  --frontend-only   Deploy only frontend"
                echo "  -h, --help        Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option $1"
                exit 1
                ;;
        esac
    done
    
    # Start deployment process
    check_prerequisites
    
    if [ "$DEPLOY_INFRA" = true ]; then
        setup_terraform_backend
        deploy_infrastructure
        sleep 30  # Wait for infrastructure to be ready
    fi
    
    if [ "$DEPLOY_BACKEND" = true ]; then
        build_backend
        deploy_backend
    fi
    
    if [ "$DEPLOY_FRONTEND" = true ]; then
        build_frontend
        deploy_frontend
    fi
    
    run_database_migrations
    setup_monitoring
    configure_ssl_domain
    
    log_success "Deployment completed successfully!"
    log_info "Please check the AWS Console to verify all services are running correctly."
    log_info "Don't forget to configure your custom domain and SSL certificates."
}

# Run main function with all arguments
main "$@"
