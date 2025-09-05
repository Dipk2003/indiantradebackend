#!/bin/bash

# =============================================================================
# iTech Deployment Status Check - AWS CloudShell Commands
# =============================================================================

echo "🔍 Checking iTech AWS Deployment Status..."
echo "=========================================="

# Set region
export AWS_DEFAULT_REGION=ap-south-1

echo ""
echo "🔧 BACKEND DEPLOYMENT STATUS (Elastic Beanstalk)"
echo "================================================"

# Check if Elastic Beanstalk application exists
echo "📋 Checking Elastic Beanstalk applications..."
aws elasticbeanstalk describe-applications --application-names itech-backend

echo ""
echo "🌐 Checking Elastic Beanstalk environments..."
aws elasticbeanstalk describe-environments --application-name itech-backend

# Get environment status
echo ""
echo "📊 Environment Health Status..."
aws elasticbeanstalk describe-environment-health --environment-name itech-backend-prod --attribute-names All

# Get application URL
echo ""
echo "🌍 Getting Backend URL..."
aws elasticbeanstalk describe-environments \
    --application-name itech-backend \
    --environment-names itech-backend-prod \
    --query 'Environments[0].CNAME' \
    --output text

echo ""
echo "🎨 FRONTEND DEPLOYMENT STATUS (AWS Amplify)"
echo "==========================================="

# Check Amplify apps
echo "📋 Checking Amplify applications..."
aws amplify list-apps --query 'apps[?name==`itech-frontend`]'

# If you know the app ID, check specific app
echo ""
echo "📱 Checking Amplify app details..."
# Replace APP_ID with actual app ID if you know it
# aws amplify get-app --app-id d123456789

echo ""
echo "🗄️ DATABASE STATUS (RDS)"
echo "======================="

# Check RDS instances
echo "📋 Checking RDS instances..."
aws rds describe-db-instances \
    --db-instance-identifier itech-mysql-prod \
    --query 'DBInstances[0].{Status:DBInstanceStatus,Endpoint:Endpoint.Address,Port:Endpoint.Port,Engine:Engine}' \
    --output table

echo ""
echo "☁️ S3 BUCKETS STATUS"
echo "=================="

# Check S3 buckets
echo "📋 Checking S3 buckets..."
aws s3 ls | grep itech

echo ""
echo "🔐 IAM ROLES AND POLICIES"
echo "======================="

# Check IAM roles for EB and Amplify
echo "👤 Checking IAM roles..."
aws iam list-roles --query 'Roles[?contains(RoleName,`aws-elasticbeanstalk`) || contains(RoleName,`amplify`)].RoleName' --output table

echo ""
echo "📊 OVERALL DEPLOYMENT SUMMARY"
echo "============================"

echo "🔧 Backend Services:"
echo "   - Elastic Beanstalk Application: $(aws elasticbeanstalk describe-applications --application-names itech-backend --query 'Applications[0].ApplicationName' --output text 2>/dev/null || echo 'NOT FOUND')"
echo "   - Environment Status: $(aws elasticbeanstalk describe-environments --application-name itech-backend --environment-names itech-backend-prod --query 'Environments[0].Status' --output text 2>/dev/null || echo 'NOT FOUND')"
echo "   - Health Status: $(aws elasticbeanstalk describe-environments --application-name itech-backend --environment-names itech-backend-prod --query 'Environments[0].Health' --output text 2>/dev/null || echo 'NOT FOUND')"

echo ""
echo "🎨 Frontend Services:"
echo "   - Amplify App Count: $(aws amplify list-apps --query 'length(apps)' --output text 2>/dev/null || echo '0')"

echo ""
echo "🗄️ Database Services:"
echo "   - RDS Instance Status: $(aws rds describe-db-instances --db-instance-identifier itech-mysql-prod --query 'DBInstances[0].DBInstanceStatus' --output text 2>/dev/null || echo 'NOT FOUND')"

echo ""
echo "✅ Status check completed!"
echo ""
echo "📝 Next Steps:"
echo "   1. If backend is not deployed: Use Elastic Beanstalk console to deploy"
echo "   2. If frontend is not deployed: Use Amplify console to deploy"
echo "   3. If database is not created: Use RDS console to create MySQL instance"
