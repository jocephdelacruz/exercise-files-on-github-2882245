data "aws_ami" "app_ami" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"]  # Bitnami
}

data "aws_vpc" "default" {
  id = "vpc-00613fdde619e4f7b"
}

data "aws_subnet" "snt_2a_pub" {
  id = "subnet-0d477a46d276ecfca"
}

data "aws_key_pair" "tf_kp_sgdevops" {
  key_name           = "sgdevops"
  include_public_key = true
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.tf_sg_default.id]
  subnet_id              = aws_subnet.snt_2a_pub.id
  key_name               = data.aws_key_pair.tf_kp_sgdevops.key_name
  
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "intelyse-dev-ecs"
  }
}

resource "aws_security_group" "tf_sg_default" {
  name = "dev_default"
  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = "intelyse-dev-ecs"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tf_sg_ing_http" {
  security_group_id = aws_security_group.tf_sg_default.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "tf_sg_ing_https" {
  security_group_id = aws_security_group.tf_sg_default.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "tf_sg_ing_ssh" {
  security_group_id = aws_security_group.tf_sg_default.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "tf_sg_egr_all" {
  security_group_id = aws_security_group.tf_sg_default.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}