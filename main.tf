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
  count                  = 2
  ami                    = data.aws_ssm_parameter.ubuntu_24_04_ami.value
  instance_type          = "t3.small"
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.ssm_and_local_only.id]

  # Install Docker Engine on Ubuntu 24.04
  user_data = file("${path.module}/files/user_data.sh")

  tags = {
    Name = "ubuntu-${count.index + 1}"
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.my_ip]
  }

  # Docker Swarm intra-cluster ports (self-referenced SG)
  ingress {
    description = "Swarm cluster management"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Swarm gossip TCP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Swarm gossip UDP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "Swarm overlay network (VXLAN)"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
