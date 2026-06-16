provider "aws" {
  region = var.region
  
}

variable "region"{}
variable "vpc_cidr_bock"{}
variable "subnet_cidr_block"{}
variable "avalability_zone"{}
variable "env_prefix"{}
variable "myip" {}
variable "instance_type" {}
variable "public_key_location" {}


resource "aws_vpc" "my_app_vpc"{
    cidr_block = var.vpc_cidr_bock
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
    
}

resource "aws_subnet" "my_dev_subnet_1" {
    vpc_id = aws_vpc.my_app_vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avalability_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
        
    }
}

resource "aws_internet_gateway" "myapp_igw"{
    vpc_id = aws_vpc.my_app_vpc.id
    tags = {
        Name = "${var.env_prefix}-igw"
    }
}
/*
resource "aws_route_table" "myapp_route_table"{
    vpc_id = aws_vpc.my_app_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp_igw.id
    }
    tags = {
        Name = "${var.env_prefix}-rtb"
    }
}


resource "aws_route_table_association" "a-rtb_subnet" {
    subnet_id = aws_subnet.my_dev_subnet_1.id
    route_table_id = aws_route_table.myapp_route_table.id

}
*/

resource "aws_default_route_table" "main-rtb"{
    default_route_table_id = aws_vpc.my_app_vpc.default_route_table_id
     route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp_igw.id
    }
    tags = {
        Name = "${var.env_prefix}-main-rtb"
    }
}


resource "aws_default_security_group" "default-sg"{
    
    vpc_id = aws_vpc.my_app_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.myip]
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
        values = ["amzn2-ami-kernel-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

resource "aws_key_pair" "ansible-key" {
    key_name = "ansible-key"
    public_key = file(var.public_key_location)
}


resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    
    subnet_id = aws_subnet.my_dev_subnet_1.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.ansible-key.key_name

    user_data = file("entry-script.sh")
    user_data_replace_on_change = true

    tags = {
        Name = "${var.env_prefix}-server"
    }
}



