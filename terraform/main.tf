# Provider Configuration
provider "aws" {
  region     = "eu-west-1"  # Replace with your desired region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Variables for AWS Credentials
variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

# Create a Public Subnet
resource "aws_subnet" "pubsubnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "pubsubnet1"
  }
}

# Create a Security Group
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id

  # Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-security-group"
  }
}

# Create an EC2 Instance
resource "aws_instance" "my_server" {
  ami           = "ami-03fd334507439f4d1"  # Replace with your desired AMI
  instance_type = "t2.micro"               # Replace with your desired instance type
  subnet_id     = aws_subnet.pubsubnet1.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "Terraform1"
  }
}

# Output the Public IP of the EC2 Instance
output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.my_server.public_ip
}
