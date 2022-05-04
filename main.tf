provider "aws" {
    region = "us-east-1"
}

variable "subnet_cidr_block" {}
variable "vpc-cidr-block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}

resource "aws_vpc" "development-vpc" {
    cidr_block = var.vpc-cidr-block

    tags = {
        Name: "${var.env_prefix}-vpc"
    }
    
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone

    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}


output "dev-vpc-id" {
    value = "aws_vpc.development-vpc.id"
  
}

output "dev-subnet-id" {
    value = "aws_subnet.dev-subnet-1.id"
  
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.development-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
  
}

resource "aws_route_table" "my_app_route-table" {
    vpc_id = aws_vpc.development-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}

resource "aws_route_table_association" "a-rt-subnet" {
    subnet_id = aws_subnet.dev-subnet-1.id
    route_table_id = aws_route_table.my_app_route-table.id
  
}

resource "aws_security_group" "myapp-sg" {
    name = "mtapp-sg"
    vpc_id = aws_vpc.development-vpc.id

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
        Name: "${var.env_prefix}-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
      
    }
  
}

output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
  
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.dev-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = "terraform.pem"



    tags = {
        Name: "${var.env_prefix}-server"
    }
}

