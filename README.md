# TẠO JENKINS SERVER VÀ SONARQUBE SERVER TRÊN AWS

Đây là project Terraform để tạo môi trường CI/CD trên AWS, bao gồm VPC với public subnet và private subnet, trong đó có bastion host, Jenkins server và SonarQube server.

# Kiến trúc tổng quan

- VPC: Mạng riêng ảo với CIDR block 10.0.0.0/16
- Public Subnet: Chứa bastion host và NAT Gateway (10.0.1.0/24)
- Private Subnet: Chứa Jenkins server và SonarQube server (10.0.2.0/24)
- Internet Gateway: Cho phép giao tiếp với internet từ public subnet
- NAT Gateway: Cho phép các máy chủ trong private subnet kết nối internet
- Security Groups: Kiểm soát luồng traffic vào/ra các máy chủ