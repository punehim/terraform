provider "aws" {
    region = "us-east-1"
}

variable "subnet_cidr_block" {
    description = "subnet cidr block"
  
}

variable "vpc-cidr-block" {
    description = "dev vpc cidr block"
  
}

variable "environment" {
    description = "deployment environment"
  
}

variable "subnet-environment" {
    description = "subnet environment"
  
}


resource "aws_vpc" "development-vpc" {
    cidr_block = var.vpc-cidr-block

    tags = {
        Name: var.environment
    }
    
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = "us-east-1a"

    tags = {
        Name: var.subnet-environment
    }
}


output "dev-vpc-id" {
    value = "aws_vpc.development-vpc.id"
  
}

output "dev-subnet-id" {
    value = "aws_subnet.dev-subnet-1.id"
  
}