copy_vault_name   = "CopyVaultFromTokyo"
backup_vault_name = "BackupVault"
iam_role_name     = "BackupRole"
selection_name    = "BackupSelection"

plans = {
  # キー名はプラン名
  ec2_plan = {
    rules = {
      # キー名はルール名
      ec2_daily_backup_rule = {
        schedule                 = "cron(0 15 ? * * *)" // 毎日 00:00 JST
        enable_continuous_backup = false                // ポイントインタイムリカバリ
        start_window             = 60                   // バックアップ開始までの時間（分）、最小 60
        completion_window        = 120                  // バックアップ完了までの時間（分）
        delete_after             = 7                    // バックアップ保持期間
        copy_action = {
          delete_after = 14 // コピーの保持期間
        }
      }
    }
    condition = {
      resources = ["arn:aws:ec2:*:*:instance/*"]
      key       = "aws:ResourceTag/aws-backup" // aws-backup の箇所は好みのタグに変える
      value     = true
    }
  }
  rds_plan = {
    rules = {
      rds_daily_backup_rule = {
        schedule                 = "cron(0 15 ? * * *)" // 毎日 00:00 JST
        enable_continuous_backup = false
        start_window             = 60
        completion_window        = 120
        delete_after             = 7
        copy_action = {
          delete_after = 14
        }
      }
      rds_hourly_backup_rule = {
        schedule                 = "cron(0 * ? * * *)" // 毎時 0 分に取得
        enable_continuous_backup = true                // ポイントインタイムリカバリ(PITR)バックアップ
        start_window             = 60
        completion_window        = 120
        delete_after             = 3
        copy_action              = { /* コピーしない */ }
      }
    }
    condition = {
      resources = ["arn:aws:rds:*:*:db:*"]
      key       = "aws:ResourceTag/aws-backup" // aws-backup の箇所は好みのタグに変える
      value     = "true"
    }
  }
}
