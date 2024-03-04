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
  default = true
}

resource "aws_instance" "web" {
  ami  = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.tf_sg_default.id]

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_security_group" "f_sg_default" {
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