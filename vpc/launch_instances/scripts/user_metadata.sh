#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
EC2ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
echo "<center><h1>The instance ID of this Amazon EC2 instance is : ${EC2ID}</h1></center>" > /var/www/html/index.html
