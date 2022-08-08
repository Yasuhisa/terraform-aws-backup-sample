variable "copy_vault_name" {}
variable "backup_vault_name" {}
variable "iam_role_name" {}
variable "selection_name" {}
variable "plans" {}

# AWS Backup コピー先ボールト
resource "aws_backup_vault" "copy" {
  provider = aws.osaka
  name     = var.copy_vault_name
}

module "backup" {
  source                = "./modules"
  destination_vault_arn = aws_backup_vault.copy.arn
  backup_vault_name     = var.backup_vault_name
  iam_role_name         = var.iam_role_name
  selection_name        = var.selection_name
  plans                 = var.plans
}
