resource "aws_default_security_group" "default-sg"{
    
    vpc_id = var.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []

    }
    tags = {
        Name = "${var.env_prefix}-default-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image"{
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = [var.image_name]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}



resource "aws_key_pair" "ansible-key" {
    key_name = "ansible-key"
    public_key = file(var.public_key_location)
}


resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.ansible-key.key_name

    user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y docker
                systemctl start docker
                systemctl enable docker
                usermod -aG docker ec2-user
                docker run -d -p 8080:80 nginx
                EOF
    user_data_replace_on_change = true

    tags = {
        Name = "${var.env_prefix}-server"
    }
}