variable "aws_region" {
    description = "AWS region để triển khai cơ sở hạ tầng"
    type        = string
    default     = "ap-southeast-2"
}

variable "vpc_cidr" {
    description = "CIDR block cho VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR block cho public subnet"
    type        = string
    default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR block cho private subnet"
    type        = string
    default     = "10.0.2.0/24"
}

variable "availability_zone" {
    description = "Availability zone cho các subnet"
    type        = string
    default     = "ap-southeast-2a"
}

variable "workstation_ip" {
    description = "Địa chỉ IP của máy tính cá nhân của bạn để kết nối đến bastion host (định dạng CIDR)"
    type        = string
}

variable "key_name" {
    description = "Tên của SSH key pair trong AWS để kết nối đến các instance"
    type        = string
}

variable "bastion_instance_type" {
    description = "Loại EC2 instance cho bastion host"
    type        = string
    default     = "t2.micro"
}

variable "jenkins_instance_type" {
    description = "Loại EC2 instance cho Jenkins server"
    type        = string
    default     = "t2.small"
}

variable "sonarqube_instance_type" {
    description = "Loại EC2 instance cho SonarQube server"
    type        = string
    default     = "t2.medium"
}

variable "project_name" {
    description = "Tên dự án, được sử dụng cho việc đặt tên các resource"
    type        = string
    default     = "devops-project"
}