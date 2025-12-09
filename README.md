# CLI Commands

Run the following in your terminal:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply --auto-approve
terraform destroy --auto-approve
```

## Find the instance ID

Run:

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=ExampleInstance-SSM-Only" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text
```

Copy the printed instance ID.

## Connect with SSM Session Manager

Start a session (replace `<instance-id>` with the copied ID):

```bash
aws ssm start-session --target <instance-id>

# switch user
sudo su - ec2-user
```
