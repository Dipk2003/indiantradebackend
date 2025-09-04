# Quick AWS Details - One Command for CloudShell
# Copy-paste this entire line:

echo "🔍 AWS DETAILS:" && echo "===============" && echo "Identity:" && aws sts get-caller-identity && echo "" && echo "Region:" && curl -s http://169.254.169.254/latest/meta-data/placement/region && echo "" && echo "Configuration:" && aws configure list && echo "" && echo "Permissions Test:" && (aws s3 ls >/dev/null 2>&1 && echo "✅ S3: OK" || echo "❌ S3: No access") && (aws ec2 describe-instances --max-items 1 >/dev/null 2>&1 && echo "✅ EC2: OK" || echo "❌ EC2: No access") && (aws iam get-user >/dev/null 2>&1 && echo "✅ IAM: OK" || echo "❌ IAM: No access") && echo "" && echo "All Regions:" && aws ec2 describe-regions --query 'Regions[*].RegionName' --output table
