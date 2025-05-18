#!/bin/bash
# SonarQube Setup Script – Ubuntu Edition
set -e

# 1. Cập nhật hệ thống
sudo apt-get update -y
sudo apt-get upgrade -y

# 2. Cài Java 11
sudo apt-get install -y openjdk-11-jdk

# 3. Cài các tiện ích cần thiết
sudo apt-get install -y git wget htop vim unzip curl gnupg2

# 4. Cấu hình kernel và limit
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=65536" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo tee -a /etc/security/limits.conf > /dev/null <<EOF
* soft nofile 65536
* hard nofile 65536
* soft nproc 4096
* hard nproc 4096
EOF

# 5. Cài đặt PostgreSQL
sudo apt-get install -y postgresql postgresql-contrib libpq-dev

# 6. Cấu hình PostgreSQL user và database cho SonarQube
sudo -u postgres psql <<EOF
CREATE USER sonarqube WITH ENCRYPTED PASSWORD 'sonarqube';
CREATE DATABASE sonarqube OWNER sonarqube;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonarqube;
EOF

# 7. Cấu hình PostgreSQL chỉ listen localhost (nếu cần chỉnh remote thì sửa lại)
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/g" /etc/postgresql/*/main/postgresql.conf
echo "host    sonarqube    sonarqube    127.0.0.1/32    md5" | sudo tee -a /etc/postgresql/*/main/pg_hba.conf
sudo systemctl restart postgresql

# 8. Tải và giải nén SonarQube
SONARQUBE_VERSION="9.9.0.65466"
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONARQUBE_VERSION.zip -P /tmp
sudo unzip /tmp/sonarqube-$SONARQUBE_VERSION.zip -d /opt
sudo mv /opt/sonarqube-$SONARQUBE_VERSION /opt/sonarqube

# 9. Tạo user sonarqube
sudo useradd -r -s /bin/bash sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube

# 10. Cấu hình SonarQube để kết nối PostgreSQL
sudo tee /opt/sonarqube/conf/sonar.properties > /dev/null <<EOL
sonar.jdbc.username=sonarqube
sonar.jdbc.password=sonarqube
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.javaOpts=-server -Xms512m -Xmx512m -XX:+HeapDumpOnOutOfMemoryError
sonar.search.javaOpts=-server -Xms512m -Xmx512m -XX:+HeapDumpOnOutOfMemoryError
sonar.web.host=0.0.0.0
sonar.web.port=9000
EOL

sudo chown sonarqube:sonarqube /opt/sonarqube/conf/sonar.properties

# 11. Tạo service cho SonarQube
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOL
[Unit]
Description=SonarQube service
After=network.target

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

# 12. Khởi động SonarQube
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube

# 13. Log quá trình cài đặt
echo "SonarQube setup completed at $(date)" | sudo tee /var/log/sonarqube_setup.log
