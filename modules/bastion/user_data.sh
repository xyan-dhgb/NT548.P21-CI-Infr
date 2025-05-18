#!/bin/bash
# Bastion Host Setup Script – Ubuntu edition
set -e  # die on any error

## 1. Cập nhật OS + package list
apt-get update -y
apt-get upgrade -y   # tùy: bỏ nếu không muốn nâng full OS

## 2. Cài vài tool hữu ích
apt-get install -y htop vim git

## 3. Giữ SSH session sống lâu hơn
# (thêm nếu chưa tồn tại, tránh spam trùng dòng)
grep -qxF 'ClientAliveInterval 60' /etc/ssh/sshd_config || \
    echo 'ClientAliveInterval 60' >> /etc/ssh/sshd_config
grep -qxF 'ClientAliveCountMax 120' /etc/ssh/sshd_config || \
    echo 'ClientAliveCountMax 120' >> /etc/ssh/sshd_config

# Khởi động lại dịch vụ SSHD
systemctl restart ssh

## 4. Log lại cho dễ debug
echo "Bastion host setup completed at $(date)" > /var/log/bastion_setup.log
