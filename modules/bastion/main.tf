
# Bastion Host EC2 Instance
resource "aws_instance" "bastion" {
    ami                    = "ami-0f5d1713c9af4fe30"
    instance_type          = var.instance_type
    key_name               = var.key_name
    subnet_id              = var.subnet_id
    vpc_security_group_ids = [var.security_group_id]

    user_data = file("${path.module}/user_data.sh")

    tags = {
        Name = "${var.project_name}-bastion"
    }

    root_block_device {
        volume_size = 8
        volume_type = "gp2"
        encrypted   = true
    }
}