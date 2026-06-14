provider "aws" {
  region = var.region
  
}

variable "region"{}
variable "cidr_block"{
    type = list(string)
}
variable "environment" {}

resource "aws_vpc" "my_dev_vpc"{
    cidr_block = var.cidr_block[0]
    tags = {
        Name = var.environment
    }
    
}

resource "aws_subnet" "my_dev_subnet_1" {
    vpc_id = aws_vpc.my_dev_vpc.id
    cidr_block = var.cidr_block[1]
    availability_zone = "us-east-1a"
    tags = {
        Name = "development-subnet-1"
        vpc_env = "dev"
    }
}

data "aws_vpc" "existing_vpc" {
    default = true
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id            = data.aws_vpc.existing_vpc.id
    cidr_block        = "172.31.96.0/20"   # ✅ fixed
    availability_zone = "us-east-1c"        # ✅ fixed
    tags = {
        Name = "subnet-2-dev"
    }
}



output "dev-vpc-id" {
    value = aws_vpc.my_dev_vpc.id
}

output "dev-subnet-id" {
    value = aws_subnet.my_dev_subnet_1.id
}