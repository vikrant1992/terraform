#!/bin/bash
sudo su
yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on
echo "<html><body><h1>Hello World</h1></body></html>" > /var/www/html/index.html

