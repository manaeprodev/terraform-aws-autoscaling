### Provider definition

provider "aws" {
  region = "${var.aws_region}"
}

module "discovery" {
  source              = "github.com/Lowess/terraform-aws-discovery"
  aws_region          = var.aws_region
  vpc_name            = var.vpc_name
  ec2_ami_names       = ["ami_resto"]
}
### Module Main

output "discovery" {
  value = module.discovery
}
