provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "TerraVPC"
    }
}

resource "aws_subnet" "pubsubnet1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "pubsubnet2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.ig.id
  }

}

resource "aws_route_table_association" "public-assoc-a" {
  subnet_id      = aws_subnet.pubsubnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "public-assoc-b" {
  subnet_id      = aws_subnet.pubsubnet2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "web_sg" {
  name = "web security group"
  description = "Allow Http connection from MyIp"
  vpc_id = aws_vpc.vpc.id
  ingress {
      to_port   = 80
      from_port = 80
      protocol = "tcp"
      cidr_blocks = ["68.249.2.214/32"]
  }
  egress {
      to_port   = 0
      from_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "nginx1" {
  ami                         = "ami-060903933d816f88b"
  instance_type               = "t2.nano"
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  subnet_id                   = aws_subnet.pubsubnet1.id
  associate_public_ip_address = true 
}

resource "aws_instance" "nginx2" {
  ami                         = "ami-060903933d816f88b"
  instance_type               = "t2.nano"
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  subnet_id                   = aws_subnet.pubsubnet2.id
  associate_public_ip_address = true 
}