output "govcloud_secret_arn" {
  value = aws_secretsmanager_secret_version.govcloud_secret_version.arn
}

output "aws_commercial_secret_arn" {
  value = aws_secretsmanager_secret_version.aws_commercial_secret_version.arn
}

output "securitycenter_secret_arn" {
  value = aws_secretsmanager_secret_version.securitycenter_secret_version.arn
}

output "govcloud_crossaccount_secret_arn" {
  value = aws_secretsmanager_secret_version.govcloud_crossaccount_secret_version.arn
}

output "securitycenter_secret_name" {
  value = aws_secretsmanager_secret.sdl_cdm_securitycenter_secret.name
}