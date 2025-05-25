#!/bin/bash

#
# This script automates the deployment if an e-commerce application
# Author: Pranav Chopra
# Email: chopraji94@gmail.com 

####################################################################
# Print a given message in a color
# Arguments:
# Color. eg: red, green
####################################################################
function print_color(){

    case $1 in
        "green") COLOR="\033[0;32m" ;;
        "red") COLOR="\033[0;31m" ;;
        "*") COLOR="\033[0m" ;;
    esac

    echo -e "${COLOR} $2 ${NC}"

}

####################################################################
# Check the status of a given service. Error and exit is not active
# Arguments:
# Service. eg: httpd, firewalld
####################################################################
function check_service_status(){

    is_service_active=$(systemctl is-active $1)

    if [ $is_service_active = "active" ]
    then
        print_color "green" "$1 service is active"
    else
        print_color "red" "$1 service is not active"
        exit 1
    fi
}

####################################################################
# Check if a port is enabled in a firewalld rule
# Arguments:
# Port. eg: 3306, 80
####################################################################
function is_firewalld_rule_configured(){

    firewalld_ports=$(sudo firewall-cmd --list-all --zone=public | grep ports)

    if [[ $firewalld_ports = *$1* ]]
    then
        print_color "green" "Port $1 configured"
    else
        print_color "red" "Port $1 not configured"
        exit 1
    fi
}

####################################################################
# Check if an item is present in a given web page
# Arguments:
# WebPage
# Item
####################################################################

function check_item(){

    if [[ $1 = *$2* ]]
    then 
        print_color "green" "Item $2 is present in the web page"
    else
        print_color "red" "Item $2 is not present in the web page"
    fi
}

# --------------------- DataBase Configuration ---------------------
# Install and configure FirewallD
print_color "green" "Installing FirewallD..."
sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

check_service_status firewalld

# Install and configure MariaDB
print_color "green" "Installing MaraiaDb..." 
sudo yum install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

check_service_status mariadb

# Add FireWallD rules for database
print_color "green" "Adding Firewall runles for DB..."
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 3306

# Configure Database
print_color "green" "Configuring DB..."
cat > configure-db.sql <<-EOF
CREATE DATABASE ecomdb;
CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
FLUSH PRIVILEGES;
EOF

sudo mysql < configure-db.sql

# Load inventory data into Database
print_color "green" "Loading inventory data in DB..."
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

sudo mysql < db-load-script.sql

mysql_db_results=$(sudo mysql -e "use ecomdb; select * from products;")

if [[ $mysql_db_results == *Laptop* ]]
then
    print_color "green" "Inventory data is loaded"
else
    print_color "red" "Inventory data is not loaded"
    exit 1
fi
 
# --------------------- WebServer Configuration ---------------------

# Install apache web server and php
print_color "green" "Configurnig Web Server..."
sudo yum install -y httpd php php-mysqlnd

# Configure FireWall rules for web server
print_color "green" "Configuring FireWallD rules for web server..."
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 3306

sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

# Start and enable httpd service
print_color "green" "Starting web server..."
sudo systemctl start httpd
sudo systemctl enable httpd

check_service_status httpd

# Install GIT and download source code repository
print_color "green" "Cloning Git Repo..."
sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

sudo sed -i "s|\$link *= *mysqli_connect(.*);|\$link = mysqli_connect('localhost', 'ecomuser', 'ecompassword', 'ecomdb');|g" /var/www/html/index.php 

sudo systemctl restart httpd

echo "All set."

web_page=$(curl http://localhost)

check_item "$web_page" Laptop
