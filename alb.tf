module "alb_tf_module" {
  source = "terraform-aws-modules/alb/aws"

  name            = "alb_tf_module"
  vpc_id          = module.vpc_tf_module.vpc_id
  subnets         = module.vpc_tf_module.public_subnets
	security_groups = ["${module.sg_module.security_group_id}"]

  target_groups = {
    ex-instance = {
      name_prefix      = "tg-tf-"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
			targets = {
				my_target = {
					target_id = aws_instance.web.id
					port = 80
				}
			}
    }
  }

  listeners = {
    http_tcp_listener = {
      port                 = 80
      protocol             = "HTTP"
      target_group_index   = 0
    }
  }

  tags = {
    Environment = "Development"
  }
}