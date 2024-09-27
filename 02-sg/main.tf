module "db" {
  source         = "../../terraform-aws-securitygroup"
  project_name   = var.project_name
  environment    = var.environment
  sg_description = "SG for DB MySQL Instances"
  common_tags    = var.common_tags
  sg_name        = "db"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value # By aws_ssm_parameter we are fetching vpc_id
}

module "backend" {
  source         = "../../terraform-aws-securitygroup"
  project_name   = var.project_name
  environment    = var.environment
  sg_description = "SG for Backend Instances"
  common_tags    = var.common_tags
  sg_name        = "backend"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
}

module "app_alb" {
  source         = "../../terraform-aws-securitygroup"
  project_name   = var.project_name
  environment    = var.environment
  sg_description = "SG for APP ALB Instances"
  common_tags    = var.common_tags
  sg_name        = "app-alb"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
}

module "vpn" {
  source         = "../../terraform-aws-securitygroup"
  project_name   = var.project_name
  environment    = var.environment
  sg_description = "SG for VPN Instances"
  common_tags    = var.common_tags
  sg_name        = "vpn"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  ingress_rules  = var.vpn_sg_rules
}

module "frontend" {
  source         = "../../terraform-aws-securitygroup"
  project_name   = var.project_name
  environment    = var.environment
  sg_description = "SG for Frontend Instances"
  common_tags    = var.common_tags
  sg_name        = "frontend"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
}

module "bastion" {
  source         = "../../terraform-aws-securitygroup"
  project_name   = var.project_name
  environment    = var.environment
  sg_description = "SG for Bostion Instances"
  common_tags    = var.common_tags
  sg_name        = "bastion"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
}

# DB is accepting connections from backend,i-e from backend getting traffic to db
resource "aws_security_group_rule" "db_backend" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.backend.sg_id # source is where you are getting traffic from
  security_group_id        = module.db.sg_id
}

# DB is accepting connections from bastion,i-e from bastion getting traffic to db
resource "aws_security_group_rule" "db_bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.db.sg_id
}

resource "aws_security_group_rule" "db_vpn" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.db.sg_id
}

resource "aws_security_group_rule" "backend_app_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.app_alb.sg_id
  security_group_id        = module.backend.sg_id
}

# app_alb is accepting connections from vpn,i-e from vpn getting traffic to app_alb
resource "aws_security_group_rule" "app_alb_vpn" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id # source is where you are getting traffic from
  security_group_id        = module.app_alb.sg_id
  description              = "VPN traffic"
}

resource "aws_security_group_rule" "app_alb_bastion" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
  security_group_id        = module.app_alb.sg_id
  description              = "bastion traffic"
}

resource "aws_security_group_rule" "app_alb_frontend" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.frontend.sg_id # source is where you are getting traffic from
  security_group_id        = module.app_alb.sg_id
  description              = "frontend traffic"
}


resource "aws_security_group_rule" "backend_vpn_http" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_vpn_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.backend.sg_id
}

resource "aws_security_group_rule" "frontend_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
  security_group_id        = module.frontend.sg_id
}

resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

