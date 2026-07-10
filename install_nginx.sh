#!/bin/bash

# Update the package index
sudo apt-get update -y

# Install Nginx
sudo apt-get install nginx -y

# Start and enable Nginx service to run on boot
sudo systemctl start nginx
sudo systemctl enable nginx