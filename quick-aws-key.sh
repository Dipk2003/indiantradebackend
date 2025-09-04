# Quick AWS Access Key Creator - One Command
# Just copy-paste this entire line in AWS CloudShell:

USERNAME="my-app-user" && aws iam create-user --user-name $USERNAME 2>/dev/null; aws iam attach-user-policy --user-name $USERNAME --policy-arn arn:aws:iam::aws:policy/PowerUserAccess; KEYS=$(aws iam create-access-key --user-name $USERNAME); echo ""; echo "🎉 ACCESS KEY CREATED!"; echo "==================="; echo "Username: $USERNAME"; echo "Access Key ID: $(echo $KEYS | jq -r '.AccessKey.AccessKeyId')"; echo "Secret Key: $(echo $KEYS | jq -r '.AccessKey.SecretAccessKey')"; echo "==================="
