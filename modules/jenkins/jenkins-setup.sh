#!/bin/bash

while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "Waiting for apt lock to be released..."
    sleep 5
done

# Cập nhật hệ thống
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk curl gnupg2

# Thêm khóa Jenkins
sudo curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Thêm Jenkins repo
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

# Cài Jenkins
sudo apt-get update -y
sudo apt-get install -y jenkins

# Khởi động Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
