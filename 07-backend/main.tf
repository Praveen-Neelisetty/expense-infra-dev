
module "backend" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = local.backend_name
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  subnet_id              = local.private_subnet_id # convert StringList to list and get first element
  ami                    = data.aws_ami.ami_info.id

  tags = merge(
    var.common_tags,
    {
      Terraform   = "true"
      Environment = var.environment
      Name        = local.backend_name
    }
  )
}

resource "null_resource" "backend" {
  triggers = {
    instance_id = module.backend.id # this will be triggered everytime instance is created
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = module.backend.private_ip
  }

  provisioner "file" {                                   # copy file from local to ec2 instance by file provisioner 
    source      = "${var.common_tags.Component}.sh"      # backend.sh
    destination = "/tmp/${var.common_tags.Component}.sh" # /tmp/backend.sh
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/${var.common_tags.Component}.sh",
      "sudo sh /tmp/${var.common_tags.Component}.sh ${var.common_tags.Component} ${var.environment}"
    ]
  }


}
