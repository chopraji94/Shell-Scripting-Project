
# 🛒 E-commerce Application Deployment Script

This repository contains a Bash script to **automate the deployment** of a basic e-commerce application, including its **web server**, **database**, **firewall rules**, and **application source code**.

---

## 📌 Features

- Installs and configures:
  - MariaDB as the backend database
  - Apache HTTP Server with PHP
  - firewalld to open necessary ports
  - Git to clone the e-commerce source code
- Sets up a sample `ecomdb` database with inventory data
- Deploys a PHP-based front-end application from a GitHub repo
- Performs verification checks for:
  - Service status
  - Firewall rules
  - Data loading
  - Web page content

---

## 📁 File List

| File Name                            | Description                          |
|-------------------------------------|--------------------------------------|
| `Ecommerce_Application_Deployement.sh` | Main deployment automation script     |

---

## 🧰 Prerequisites

- OS: RHEL/CentOS based Linux distribution
- User: Run as a user with `sudo` privileges
- Internet access (to install packages and clone GitHub repo)

---

## 🚀 How to Use

1. Clone this repository or upload the `.sh` file to your server:

   ```bash
   git clone <this-repo-url>
   cd <repo-folder>
   ```

2. Make the script executable:

   ```bash
   chmod +x Ecommerce_Application_Deployement.sh
   ```

3. Run the script:

   ```bash
   sudo ./Ecommerce_Application_Deployement.sh
   ```

---

## 🧾 Script Summary

### 1. **Firewall Setup**
- Installs `firewalld`
- Enables ports:
  - `3306` (MariaDB)
  - `80` (HTTP)

### 2. **Database Setup**
- Installs and configures MariaDB
- Creates:
  - Database: `ecomdb`
  - User: `ecomuser`
  - Sample products table and data

### 3. **Web Server Setup**
- Installs Apache HTTP server and PHP
- Updates `httpd.conf` to serve `index.php`
- Clones the app from:
  ```
  https://github.com/kodekloudhub/learning-app-ecommerce.git
  ```
- Updates DB credentials in the PHP app

### 4. **Verification**
- Ensures services are active
- Confirms firewall rules are applied
- Checks web page content for the word `"Laptop"`

---

## 📷 Example Output

```bash
Installing FirewallD...
firewalld service is active
Installing MaraiaDb...
mariadb service is active
Adding Firewall runles for DB...
Port 3306 configured
Configuring DB...
Inventory data is loaded
Configurnig Web Server...
Starting web server...
httpd service is active
Cloning Git Repo...
Item Laptop is present in the web page
All set.
```

---

## 🧑‍💻 Author

**Pranav Chopra**  
📧 Email: [chopraji94@gmail.com](mailto:chopraji94@gmail.com)

---
