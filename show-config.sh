# Quick AWS Configuration Display (matches your format)
# Copy-paste this in CloudShell:

echo "AWS Configuration Details:" && echo "=========================" && echo "Access Key ID: $(aws configure get aws_access_key_id)" && echo "Secret Access Key: $(aws configure get aws_secret_access_key)" && echo "Default Region: $(aws configure get region)" && echo "Default Output Format: $(aws configure get output)" && echo "" && echo "Account Identity:" && aws sts get-caller-identity && echo "" && echo "Current Region Details:" && curl -s http://169.254.169.254/latest/meta-data/placement/region && echo "" && echo "Full Configuration:" && aws configure list
