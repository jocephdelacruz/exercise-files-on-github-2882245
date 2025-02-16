data "aws_ami" "app_ami" {
  most_recent = true
  
  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_filter.owner]
}

#data "aws_vpc" "default" {
#  id = "vpc-00613fdde619e4f7b"
#}

module "vpc_tf_module" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = "${var.environment.network_prefix}-vpc-tf-module"
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  public_subnets = ["${var.environment.network_prefix}.10.0/24", "${var.environment.network_prefix}.11.0/24", "${var.environment.network_prefix}.12.0/24"]

  tags = {
    Terraform = "true"
    Environment = var.environment.name
  }
}

#data "aws_subnet" "snt_2a_pub" {
#  id = "subnet-0d477a46d276ecfca"
#}

data "aws_key_pair" "tf_kp_sgdevops" {
  key_name           = "sgdevops"
  include_public_key = true
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.sg_module.security_group_id]
  subnet_id              = module.vpc_tf_module.public_subnets[0]
  key_name               = data.aws_key_pair.tf_kp_sgdevops.key_name
  
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.environment.network_prefix}-intelyse-dev-ecs"
  }
}

module "sg_module" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.1"
  name = "${var.environment.network_prefix}-tf-sg-module"
  
  vpc_id = module.vpc_tf_module.vpc_id

  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

#resource "aws_security_group" "tf_sg_default" {
#  name = "dev_default"
#  vpc_id = data.aws_vpc.default.id
#
#  tags = {
#    Name = "intelyse-dev-ecs"
#  }
#}

#resource "aws_vpc_security_group_ingress_rule" "tf_sg_ing_http" {
#  security_group_id = aws_security_group.tf_sg_default.id
#
#  cidr_ipv4   = "0.0.0.0/0"
#  from_port   = 80
#  ip_protocol = "tcp"
#  to_port     = 80
#}

#resource "aws_vpc_security_group_ingress_rule" "tf_sg_ing_https" {
#  security_group_id = aws_security_group.tf_sg_default.id
#
#  cidr_ipv4   = "0.0.0.0/0"
#  from_port   = 443
#  ip_protocol = "tcp"
#  to_port     = 443
#}

#resource "aws_vpc_security_group_ingress_rule" "tf_sg_ing_ssh" {
#  security_group_id = aws_security_group.tf_sg_default.id
#
#  cidr_ipv4   = "0.0.0.0/0"
#  from_port   = 22
#  ip_protocol = "tcp"
#  to_port     = 22
#}

#resource "aws_vpc_security_group_egress_rule" "tf_sg_egr_all" {
#  security_group_id = aws_security_group.tf_sg_default.id
#  cidr_ipv4         = "0.0.0.0/0"
#  ip_protocol       = "-1" # semantically equivalent to all ports
#}