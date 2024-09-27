module "bastion" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = local.bastion_name
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  subnet_id              = local.public_subnet_id # convert StringList to list and get first element
  ami                    = data.aws_ami.ami_info.id
  user_data              = file("bastion.sh")

  tags = merge(
    var.common_tags,
    {
      Terraform   = "true"
      Environment = var.environment
      Name        = local.bastion_name
    }
  )
}

