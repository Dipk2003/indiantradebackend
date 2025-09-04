#!/bin/bash

# AWS Details Finder for CloudShell
# Copy-paste this script in AWS CloudShell to get all details

echo "🔍 AWS Account & Configuration Details"
echo "====================================="
echo ""

# 1. Current AWS Identity
echo "👤 CURRENT AWS IDENTITY:"
echo "------------------------"
IDENTITY=$(aws sts get-caller-identity 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "Account ID: $(echo $IDENTITY | jq -r '.Account')"
    echo "User ARN: $(echo $IDENTITY | jq -r '.Arn')"
    echo "User ID: $(echo $IDENTITY | jq -r '.UserId')"
else
    echo "❌ Unable to get identity (credentials might be invalid)"
fi
echo ""

# 2. Current Region
echo "🌍 REGION INFORMATION:"
echo "----------------------"
CURRENT_REGION=$(aws configure get region 2>/dev/null)
if [ -z "$CURRENT_REGION" ]; then
    # Try to get from metadata service (works in CloudShell)
    CURRENT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null)
fi
echo "Current Region: ${CURRENT_REGION:-Not configured}"

# Get region description
if [ ! -z "$CURRENT_REGION" ]; then
    REGION_INFO=$(aws ec2 describe-regions --region-names $CURRENT_REGION --query 'Regions[0]' 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "Region Name: $(echo $REGION_INFO | jq -r '.RegionName')"
        echo "Endpoint: $(echo $REGION_INFO | jq -r '.Endpoint')"
        echo "Opt-in Status: $(echo $REGION_INFO | jq -r '.OptInStatus')"
    fi
fi
echo ""

# 3. AWS CLI Configuration
echo "⚙️ AWS CLI CONFIGURATION:"
echo "-------------------------"
echo "Access Key ID: $(aws configure get aws_access_key_id | cut -c1-8)********"
echo "Secret Key: $(aws configure get aws_secret_access_key | cut -c1-8)********"
echo "Region: $(aws configure get region)"
echo "Output Format: $(aws configure get output)"
echo ""

# 4. Available Regions
echo "🗺️ AVAILABLE REGIONS:"
echo "---------------------"
aws ec2 describe-regions --query 'Regions[*].[RegionName,Endpoint]' --output table 2>/dev/null | head -20
echo ""

# 5. Current User/Role Permissions (sample check)
echo "🔐 PERMISSION CHECK:"
echo "--------------------"
echo "Checking basic permissions..."

# Check S3 access
if aws s3 ls > /dev/null 2>&1; then
    echo "✅ S3 Access: Available"
else
    echo "❌ S3 Access: Not available"
fi

# Check EC2 access
if aws ec2 describe-instances --max-items 1 > /dev/null 2>&1; then
    echo "✅ EC2 Access: Available"
else
    echo "❌ EC2 Access: Not available"
fi

# Check IAM access
if aws iam get-user > /dev/null 2>&1; then
    echo "✅ IAM Access: Available"
else
    echo "❌ IAM Access: Not available"
fi

# Check Lambda access
if aws lambda list-functions --max-items 1 > /dev/null 2>&1; then
    echo "✅ Lambda Access: Available"
else
    echo "❌ Lambda Access: Not available"
fi
echo ""

# 6. Environment Variables
echo "🌐 ENVIRONMENT VARIABLES:"
echo "-------------------------"
echo "AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID:+Set (${AWS_ACCESS_KEY_ID:0:8}********)}"
echo "AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY:+Set (${AWS_SECRET_ACCESS_KEY:0:8}********)}"
echo "AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION:-Not set}"
echo "AWS_REGION: ${AWS_REGION:-Not set}"
echo "AWS_PROFILE: ${AWS_PROFILE:-default}"
echo ""

# 7. CloudShell Environment Info
echo "☁️ CLOUDSHELL ENVIRONMENT:"
echo "--------------------------"
echo "Shell: $SHELL"
echo "User: $USER"
echo "Home: $HOME"
echo "PWD: $PWD"
echo "Instance Metadata:"
if curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/instance-id > /dev/null 2>&1; then
    echo "  Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)"
    echo "  Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type 2>/dev/null)"
    echo "  Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null)"
else
    echo "  Instance metadata not available"
fi
echo ""

# 8. Account Limits (optional)
echo "📊 ACCOUNT INFORMATION:"
echo "-----------------------"
# Get account attributes if available
ACCOUNT_ATTRS=$(aws ec2 describe-account-attributes 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "Account Attributes:"
    echo $ACCOUNT_ATTRS | jq -r '.AccountAttributes[] | "  \(.AttributeName): \(.AttributeValues[0].AttributeValue)"' 2>/dev/null || echo "  Unable to parse account attributes"
else
    echo "  Account attributes not accessible"
fi

echo ""
echo "✅ Details gathering completed!"
echo "💾 To save this info: Run this script with '> aws-details.txt' at the end"
