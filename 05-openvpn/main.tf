resource "aws_key_pair" "vpn" {
  key_name = "deployer-key"
  # you can paste the public key directly like this
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGfxQ/H1UDqQcmGh3FAKjq9pYhaAJg9knR+dKx8TxsMt PRAVEEN@DESKTOP-09SKOBT"
  public_key = file("~/.ssh/openvpn.pub")
  # ~ means windows home directory
}

module "vpn" {
  source = "terraform-aws-modules/ec2-instance/aws"

  key_name               = aws_key_pair.vpn.key_name
  name                   = local.vpn_name
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  subnet_id              = local.public_subnet_id # convert StringList to list and get first element
  ami                    = data.aws_ami.ami_info.id

  tags = merge(
    var.common_tags,
    {
      Terraform   = "true"
      Environment = var.environment
      Name        = local.vpn_name
    }
  )
}

