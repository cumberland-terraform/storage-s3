module "platform" {
  source                = "github.com/cumberland-terraform/platform"

  platform              = var.platform
  hydration             = {
    vpc_query           = false
    subnets_query       = false
    public_sg_query     = false
    private_sg_query    = false
    eks_ami_query       = false
  }
}

module "kms" {
  count                 = local.conditions.provision_key ? 1 : 0
  source                = "github.com/cumberland-terraform/security-kms"

  kms                   = {
      alias_suffix      = var.s3.suffix
  }
  platform              = var.platform
}