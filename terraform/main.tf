provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "AppServer"
  }

  # Use remote-exec to ensure the server is ready for Ansible
  provisioner "remote-exec" {
    inline = [
      "echo 'Server is ready for Ansible'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/hng.pem")
      host        = self.public_ip
    }
  }

  # # Use local-exec to trigger the Ansible playbook after provisioning
  # provisioner "local-exec" {
  #   command = <<EOT
  #     sleep 30 &&
  #     cd ../ansible && \
  #     ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory playbook.yml
  #   EOT
  # }
}

resource "aws_security_group" "app_sg" {
  name_prefix = "app-sg-"

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

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    app_server_ip = aws_instance.app_server.public_ip
  })
  filename = "../ansible/inventory"
}

resource "null_resource" "run_ansible" {
  depends_on = [
    aws_instance.app_server,
  ]

  # Add triggers to ensure ansible runs when instance or IP changes
  triggers = {
    instance_id = aws_instance.app_server.id
  }

  provisioner "local-exec" {
    # Add a small delay to ensure instance is fully ready
    command = <<-EOT
      sleep 30 && \
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/inventory ../ansible/playbook.yml
    EOT
  }
}