#!/bin/bash
# SonarQube Setup Script – Ubuntu Edition
# Được tối ưu hóa cho Terraform user-data

# Cấu hình ghi log
LOGFILE="/var/log/sonarqube-setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "$(date): === Bắt đầu cài đặt SonarQube ==="

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

# Kiểm tra nếu SonarQube đã được cài đặt
if systemctl is-active --quiet sonarqube; then
    echo "$(date): SonarQube đã được cài đặt và đang chạy. Bỏ qua cài đặt."
    
    # Hiển thị URL truy cập
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    echo "$(date): SonarQube UI có thể truy cập tại: http://$PUBLIC_IP:9000"
    echo "$(date): Tài khoản mặc định: admin/admin"
    exit 0
fi

# 1. Cập nhật hệ thống
echo "$(date): Cập nhật hệ thống..."
wait_for_apt
sudo apt-get update -y
check_error "Cập nhật package list"

# Chỉ cài đặt các package cần thiết, bỏ qua nâng cấp toàn bộ hệ thống để tăng tốc
echo "$(date): Cài đặt các package cần thiết..."
wait_for_apt
sudo apt-get install -y openjdk-17-jdk git wget unzip curl gnupg2 htop vim
check_error "Cài đặt Java và các tiện ích cần thiết"

# 2. Cấu hình kernel và limit
echo "$(date): Cấu hình kernel parameters..."
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=65536" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
check_error "Cấu hình kernel parameters"

echo "$(date): Cấu hình system limits..."
sudo tee -a /etc/security/limits.conf > /dev/null <<EOF
* soft nofile 65536
* hard nofile 65536
* soft nproc 4096
* hard nproc 4096
EOF
check_error "Cấu hình system limits"

# 3. Cài đặt PostgreSQL
echo "$(date): Cài đặt PostgreSQL..."
wait_for_apt
sudo apt-get install -y postgresql postgresql-contrib libpq-dev
check_error "Cài đặt PostgreSQL"

# Đợi PostgreSQL khởi động
echo "$(date): Đảm bảo PostgreSQL đã hoạt động..."
max_retries=10
retries=0
while ! pg_isready -q && [ $retries -lt $max_retries ]; do
    echo "$(date): Đang đợi PostgreSQL khởi động..."
    sleep 3
    retries=$((retries+1))
done

if [ $retries -eq $max_retries ]; then
    echo "$(date): LỖI - PostgreSQL không khởi động được."
    exit 1
fi

# 4. Cấu hình PostgreSQL user và database cho SonarQube
echo "$(date): Cấu hình PostgreSQL cho SonarQube..."
# Kiểm tra xem database đã tồn tại chưa
DB_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='sonarqube'")
if [ "$DB_EXISTS" != "1" ]; then
    sudo -u postgres psql <<EOF
CREATE USER sonarqube WITH ENCRYPTED PASSWORD 'sonarqube';
CREATE DATABASE sonarqube OWNER sonarqube;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonarqube;
EOF
    check_error "Cấu hình PostgreSQL user và database"
else
    echo "$(date): Database sonarqube đã tồn tại."
fi

# 5. Cấu hình PostgreSQL chỉ listen localhost
echo "$(date): Cấu hình PostgreSQL connection..."
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/g" /etc/postgresql/*/main/postgresql.conf

