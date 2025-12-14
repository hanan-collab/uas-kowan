#!/bin/bash

# Update Deployment with Ngrok URL
# This script updates K8s deployment with current Ngrok URL

set -e

echo "=========================================="
echo "Updating Deployment with Ngrok URL"
echo "=========================================="

# Get Ngrok URL from API
echo "Step 1: Getting Ngrok URL..."
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | cut -d'"' -f4 | head -n1)

if [ -z "$NGROK_URL" ]; then
    echo "Error: Could not get Ngrok URL!"
    echo "Make sure Ngrok is running: sudo systemctl status ngrok"
    echo "Or check: curl http://localhost:4040/api/tunnels"
    exit 1
fi

echo "Ngrok URL: $NGROK_URL"

# Extract domain from URL (without https://)
NGROK_DOMAIN=$(echo $NGROK_URL | sed 's|https://||')

echo "Ngrok Domain: $NGROK_DOMAIN"

# Update deployment YAML
echo ""
echo "Step 2: Updating deployment configuration..."

# Backup current deployment
cp k8s/app-deployment.yaml k8s/app-deployment.yaml.bak

# Update RP_ID and ORIGIN
sudo k3s kubectl set env deployment/passkey-app \
    RP_ID="$NGROK_DOMAIN" \
    ORIGIN="$NGROK_URL" \
    -n passkey-tutorial

echo ""
echo "Step 3: Restarting application..."
sudo k3s kubectl rollout restart deployment/passkey-app -n passkey-tutorial

echo ""
echo "Step 4: Waiting for pods to be ready..."
sudo k3s kubectl rollout status deployment/passkey-app -n passkey-tutorial

echo ""
echo "=========================================="
echo "Update Complete!"
echo "=========================================="
echo ""
echo "Access your application at:"
echo "  $NGROK_URL"
echo ""
echo "Note: Ngrok free tier URLs change on restart!"
echo "If you restart ngrok, run this script again."
echo ""
