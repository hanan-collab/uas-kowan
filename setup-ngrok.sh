#!/bin/bash

# Ngrok Setup Script for K3s Passkey App
# This script sets up Ngrok tunnel for HTTPS access

set -e

echo "=========================================="
echo "Setting up Ngrok for Passkey App"
echo "=========================================="

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo "Step 1: Installing Ngrok..."
    
    # Add ngrok repository
    curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
    
    # Install
    sudo apt update
    sudo apt install -y ngrok
    
    echo "Ngrok installed successfully!"
else
    echo "Step 1: Ngrok already installed, skipping..."
fi

echo ""
echo "=========================================="
echo "Ngrok Setup Instructions"
echo "=========================================="
echo ""
echo "1. Go to https://ngrok.com and sign up (FREE)"
echo "2. Get your authtoken from: https://dashboard.ngrok.com/get-started/your-authtoken"
echo "3. Copy your authtoken"
echo ""
read -p "Enter your Ngrok authtoken: " NGROK_TOKEN

if [ -z "$NGROK_TOKEN" ]; then
    echo "Error: Authtoken cannot be empty!"
    exit 1
fi

echo ""
echo "Step 2: Configuring Ngrok with your token..."
ngrok config add-authtoken $NGROK_TOKEN

echo ""
echo "Step 3: Creating systemd service for Ngrok..."

# Create ngrok service file
sudo tee /etc/systemd/system/ngrok.service > /dev/null <<EOF
[Unit]
Description=Ngrok Tunnel Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu
ExecStart=/usr/local/bin/ngrok http 30080 --log stdout
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "Step 4: Starting Ngrok service..."
sudo systemctl daemon-reload
sudo systemctl enable ngrok
sudo systemctl start ngrok

echo ""
echo "Step 5: Waiting for Ngrok to start..."
sleep 5

echo ""
echo "Step 6: Getting Ngrok URL..."
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | cut -d'"' -f4 | head -n1)

if [ -z "$NGROK_URL" ]; then
    echo "Error: Could not get Ngrok URL. Check if Ngrok is running:"
    echo "  sudo systemctl status ngrok"
    echo "  curl http://localhost:4040/api/tunnels"
    exit 1
fi

echo ""
echo "=========================================="
echo "Ngrok Setup Complete!"
echo "=========================================="
echo ""
echo "Your Ngrok URL: $NGROK_URL"
echo ""
echo "Next steps:"
echo "1. Run: bash update-ngrok-url.sh"
echo "2. Access your app at: $NGROK_URL"
echo ""
echo "Useful commands:"
echo "  Check ngrok status: sudo systemctl status ngrok"
echo "  View ngrok logs:    sudo journalctl -u ngrok -f"
echo "  Ngrok web UI:       http://localhost:4040"
echo "  Restart ngrok:      sudo systemctl restart ngrok"
echo ""