# Kiểm tra xem cấu hình đã tồn tại chưa
PG_CONFIG_EXISTS=$(grep "host    sonarqube    sonarqube    127.0.0.1/32    md5" /etc/postgresql/*/main/pg_hba.conf || echo "")
if [ -z "$PG_CONFIG_EXISTS" ]; then
    echo "host    sonarqube    sonarqube    127.0.0.1/32    md5" | sudo tee -a /etc/postgresql/*/main/pg_hba.conf
fi

sudo systemctl restart postgresql
check_error "Khởi động lại PostgreSQL"

# 6. Tải và giải nén SonarQube
echo "$(date): Tải SonarQube..."
SONARQUBE_VERSION="9.9.0.65466"
SONARQUBE_DIR="/opt/sonarqube"

# Kiểm tra nếu SonarQube đã được cài đặt
if [ ! -d "$SONARQUBE_DIR" ]; then
    if [ ! -f "/tmp/sonarqube-$SONARQUBE_VERSION.zip" ]; then
        wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONARQUBE_VERSION.zip -P /tmp
        check_error "Tải SonarQube"
    fi
    
    echo "$(date): Giải nén SonarQube..."
    sudo unzip -q /tmp/sonarqube-$SONARQUBE_VERSION.zip -d /opt
    check_error "Giải nén SonarQube"
    
    sudo mv /opt/sonarqube-$SONARQUBE_VERSION /opt/sonarqube
    check_error "Di chuyển thư mục SonarQube"
    
    # Xóa file zip để tiết kiệm không gian
    rm -f /tmp/sonarqube-$SONARQUBE_VERSION.zip
else
    echo "$(date): SonarQube đã được cài đặt tại $SONARQUBE_DIR. Bỏ qua bước cài đặt."
fi

# 7. Tạo user sonarqube nếu chưa tồn tại
echo "$(date): Tạo user sonarqube..."
id -u sonarqube &>/dev/null || sudo useradd -r -s /bin/bash sonarqube
check_error "Tạo user sonarqube"

sudo chown -R sonarqube:sonarqube /opt/sonarqube
check_error "Thiết lập quyền cho thư mục SonarQube"

# 8. Cấu hình SonarQube để kết nối PostgreSQL
echo "$(date): Cấu hình SonarQube..."
sudo tee /opt/sonarqube/conf/sonar.properties > /dev/null <<EOL
sonar.jdbc.username=sonarqube
sonar.jdbc.password=sonarqube
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.javaOpts=-server -Xms512m -Xmx512m -XX:+HeapDumpOnOutOfMemoryError
sonar.search.javaOpts=-server -Xms512m -Xmx512m -XX:+HeapDumpOnOutOfMemoryError
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.path.data=/opt/sonarqube/data
sonar.path.temp=/opt/sonarqube/temp
EOL
check_error "Cấu hình SonarQube"

sudo chown sonarqube:sonarqube /opt/sonarqube/conf/sonar.properties

# 9. Tạo service cho SonarQube
echo "$(date): Tạo systemd service cho SonarQube..."
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOL
[Unit]
Description=SonarQube service
After=syslog.target network.target postgresql.service

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOL
check_error "Tạo systemd service"

# 10. Khởi động SonarQube
echo "$(date): Khởi động SonarQube..."
sudo systemctl daemon-reload
check_error "Reload systemd"

sudo systemctl enable sonarqube
check_error "Enable SonarQube service"

sudo systemctl start sonarqube
check_error "Khởi động SonarQube service"

# 11. Đợi SonarQube khởi động
echo "$(date): Đợi SonarQube khởi động hoàn tất (có thể mất vài phút)..."
max_retries=30
retries=0
while ! curl -s http://localhost:9000 > /dev/null && [ $retries -lt $max_retries ]; do
    echo "$(date): Đang đợi SonarQube khởi động hoàn tất... (${retries}/${max_retries})"
    sleep 10
    retries=$((retries+1))
done

if [ $retries -eq $max_retries ]; then
    echo "$(date): CẢNH BÁO - SonarQube có thể chưa khởi động hoàn tất trong thời gian chờ."
    echo "$(date): Vui lòng kiểm tra logs tại /opt/sonarqube/logs/"
    echo "$(date): hoặc sử dụng lệnh: sudo systemctl status sonarqube"
else
    echo "$(date): SonarQube đã khởi động thành công!"
fi

# 12. Hiển thị thông tin truy cập
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "$(date): === Cài đặt SonarQube hoàn tất ==="
echo "$(date): SonarQube UI có thể truy cập tại: http://$PUBLIC_IP:9000"
echo "$(date): Tài khoản mặc định: admin/admin"
echo "$(date): Hãy đổi mật khẩu ngay khi đăng nhập lần đầu"