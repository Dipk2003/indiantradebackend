#!/bin/bash

# AWS Access Key Creator for CloudShell
# Copy-paste this entire script in AWS CloudShell

echo "🔑 AWS Access Key Creator"
echo "========================="

# Get username input
read -p "Enter IAM username to create (or press Enter for 'developer-user'): " USERNAME
USERNAME=${USERNAME:-developer-user}

echo "Creating IAM user: $USERNAME"

# Create IAM user
aws iam create-user --user-name $USERNAME 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ User created successfully"
else
    echo "⚠️  User might already exist, continuing..."
fi

# Attach PowerUser policy
echo "Attaching PowerUserAccess policy..."
aws iam attach-user-policy \
    --user-name $USERNAME \
    --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Create access key
echo "Creating access key..."
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name $USERNAME)

# Parse and display results
ACCESS_KEY_ID=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.SecretAccessKey')

echo ""
echo "🎉 ACCESS KEY CREATED SUCCESSFULLY!"
echo "=================================="
echo "Username: $USERNAME"
echo "Access Key ID: $ACCESS_KEY_ID"
echo "Secret Access Key: $SECRET_ACCESS_KEY"
echo "=================================="
echo ""

# Save to file
echo "Saving credentials to aws-credentials.txt..."
cat > aws-credentials.txt << EOF
AWS Credentials for $USERNAME
============================
Access Key ID: $ACCESS_KEY_ID
Secret Access Key: $SECRET_ACCESS_KEY

AWS CLI Setup Commands:
aws configure set aws_access_key_id $ACCESS_KEY_ID
aws configure set aws_secret_access_key $SECRET_ACCESS_KEY
aws configure set region us-east-1

Environment Variables:
export AWS_ACCESS_KEY_ID="$ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$SECRET_ACCESS_KEY"
EOF

echo "✅ Credentials saved to aws-credentials.txt"
echo ""
echo "⚠️  IMPORTANT: Keep these credentials secure!"
echo "📁 Use 'cat aws-credentials.txt' to view them again"
