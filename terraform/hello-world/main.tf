terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public-a1" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "main-public-a1"
  }

}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public-a1" {
  route_table_id = aws_route_table.main.id
  subnet_id = aws_subnet.public-a1.id
}

resource "aws_security_group" "web" {
  name = "web"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = [
      "68.84.91.65/32"
    ]
    description = "web security group"
  }

  ingress {
    from_port = 80
    protocol  = "tcp"
    to_port   = 80
    cidr_blocks = [
      "68.84.91.65/32"
    ]
    description = "web security group"
  }

  ingress {
    from_port = 8080
    protocol  = "tcp"
    to_port   = 8080
    cidr_blocks = [
      "68.84.91.65/32"
    ]
    description = "web security group"
  }

  ingress {
    from_port = 3000
    protocol  = "tcp"
    to_port   = 3000
    cidr_blocks = [
      "68.84.91.65/32"
    ]
    description = "web security group"
  }

  tags = {
    Name = "web-1"
  }
}

resource "aws_instance" "my-web-1" {
  ami = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"
  key_name = "Laptop"
  subnet_id = aws_subnet.public-a1.id
  security_groups = ["${aws_security_group.web.id}"]
  tags = {
    Name = "my-web-1"
  }
}

