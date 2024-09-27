resource "aws_lb" "app_alb" {
  name               = locals.app_alb_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.app_alb_sg_id.value]
  subnets            = [local.private_subnet_id]

  enable_deletion_protection = false

  tags = merge(
    var.common_tags,
    {
      Name      = locals.app_alb_name
      Component = "app-dev-alb"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1> This is Fixed response from APP ALB </h1>"
      status_code  = "200"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = var.zone_name

  records = [
    {
      name            = "*-app-${var.environment}"
      type            = "A"
      allow_overwrite = true
      alias = {
        name    = aws_lb.app_alb.dns_name
        zone_id = aws_lb.app_alb.zone_id
      }
    }
  ]
}
