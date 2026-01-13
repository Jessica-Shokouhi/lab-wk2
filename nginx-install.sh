#!/bin/bash
# This script installs nginx on the remote EC2 instance

source ./env.sh

ssh -i "$SSH_KEY" "$USERNAME@$SERVER_IP" << 'EOF'
sudo apt update
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
EOF
