# resource "aws_instance" "amazon_linux_2023" {
#   ami                    = data.aws_ssm_parameter.al2023_ami.value
#   instance_type          = "t3.medium" # free tier eligible
#   iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
#   vpc_security_group_ids = [aws_security_group.ssm_and_local_only.id]

#   # Install Docker Engine on Amazon Linux 2023
#   user_data = <<-EOF
#               #!/bin/bash
#               set -xe

#               # Update system
#               dnf update -y

#               # Install Docker
#               dnf install -y docker git vim

#               # Enable + start Docker
#               systemctl enable docker
#               systemctl start docker

#               # Add ec2-user to docker group
#               usermod -aG docker ec2-user

#               # Apply group changes WITHOUT requiring logout
#               # This runs in a safe subshell to avoid breaking cloud-init
#               su - ec2-user -c "newgrp docker << 'EONG'
#               exit
#               EONG"
#               EOF

#   tags = {
#     Name = "amazon_linux_2023"
#   }
# }

resource "aws_instance" "ubuntu" {
  ami                    = data.aws_ssm_parameter.ubuntu_24_04_ami.value
  instance_type          = "t3.medium"
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.ssm_and_local_only.id]

  # Install Docker Engine on Ubuntu 24.04
  user_data = <<-EOF
  #!/bin/bash
  set -xe
  
  # Update system
  apt-get update
  
  # Install Docker
  apt-get install -y docker.io git vim bridge-utils
  
  # Enable + start Docker
  systemctl enable docker
  systemctl start docker
  
  # Add ubuntu user to docker group
  usermod -aG docker ubuntu
  
  # Group changes will take effect on next login; no need to run newgrp in cloud-init
  EOF

  tags = {
    Name = "ubuntu"
  }
}

data "http" "my_ip" {
  url = "https://api.ipify.org"
}

locals {
  # This works when running Terraform locally
  my_ip = "${chomp(data.http.my_ip.response_body)}/32"
}

# Security group - SSM and local ip only
resource "aws_security_group" "ssm_and_local_only" {
  name        = "ssm-and-local-only-sg"
  description = "inbound for local ip only; outbound only for SSM and package installs"

  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
