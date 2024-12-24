# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Change to your preferred region
}
 
# Generate a new SSH Key Pair
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
 
resource "aws_key_pair" "generated_key" {
  key_name   = "web-server-key"
  public_key = tls_private_key.example.public_key_openssh
}
 
 
# Create a Security Group
resource "aws_security_group" "web_sg" {
  name_prefix = "web-server-sg-"
 
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
 
  tags = {
    Name = "web-server-sg"
  }
}
 
# Provision an EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-01816d07b1128cd2d" 
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
 
security_groups = [aws_security_group.web_sg.name]
 
  tags = {
    Name = "web-server"
  }
 

 
# Outputs
output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}
 
output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}

