output "bastion_public_ip" {
    description = "Public IP của bastion host"
    value       = module.bastion.public_ip
}

output "jenkins_private_ip" {
    description = "Private IP của Jenkins server"
    value       = module.jenkins.private_ip
}

output "sonarqube_private_ip" {
    description = "Private IP của SonarQube server"
    value       = module.sonarqube.private_ip
}

output "ssh_to_bastion_command" {
    description = "Lệnh SSH để kết nối đến bastion host"
    value       = "ssh -i <đường_dẫn_đến_key.pem> ec2-user@${module.bastion.public_ip}"
}

output "ssh_tunnel_jenkins_command" {
    description = "Lệnh tạo SSH tunnel để truy cập Jenkins UI"
    value       = "ssh -i <đường_dẫn_đến_key.pem> -L 8080:${module.jenkins.private_ip}:8080 ubuntu@${module.bastion.public_ip}"
}

output "ssh_tunnel_sonarqube_command" {
    description = "Lệnh tạo SSH tunnel để truy cập SonarQube UI"
    value       = "ssh -i <đường_dẫn_đến_key.pem> -L 9000:${module.sonarqube.private_ip}:9000 ubuntu@${module.bastion.public_ip}"
}

output "jenkins_url" {
    description = "URL để truy cập Jenkins UI sau khi tạo SSH tunnel"
    value       = "http://localhost:8080"
}

output "sonarqube_url" {
    description = "URL để truy cập SonarQube UI sau khi tạo SSH tunnel"
    value       = "http://localhost:9000"
}