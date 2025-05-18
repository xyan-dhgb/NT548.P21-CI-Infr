variable "vpc_id" {
    description = "ID của VPC"
    type        = string
}

variable "workstation_ip" {
    description = "Địa chỉ IP của máy tính cá nhân của bạn để kết nối đến bastion host (định dạng CIDR)"
    type        = string
}

variable "project_name" {
    description = "Tên dự án, được sử dụng cho việc đặt tên các resource"
    type        = string
}
