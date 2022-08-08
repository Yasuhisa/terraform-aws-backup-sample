# AWS Backup ボールト
resource "aws_backup_vault" "main" {
  name = var.backup_vault_name
}

# AWS Backup プラン
resource "aws_backup_plan" "main" {
  for_each = var.plans
  name     = each.key

  dynamic "rule" {
    for_each = each.value.rules
    content {
      rule_name                = rule.key
      target_vault_name        = aws_backup_vault.main.name
      schedule                 = rule.value.schedule
      enable_continuous_backup = rule.value.enable_continuous_backup
      start_window             = rule.value.start_window
      completion_window        = rule.value.completion_window

      lifecycle {
        delete_after = rule.value.delete_after
      }

      dynamic "copy_action" {
        for_each = rule.value.copy_action
        content {
          destination_vault_arn = var.destination_vault_arn

          lifecycle {
            delete_after = copy_action.value
          }
        }
      }
    }
  }
}

# AWS Backup が使う IAM ロール
resource "aws_iam_role" "main" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })

  # https://docs.aws.amazon.com/ja_jp/aws-backup/latest/devguide/iam-service-roles.html
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup",  // AWS 管理の AWSBackupServiceRolePolicyForBackup ポリシー
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores" // AWS 管理の AWSBackupServiceRolePolicyForRestores ポリシー
  ]
}

# AWS Backup が使う認証情報とバックアップ対象
resource "aws_backup_selection" "main" {
  for_each     = var.plans
  iam_role_arn = aws_iam_role.main.arn
  name         = var.selection_name
  plan_id      = aws_backup_plan.main[each.key].id
  resources    = each.value.condition.resources

  condition {
    string_equals {
      key   = each.value.condition.key
      value = each.value.condition.value
    }
  }
}
