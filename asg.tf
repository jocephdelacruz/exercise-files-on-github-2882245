module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "7.4.0"
  
  name = "asg-tf-dev"
  min_size            = 1
  max_size            = 2
	desired_capacity    = 1

	vpc_zone_identifier    = module.vpc_tf_module.public_subnets
	security_groups        = ["${module.sg_module.security_group_id}"]
	key_name               = data.aws_key_pair.tf_kp_sgdevops.key_name

	#launch template
	image_id               = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp3"
      }
    }
  ]

	target_group_arns   = ["${module.alb_tf_module.target_groups.tg-target.arn}"]
}