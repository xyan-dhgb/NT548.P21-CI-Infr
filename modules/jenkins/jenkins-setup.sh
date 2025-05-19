#!/bin/bash

# File: jenkins-setup.sh
# Mục đích: Cài đặt Jenkins tự động trên EC2 instance
# Sử dụng: Chạy như một user-data script trong Terraform

# Cấu hình ghi log
LOGFILE="/var/log/jenkins-setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "$(date): Bắt đầu cài đặt Jenkins..."

# Hàm kiểm tra lỗi
check_error() {
    if [ $? -ne 0 ]; then
        echo "$(date): LỖI - $1"
        exit 1
    else
        echo "$(date): OK - $1"
    fi
}

# Đợi apt lock
wait_for_apt() {
    echo "$(date): Kiểm tra apt lock..."
    while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
        echo "$(date): Đang đợi apt lock được giải phóng..."
        sleep 5
    done
}

# Kiểm tra nếu Jenkins đã được cài đặt
if systemctl is-active --quiet jenkins; then
    echo "$(date): Jenkins đã được cài đặt và đang chạy. Bỏ qua cài đặt."
    exit 0
fi

# Cập nhật hệ thống
wait_for_apt
echo "$(date): Cập nhật package list..."
sudo apt-get update -y
check_error "Cập nhật package list"

# Cài đặt các phụ thuộc
echo "$(date): Cài đặt Java và các phụ thuộc..."
wait_for_apt
sudo apt-get install -y openjdk-17-jdk curl gnupg2
check_error "Cài đặt Java và các phụ thuộc"

# Thêm khóa Jenkins
echo "$(date): Thêm khóa Jenkins..."
sudo curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null
check_error "Thêm khóa Jenkins"

# Thêm Jenkins repo
echo "$(date): Thêm repository Jenkins..."
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
check_error "Thêm repository Jenkins"

# Cài Jenkins
echo "$(date): Cập nhật lại package list..."
wait_for_apt
sudo apt-get update -y
check_error "Cập nhật lại package list"

echo "$(date): Cài đặt Jenkins..."
wait_for_apt
sudo apt-get install -y jenkins
check_error "Cài đặt Jenkins"

# Khởi động Jenkins
echo "$(date): Kích hoạt và khởi động Jenkins..."
sudo systemctl enable jenkins
check_error "Kích hoạt Jenkins service"

sudo systemctl start jenkins
check_error "Khởi động Jenkins service"

# Kiểm tra Jenkins đã chạy
echo "$(date): Kiểm tra Jenkins đã chạy..."
sleep 10
if systemctl is-active --quiet jenkins; then
    echo "$(date): Jenkins đã được cài đặt thành công và đang chạy."
    
    # Hiển thị password ban đầu
    if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
        INITIAL_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
        echo "$(date): Mật khẩu quản trị Jenkins ban đầu: $INITIAL_PASSWORD"
    else
        echo "$(date): Không tìm thấy mật khẩu ban đầu. Có thể Jenkins chưa tạo xong."
    fi  

echo "$(date): Cài đặt Jenkins hoàn tất!"