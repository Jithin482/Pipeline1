terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket482"  # Replace with your S3 bucket name
    key    = "path/to/terraform.tfstate"  # Replace with your desired path
    region = "eu-west-1"                  # Replace with your bucket's region
  }
}

provider "aws" {
  region     = "eu-west-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc1"
  }
}

resource "aws_subnet" "pubsubnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "pubsubnet1"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_server" {
  ami           = "ami-03fd334507439f4d1"  # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pubsubnet1.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "Terraform1"
  }
}
