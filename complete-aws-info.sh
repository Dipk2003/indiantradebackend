#!/bin/bash

# Complete AWS Information Gatherer
# Copy-paste this in AWS CloudShell

echo "🔍 COMPLETE AWS INFORMATION"
echo "=========================="
echo ""

# 1. AWS CLI Configuration (like your local setup)
echo "⚙️ AWS CLI CONFIGURATION:"
echo "-------------------------"
echo "Access Key ID: $(aws configure get aws_access_key_id)"
echo "Secret Access Key: $(aws configure get aws_secret_access_key | head -c 20)..."
echo "Default Region: $(aws configure get region)"
echo "Default Output Format: $(aws configure get output)"
echo ""

# 2. Current AWS Identity & Account Info
echo "👤 AWS ACCOUNT IDENTITY:"
echo "------------------------"
IDENTITY=$(aws sts get-caller-identity)
ACCOUNT_ID=$(echo $IDENTITY | jq -r '.Account')
USER_ARN=$(echo $IDENTITY | jq -r '.Arn')
USER_ID=$(echo $IDENTITY | jq -r '.UserId')

echo "Account ID: $ACCOUNT_ID"
echo "User ARN: $USER_ARN"
echo "User ID: $USER_ID"
echo "User Type: $(echo $USER_ARN | cut -d':' -f5 | cut -d'/' -f1)"
echo ""

# 3. Region Information
echo "🌍 REGION DETAILS:"
echo "------------------"
CONFIGURED_REGION=$(aws configure get region)
CURRENT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null || echo $CONFIGURED_REGION)

echo "Configured Region: $CONFIGURED_REGION"
echo "Current CloudShell Region: $CURRENT_REGION"

# Get region description
if [ ! -z "$CURRENT_REGION" ]; then
    REGION_INFO=$(aws ec2 describe-regions --region-names $CURRENT_REGION 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "Region Name: $(echo $REGION_INFO | jq -r '.Regions[0].RegionName')"
        echo "Region Endpoint: $(echo $REGION_INFO | jq -r '.Regions[0].Endpoint')"
        echo "Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null || echo 'Not available')"
    fi
fi
echo ""

# 4. Complete Configuration List
echo "📋 DETAILED CONFIGURATION:"
echo "--------------------------"
aws configure list
echo ""

# 5. Environment Variables
echo "🌐 ENVIRONMENT VARIABLES:"
echo "-------------------------"
echo "AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID:-'Not set in environment'}"
echo "AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY:+Set in environment}"
echo "AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION:-'Not set'}"
echo "AWS_REGION: ${AWS_REGION:-'Not set'}"
echo "AWS_PROFILE: ${AWS_PROFILE:-'default'}"
echo "AWS_CONFIG_FILE: ${AWS_CONFIG_FILE:-'~/.aws/config'}"
echo "AWS_SHARED_CREDENTIALS_FILE: ${AWS_SHARED_CREDENTIALS_FILE:-'~/.aws/credentials'}"
echo ""

# 6. Account & Service Limits
echo "📊 ACCOUNT INFORMATION:"
echo "-----------------------"
# Account attributes
ACCOUNT_ATTRS=$(aws ec2 describe-account-attributes 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "Account Attributes:"
    echo "$ACCOUNT_ATTRS" | jq -r '.AccountAttributes[] | "  \(.AttributeName): \(.AttributeValues[0].AttributeValue)"' 2>/dev/null
fi

# Service quotas (sample)
echo ""
echo "Service Limits (Sample):"
aws service-quotas get-service-quota --service-code ec2 --quota-code L-1216C47A 2>/dev/null | jq -r '"  EC2 Running On-Demand Instances: \(.Quota.Value)"' || echo "  EC2 limits not accessible"
aws service-quotas get-service-quota --service-code s3 --quota-code L-DC2B2D3D 2>/dev/null | jq -r '"  S3 Buckets per account: \(.Quota.Value)"' || echo "  S3 limits not accessible"
echo ""

# 7. Permission & Access Check
echo "🔐 PERMISSION & ACCESS CHECK:"
echo "-----------------------------"
echo "Testing access to various AWS services..."

# S3 Access
if aws s3 ls > /dev/null 2>&1; then
    S3_BUCKETS=$(aws s3 ls | wc -l)
    echo "✅ S3 Access: Available ($S3_BUCKETS buckets)"
else
    echo "❌ S3 Access: Not available"
fi

# EC2 Access
if aws ec2 describe-instances --max-items 1 > /dev/null 2>&1; then
    EC2_INSTANCES=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text | wc -w)
    echo "✅ EC2 Access: Available ($EC2_INSTANCES instances)"
else
    echo "❌ EC2 Access: Not available"
fi

# IAM Access
if aws iam get-user > /dev/null 2>&1; then
    CURRENT_USER=$(aws iam get-user --query 'User.UserName' --output text)
    echo "✅ IAM Access: Available (Current user: $CURRENT_USER)"
else
    echo "❌ IAM Access: Not available"
fi

# Lambda Access
if aws lambda list-functions --max-items 1 > /dev/null 2>&1; then
    LAMBDA_FUNCTIONS=$(aws lambda list-functions --query 'Functions[*].FunctionName' --output text | wc -w)
    echo "✅ Lambda Access: Available ($LAMBDA_FUNCTIONS functions)"
else
    echo "❌ Lambda Access: Not available"
fi

# CloudFormation Access
if aws cloudformation list-stacks --max-items 1 > /dev/null 2>&1; then
    echo "✅ CloudFormation Access: Available"
else
    echo "❌ CloudFormation Access: Not available"
fi

# RDS Access
if aws rds describe-db-instances --max-items 1 > /dev/null 2>&1; then
    echo "✅ RDS Access: Available"
else
    echo "❌ RDS Access: Not available"
fi
echo ""

# 8. Available Regions
echo "🗺️ ALL AVAILABLE REGIONS:"
echo "-------------------------"
aws ec2 describe-regions --query 'Regions[*].[RegionName,Endpoint]' --output table
echo ""

# 9. CloudShell Specific Information
echo "☁️ CLOUDSHELL ENVIRONMENT:"
echo "--------------------------"
echo "Shell Type: $SHELL"
echo "Current User: $USER"
echo "Home Directory: $HOME"
echo "Current Directory: $PWD"
echo "AWS CLI Version: $(aws --version)"

# Instance metadata
echo ""
echo "Instance Metadata:"
if curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/instance-id > /dev/null 2>&1; then
    echo "  Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
    echo "  Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type)"
    echo "  AMI ID: $(curl -s http://169.254.169.254/latest/meta-data/ami-id)"
    echo "  Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
    echo "  Local IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
else
    echo "  Metadata service not available"
fi
echo ""

# 10. Summary
echo "📝 CONFIGURATION SUMMARY:"
echo "------------------------"
echo "Account ID: $ACCOUNT_ID"
echo "Region: $CURRENT_REGION"
echo "Access Key: $(aws configure get aws_access_key_id | head -c 12)..."
echo "User: $(echo $USER_ARN | sed 's/.*\///')"
echo ""

echo "✅ Complete information gathering finished!"
echo "💾 To save: bash this-script.sh > aws-complete-info.txt"
