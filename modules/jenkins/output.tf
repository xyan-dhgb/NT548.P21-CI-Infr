output "private_ip" {
    description = "Private IP của Jenkins server"
    value       = aws_instance.jenkins.private_ip
}

output "instance_id" {
    description = "ID của Jenkins EC2 instance"
    value       = aws_instance.jenkins.id
}