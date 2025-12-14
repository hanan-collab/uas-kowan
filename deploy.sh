#!/bin/bash

# Deployment Script for Passkey Tutorial App on K3s
# This script builds Docker image and deploys to K3s

set -e

echo "=========================================="
echo "Deploying Passkey Tutorial to K3s"
echo "=========================================="

# Variables
APP_NAME="passkey-tutorial-app"
NAMESPACE="passkey-tutorial"
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo "Detected Public IP: $PUBLIC_IP"

# Check if K3s is running
if ! sudo systemctl is-active --quiet k3s; then
    echo "Error: K3s is not running. Please install K3s first."
    echo "Run: sudo bash install-k3s.sh"
    exit 1
fi

# Build Docker image
echo ""
echo "Step 1: Building Docker image..."
docker build -t $APP_NAME:latest .

# Import image to K3s
echo ""
echo "Step 2: Importing Docker image to K3s..."
docker save $APP_NAME:latest | sudo k3s ctr images import -

# Update RP_ID and ORIGIN in deployment YAML
echo ""
echo "Step 3: Updating deployment configuration..."
sed -i "s|value: \"3.235.222.237\"|value: \"$PUBLIC_IP\"|g" k8s/app-deployment.yaml
sed -i "s|value: \"http://3.235.222.237\"|value: \"http://$PUBLIC_IP\"|g" k8s/app-deployment.yaml

# Apply Kubernetes manifests
echo ""
echo "Step 4: Deploying to Kubernetes..."
sudo k3s kubectl apply -f k8s/namespace.yaml
sudo k3s kubectl apply -f k8s/mysql-secret.yaml
sudo k3s kubectl apply -f k8s/app-secret.yaml
sudo k3s kubectl apply -f k8s/mysql-configmap.yaml
sudo k3s kubectl apply -f k8s/mysql-pv.yaml
sudo k3s kubectl apply -f k8s/mysql-deployment.yaml

echo ""
echo "Step 5: Waiting for MySQL to be ready..."
sudo k3s kubectl wait --for=condition=ready pod -l app=mysql -n $NAMESPACE --timeout=180s

echo ""
echo "Step 6: Deploying application..."
sudo k3s kubectl apply -f k8s/app-deployment.yaml

echo ""
echo "Step 7: Waiting for application to be ready..."
sudo k3s kubectl wait --for=condition=ready pod -l app=passkey-app -n $NAMESPACE --timeout=180s

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Access your application at:"
echo "  http://$PUBLIC_IP:30080"
echo ""
echo "Useful commands:"
echo "  Check pods:    sudo k3s kubectl get pods -n $NAMESPACE"
echo "  Check services: sudo k3s kubectl get svc -n $NAMESPACE"
echo "  View logs:     sudo k3s kubectl logs -f deployment/passkey-app -n $NAMESPACE"
echo "  Restart app:   sudo k3s kubectl rollout restart deployment/passkey-app -n $NAMESPACE"
echo ""
