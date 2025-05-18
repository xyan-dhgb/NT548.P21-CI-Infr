provider "aws" {
    
}

# Module Networking
module "networking" {
    source = "./modules/vpc"

    vpc_cidr             = var.vpc_cidr
    public_subnet_cidr   = var.public_subnet_cidr
    private_subnet_cidr  = var.private_subnet_cidr
    availability_zone    = var.availability_zone
    project_name         = var.project_name
}

# Module Security
module "security" {
    source = "./modules/security"

    vpc_id          = module.networking.vpc_id
    project_name    = var.project_name
    workstation_ip  = var.workstation_ip
}

# Module Bastion Host
module "bastion" {
    source = "./modules/bastion"

    subnet_id           = module.networking.public_subnet_id
    security_group_id   = module.security.bastion_sg_id
    key_name            = var.key_name
    instance_type       = var.bastion_instance_type
    project_name        = var.project_name
}

# Module Jenkins
module "jenkins" {
    source = "./modules/jenkins"

    subnet_id           = module.networking.private_subnet_id
    security_group_id   = module.security.jenkins_sg_id
    key_name            = var.key_name
    instance_type       = var.jenkins_instance_type
    project_name        = var.project_name
}

# Module SonarQube
module "sonarqube" {
    source = "./modules/sonarqube"

    subnet_id           = module.networking.private_subnet_id
    security_group_id   = module.security.sonarqube_sg_id
    key_name            = var.key_name
    instance_type       = var.sonarqube_instance_type
    project_name        = var.project_name
}