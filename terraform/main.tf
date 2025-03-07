provider "aws" {
  region     = "eu-west-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "my_server" {
  ami           = "ami-03fd334507439f4d1"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.My_keypair.key_name
  subnet_id     = aws_subnet.pubsubnet1.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  associate_public_ip_address = true 
  tags = {
    Name = "Terraform1"
  }
}

resource "aws_key_pair" "My_keypair" {
  key_name   = "my-keypair"
  public_key = file("my-key.pem.pub")  
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc1"
  }
}

resource "aws_subnet" "pubsubnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "Tsubnet"
  }
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.my_vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "My_RT"
  }
}

resource "aws_route_table_association" "RT" {
  subnet_id = aws_subnet.pubsubnet1.id 
  route_table_id = aws_route_table.RT.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Tgw"
  }
}

resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
