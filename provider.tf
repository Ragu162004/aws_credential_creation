provider "aws" {
  region = "us-east-1"
  profile = "terraform-aws"
}


resource "aws_vpc" "vpc_id" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "Terraform_VPC"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc_id.id

  tags = {
    Name = "Terraform-internet-gateway"
  }
}

resource "aws_subnet" "public-subnets" {
  vpc_id = aws_vpc.vpc_id.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "TerraformPublicSubnets"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc_id.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    Name = "Terraform-public-route-table"
  }
}

resource "aws_route_table_association" "public-subnet-route-table-association" {
  subnet_id = aws_subnet.public-subnets.id
  route_table_id = aws_route_table.public-route-table.id

}

resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.vpc_id.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Terraform-private-subnet"
  }
}


resource "aws_instance" "terraform-Ec2" {
  ami = "ami-0ebf330ebbfac441d"
  instance_type = "t3.micro"

  tags = {
    Name ="terraform-Ec2"
  }
}

resource "aws_security_group" "terraform-sg" {
  name        = "security group using Terraform"
  description = "security group using Terraform"
  vpc_id      = aws_vpc.vpc_id.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "terraform-sg"
  }
}
