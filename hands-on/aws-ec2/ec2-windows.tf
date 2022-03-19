############################################# LUCAS OMENA #############################################

# HANDS-ON LABS
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs

#######################################################################################################

resource "aws_instance" "ec2_windows" {
  count = var.ec2_os == "w" ? 1 : 0

  ami                         = data.aws_ami.instance_ami.image_id
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile != "" ? var.iam_instance_profile : null
  get_password_data           = var.get_password_data
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.subnet.id
  vpc_security_group_ids      = data.aws_security_group.sg[*].id
  associate_public_ip_address = true
  private_ip                  = length(var.private_ip) > 0 ? element(var.private_ip, count.index) : null
  monitoring                  = true
  tenancy                     = var.tenancy
  disable_api_termination     = true

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size == "" ? 8 : var.root_volume_size
    iops                  = var.root_volume_type == "io1" ? var.root_iops : 0
    delete_on_termination = true
    encrypted             = true
  }

  user_data = var.user_data
  tags = {
    "Name"             = "${local.ec2_name}",
    "Environment"      = "${local.environment}",
    "Operating System" = var.ec2_os == "w" ? "Windows" : "Linux"
  }

  volume_tags = {
    "Name"             = join("", [local.ec2_name, "-root-volume"]),
    "Environment"      = "${local.environment}",
    "Operating System" = var.ec2_os == "w" ? "Windows" : "Linux"
  }

  depends_on = [
    data.aws_ami.instance_ami,
    data.aws_vpc.vpc,
    data.aws_subnet.subnet,
    data.aws_security_group.sg
  ]
}

