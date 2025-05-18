output "private_ip" {
    description = "Private IP của SonarQube server"
    value       = aws_instance.sonarqube.private_ip
}

output "instance_id" {
    description = "ID của SonarQube EC2 instance"
    value       = aws_instance.sonarqube.id
}