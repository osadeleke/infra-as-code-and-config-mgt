# Load environment variables for sensitive information
variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "ssh_key_name" {}
variable "ssh_private_key_path" {}

# AWS Provider configuration
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create a security group to allow SSH, HTTP, and HTTPS
resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow SSH, HTTP, and HTTPS traffic"

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

# Provision an EC2 instance
resource "aws_instance" "app_server" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  key_name      = var.ssh_key_name
  security_groups = [aws_security_group.allow_traffic.name]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y python3",
      "touch thisfileishere"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = self.public_ip
  }

  tags = {
    Name = "AppServer"
  }
}

# Automatically generate the Ansible inventory file with the dynamic server IP
resource "local_file" "inventory" {
  content = <<EOT
[app]
${aws_instance.app_server.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.ssh_private_key_path}
EOT
  filename = "inventory.ini"
}

# Output the public IP of the server
output "public_ip" {
  value = aws_instance.app_server.public_ip
}
