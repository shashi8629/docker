#!/bin/sh
#this script installs nginx in ubny

chmod +x nginx.sh 
sudo apt-get update -y
sudo apt-get install -y nginx > /tmp/log_nginx.log
