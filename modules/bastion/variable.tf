variable "subnet_id" {
    description = "ID của public subnet"
    type        = string
}

variable "security_group_id" {
    description = "ID của security group cho bastion host"
    type        = string
}

variable "key_name" {
    description = "Tên của SSH key pair trong AWS"
    type        = string
}

variable "instance_type" {
    description = "Loại EC2 instance cho bastion host"
    type        = string
    default     = "t2.micro"
}

variable "project_name" {
    description = "Tên dự án, được sử dụng cho việc đặt tên các resource"
    type        = string
}