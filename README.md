# TẠO JENKINS SERVER VÀ SONARQUBE SERVER TRÊN AWS

Đây là project Terraform để tạo môi trường CI/CD trên AWS, bao gồm VPC với public subnet và private subnet, trong đó có bastion host, Jenkins server và SonarQube server.

## Kiến trúc tổng quan

- VPC: Mạng riêng ảo với CIDR block 10.0.0.0/16
- Public Subnet: Chứa bastion host và NAT Gateway (10.0.1.0/24)
- Private Subnet: Chứa Jenkins server và SonarQube server (10.0.2.0/24)
- Internet Gateway: Cho phép giao tiếp với internet từ public subnet
- NAT Gateway: Cho phép các máy chủ trong private subnet kết nối internet
- Security Groups: Kiểm soát luồng traffic vào/ra các máy chủ

## Triển khai hạ tầng

```bash
# Khởi tạo Terraform
terraform init

# Kiểm tra các thay đổi sẽ được áp dụng
terraform plan

# Áp dụng để tạo hạ tầng
terraform apply
```

## Truy cập các dịch vụ

- **Bastion Host**: Kết nối SSH để truy cập vào các server trong private subnet
- **Jenkins Server**: Sau khi khởi tạo, truy cập Jenkins qua địa chỉ IP private/public (tùy cấu hình) trên port 8080
- **SonarQube Server**: Truy cập qua port 9000

> **Lưu ý:** Đảm bảo Security Group đã mở port 22 (SSH), 8080 (Jenkins), 9000 (SonarQube) cho IP của bạn hoặc dải IP phù hợp.

## Lấy mật khẩu admin Jenkins

Sau khi instance Jenkins khởi động, đăng nhập vào server và lấy mật khẩu admin bằng lệnh:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

## Xóa hạ tầng

Khi không còn sử dụng, bạn có thể xóa toàn bộ tài nguyên bằng lệnh:

```bash
terraform destroy
```

## Tham khảo

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

Nếu bạn cần bổ sung phần nào chi tiết hơn (ví dụ: hướng dẫn cấu hình Jenkins, SonarQube, CI/CD pipeline...), hãy cho mình biết nhé!