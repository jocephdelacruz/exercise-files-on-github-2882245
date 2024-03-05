module "alb_tf_module" {
  source = "terraform-aws-modules/alb/aws"
	version = "9.7.0"
	
  name            = "alb-tf-module"
  vpc_id          = module.vpc_tf_module.vpc_id
  subnets         = module.vpc_tf_module.public_subnets
	security_groups = ["${module.sg_module.security_group_id}"]

  listeners = {
    ls-http-tcp = {
      port                 = 80
      protocol             = "HTTP"
      forward = {
        target_group_key = "tg-tf-http"
      }
    }
  }

  target_groups = {
    tg-tf-http = {
      name_prefix      = "tg-tf-"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
    }
  }

  tags = {
    Environment = "Development"
  }
}