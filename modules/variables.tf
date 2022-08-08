# コピー先ボールトの ARN
variable "destination_vault_arn" {
  description = "AWS Backup Copy Vault ARN."
  type        = string
}

# AWS Backup ボールト名
variable "backup_vault_name" {
  description = "AWS Backup Vault Name."
  type        = string
}

# AWS Backup プラン
variable "plans" {
  description = "AWS Backup Plan Parameter."
  type = map(object({
    rules = map(object({
      schedule                 = string
      enable_continuous_backup = bool
      start_window             = number
      completion_window        = number
      delete_after             = number
      copy_action              = map(number)
    }))
    condition = object({
      resources = set(string)
      key       = string
      value     = string
    })
  }))
}

# AWS Backup が使う IAM ロール名
variable "iam_role_name" {
  description = "IAM Role Name for AWS Backup Job."
  type        = string
}

# AWS Backup が使う IAM ロールとバックアップ対象を束ねるセレクション名
variable "selection_name" {
  description = "AWS Backup Selection Name."
  type        = string
}
