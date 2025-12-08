resource "aws_instance" "example" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t2.micro" # free tier eligible
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.ssm_only.id]

  # Install Docker Engine on Amazon Linux 2023
  user_data = <<-EOF
              #!/bin/bash
              set -xe

              # Update system
              dnf update -y

              # Install Docker
              dnf install -y docker

              # Enable + start Docker
              systemctl enable docker
              systemctl start docker

              # Add ec2-user to docker group
              usermod -aG docker ec2-user

              # Apply group changes WITHOUT requiring logout
              # This runs in a safe subshell to avoid breaking cloud-init
              su - ec2-user -c "newgrp docker << 'EONG'
              exit
              EONG"
              EOF

  tags = {
    Name = "ExampleInstance-SSM-Only"
  }
}

# Security group - SSM only
# (no inbound ports open)
resource "aws_security_group" "ssm_only" {
  name        = "ssm-only-sg"
  description = "No inbound; outbound only for SSM and package installs"

  # No ingress block = no inbound allowed

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
