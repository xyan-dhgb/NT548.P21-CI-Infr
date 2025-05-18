# Security Group cho Bastion Host
resource "aws_security_group" "bastion" {
    name        = "${var.project_name}-bastion-sg"
    description = "Security group cho bastion host"
    vpc_id      = var.vpc_id

    # Cho phép SSH từ địa chỉ IP máy tính cá nhân
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks =  ["0.0.0.0/0"]
        description = "SSH from personal workstation"
    }

    # Cho phép tất cả traffic đi ra
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Outbound traffic"
    }

    tags = {
        Name = "${var.project_name}-bastion-sg"
    }
}

# Security Group cho Jenkins Server
resource "aws_security_group" "jenkins" {
    name        = "${var.project_name}-jenkins-sg"
    description = "Security group cho Jenkins server"
    vpc_id      = var.vpc_id

    # Cho phép SSH từ bastion host
    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        security_groups = [aws_security_group.bastion.id]
        description     = "SSH from bastion host"
    }

    # Cho phép traffic đến cổng Jenkins (8080) từ bastion host
    ingress {
        from_port       = 8080
        to_port         = 8080
        protocol        = "tcp"
        security_groups = [aws_security_group.bastion.id]
        description     = "Jenkins Web UI from bastion host"
    }

    # Cho phép traffic đến cổng JNLP (50000) từ private subnet
    ingress {
        from_port   = 50000
        to_port     = 50000
        protocol    = "tcp"
        cidr_blocks = ["10.0.2.0/24"]
        description = "Jenkins JNLP from private subnet"
    }

    # Cho phép tất cả traffic đi ra
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Outbound traffic"
    }

    tags = {
        Name = "${var.project_name}-jenkins-sg"
    }
}

# Security Group cho SonarQube Server
resource "aws_security_group" "sonarqube" {
    name        = "${var.project_name}-sonarqube-sg"
    description = "Security group for SonarQube server"
    vpc_id      = var.vpc_id

    # Cho phép SSH từ bastion host
    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        security_groups = [aws_security_group.bastion.id]
        description     = "SSH from bastion host"
    }

    # Cho phép traffic đến cổng SonarQube (9000) từ bastion host
    ingress {
        from_port       = 9000
        to_port         = 9000
        protocol        = "tcp"
        security_groups = [aws_security_group.bastion.id]
        description     = "SonarQube Web UI from bastion host"
    }

    # Cho phép traffic đến cổng SonarQube (9000) từ Jenkins server
    ingress {
        from_port       = 9000
        to_port         = 9000
        protocol        = "tcp"
        security_groups = [aws_security_group.jenkins.id]
        description     = "SonarQube Web UI from Jenkins server"
    }

    # Cho phép tất cả traffic đi ra
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Outbound traffic"
    }

    tags = {
        Name = "${var.project_name}-sonarqube-sg"
    }
}