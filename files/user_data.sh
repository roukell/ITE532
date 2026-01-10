#!/bin/bash
set -xe
  
# Update system
sudo apt-get update
  
# Install Docker
sudo apt-get install -y docker.io git vim bridge-utils ca-certificates curl gnupg
# Enable + start Docker
systemctl enable docker
systemctl start docker

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-compose-plugin
docker compose version
  
# Add ubuntu user to docker group
usermod -aG docker ubuntu
