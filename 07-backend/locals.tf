locals {
  backend_name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
}

locals {
  private_subnet_id = element(split(",", data.aws_ssm_parameter.private_subnet_ids.value), 0)
}
