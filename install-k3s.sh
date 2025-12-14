#!/bin/bash

# K3s Installation Script for EC2
# This script installs K3s (Lightweight Kubernetes) on Ubuntu EC2 instance

set -e

echo "=========================================="
echo "Installing K3s on Ubuntu EC2"
echo "=========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo: sudo bash install-k3s.sh"
    exit 1
fi

# Update system
echo "Step 1: Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install required packages
echo "Step 2: Installing required packages..."
apt-get install -y curl git

# Install Docker (if not already installed)
if ! command -v docker &> /dev/null; then
    echo "Step 3: Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker ubuntu
else
    echo "Step 3: Docker already installed, skipping..."
fi

# Install K3s
echo "Step 4: Installing K3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--docker" sh -

# Wait for K3s to be ready
echo "Step 5: Waiting for K3s to be ready..."
sleep 10

# Check K3s status
systemctl status k3s --no-pager

# Set up kubectl for ubuntu user
echo "Step 6: Setting up kubectl for ubuntu user..."
mkdir -p /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config
chmod 600 /home/ubuntu/.kube/config

# Add kubectl alias
if ! grep -q "alias kubectl" /home/ubuntu/.bashrc; then
    echo "alias kubectl='sudo k3s kubectl'" >> /home/ubuntu/.bashrc
fi

# Test kubectl
echo "Step 7: Testing kubectl..."
sudo k3s kubectl get nodes

echo ""
echo "=========================================="
echo "K3s Installation Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Logout and login again to apply group changes"
echo "2. Test with: kubectl get nodes"
echo "3. Run deployment script: bash deploy.sh"
echo ""
