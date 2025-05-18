output "bastion_sg_id" {
    description = "ID của security group cho bastion host"
    value       = aws_security_group.bastion.id
}

output "jenkins_sg_id" {
    description = "ID của security group cho Jenkins server"
    value       = aws_security_group.jenkins.id
}

output "sonarqube_sg_id" {
    description = "ID của security group cho SonarQube server"
    value       = aws_security_group.sonarqube.id
}