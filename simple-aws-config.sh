# Simple AWS Configuration Display - One Command
# Copy-paste this line in AWS CloudShell:

echo "AWS Configuration:" && echo "==================" && echo "AWS Access Key ID [None]: $(aws configure get aws_access_key_id)" && echo "AWS Secret Access Key [None]: $(aws configure get aws_secret_access_key)" && echo "Default region name [None]: $(aws configure get region)" && echo "Default output format [None]: $(aws configure get output)" && echo "" && echo "Account Identity:" && aws sts get-caller-identity && echo "" && echo "Configuration List:" && aws configure list
