module "alb_tf_module" {
  source = "terraform-aws-modules/alb/aws"

  name            = "alb-tf-module"
  vpc_id          = module.vpc_tf_module.vpc_id
  subnets         = module.vpc_tf_module.public_subnets
	security_groups = ["${module.sg_module.security_group_id}"]

  target_groups = {
    tg-target = {
      name_prefix      = "tg-tf-"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
    }
  }

  listeners = {
    ls-http-tcp = {
      port                 = 80
      protocol             = "HTTP"
      forward = {
        target_group_key = "tg-target"
      }
    }
  }

  tags = {
    Environment = "Development"
  }
}