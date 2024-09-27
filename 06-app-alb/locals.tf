locals {
  app_alb_name = "${var.project_name}-${var.environment}-app-alb"
}

locals {
  private_subnet_id = element(split(",", data.aws_ssm_parameter.private_subnet_ids.value), 1)
}
