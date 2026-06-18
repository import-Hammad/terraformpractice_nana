provider "aws" {
  region = var.region
  
}




resource "aws_vpc" "my_app_vpc"{
    cidr_block = var.vpc_cidr_bock
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
    
}

module "myapp-subnet" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.my_app_vpc.id
    avalability_zone = var.avalability_zone
    default_route_table_id = aws_vpc.my_app_vpc.default_route_table_id
}


module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.my_app_vpc.id
    my_ip = var.myip
    env_prefix = var.env_prefix
    image_name = var.image_name
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    subnet_id = module.myapp-subnet.subnet.id
    

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








