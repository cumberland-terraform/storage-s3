module "platform" {
  source                = "github.com/cumberland-terraform/platform"

  platform              = var.platform
}

module "kms" {
  count                 = local.conditions.provision_key ? 1 : 0
  source                = "github.com/cumberland-terraform/security-kms"

  kms                   = {
      alias_suffix      = var.s3.suffix
  }
  platform              = var.platform
}