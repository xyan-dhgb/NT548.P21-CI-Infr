
variable "vpc_cidr" {
    description = "CIDR block cho VPC"
    type        = string
}

variable "public_subnet_cidr" {
    description = "CIDR block cho public subnet"
    type        = string
}

variable "private_subnet_cidr" {
    description = "CIDR block cho private subnet"
    type        = string
}

variable "availability_zone" {
    description = "Availability zone cho các subnet"
    type        = string
}

variable "project_name" {
    description = "Project name"
    type        = string
}