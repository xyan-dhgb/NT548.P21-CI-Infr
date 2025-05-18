output "public_ip" {
    description = "Public IP của bastion host"
    value       = aws_instance.bastion.public_ip
}

output "instance_id" {
    description = "ID của bastion host EC2 instance"
    value       = aws_instance.bastion.id
}