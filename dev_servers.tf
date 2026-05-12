###############################################################################
# dev_servers.tf
# Two Dev web servers — Ubuntu 20.04 LTS (ami-0a59ec92177ec3fad), t3.micro
###############################################################################

locals {
  ubuntu_userdata_dev1 = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    systemctl enable apache2
    systemctl start apache2
    echo "<h1>DevSrv1 Online</h1>" > /var/www/html/index.html
  EOF

  ubuntu_userdata_dev2 = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    systemctl enable apache2
    systemctl start apache2
    echo "<h1>DevSrv2 Online</h1>" > /var/www/html/index.html
  EOF
}

resource "aws_instance" "dev_srv1" {
  ami                    = var.ubuntu_ami
  instance_type          = "t3.micro"
  key_name               = var.key_pair_name
  subnet_id              = aws_subnet.dev_az1.id
  vpc_security_group_ids = [aws_security_group.web_dev.id]
  monitoring             = true

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = base64encode(local.ubuntu_userdata_dev1)

  tags = {
    Name        = "Dev-Srv-AZ1"
    Environment = "Development"
  }
}

resource "aws_instance" "dev_srv2" {
  ami                    = var.ubuntu_ami
  instance_type          = "t3.micro"
  key_name               = var.key_pair_name
  subnet_id              = aws_subnet.dev_az2.id
  vpc_security_group_ids = [aws_security_group.web_dev.id]
  monitoring             = true

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = base64encode(local.ubuntu_userdata_dev2)

  tags = {
    Name        = "Dev-Srv-AZ2"
    Environment = "Development"
  }
}
