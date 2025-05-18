output "vpc_id" {
    description = "ID của VPC"
    value       = aws_vpc.main.id
}

output "public_subnet_id" {
    description = "ID của public subnet"
    value       = aws_subnet.public.id
}

output "private_subnet_id" {
    description = "ID của private subnet"
    value       = aws_subnet.private.id
}

output "nat_gateway_id" {
    description = "ID của NAT Gateway"
    value       = aws_nat_gateway.main.id
}
