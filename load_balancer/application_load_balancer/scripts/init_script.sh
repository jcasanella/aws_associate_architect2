#!/bin/bash
sudo yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
EC2AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
echo '<center><h1>This Amazon EC2 instance is located in Availability zone: AZID<h1></center>' > /var/www/index.txt
sed "s/AZID/$EC2AZ" /var/www/index.txt > /var/www/index.html