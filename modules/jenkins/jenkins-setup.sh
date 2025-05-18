#!/bin/bash

# Cập nhật hệ thống
apt-get update -y
apt-get install -y openjdk-17-jdk curl gnupg2

# Thêm khóa Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Thêm Jenkins repo
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

# Cài Jenkins
apt-get update -y
apt-get install -y jenkins

# Khởi động Jenkins
systemctl enable jenkins
systemctl start jenkins
