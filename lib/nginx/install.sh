#!/bin/sh

# Install nginx
apt-get update
apt-get install nginx -y

# Enable Nginx on firewall
# ufw allow 'Nginx HTTP'