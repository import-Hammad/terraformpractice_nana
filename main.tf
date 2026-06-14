provider "aws" {
  region = var.region
  
}

variable "region"{}
variable "vpc_cidr_bock"{}
variable "subnet_cidr_block"{}
variable "avalability_zone"{}
variable "env_prefix"{}


resource "aws_vpc" "my_app_vpc"{
    cidr_block = var.vpc_cidr_bock
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
    
}

resource "aws_subnet" "my_dev_subnet_1" {
    vpc_id = aws_vpc.my_app_vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = "us-east-1a"
    tags = {
        Name = "${var.env_prefix}-subnet-1"
        
    }
}

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



