#!/bin/bash
apt -y update
apt -y upgrade
apt -y install nginx
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
rm -rf /var/www/html/*
echo "<h2>webserver IP: v1 $myip</h2><br>by terraform ext file" > /var/www/html/index.html
systemctl enable nginx
systemctl start nginx
