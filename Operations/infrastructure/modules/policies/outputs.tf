#########################################################################
#   Step Functions Roles
#########################################################################
output "sdl_daily_ingest_role" {
   value = aws_iam_role.sdl_daily_ingest_role.arn
 }

 output "sdl_daily_aws_role" {
   value = aws_iam_role.sdl_daily_aws_role.arn
 }

 output "sdl_daily_securitycenter_role" {
   value = aws_iam_role.sdl_daily_securitycenter_role.arn
 }

 output "sdl_cdm_govcloud_role" {
   value = aws_iam_role.sdl_cdm_govcloud_role.arn
 }

 output "sdl_daily_aws_vcc_role" {
   value = aws_iam_role.sdl_daily_aws_vcc_role.arn
 }

 output "sdl_daily_ingest_vuln_csm_config_role" {
   value = aws_iam_role.sdl_daily_ingest_vuln_csm_config_role.arn
 }

#########################################################################
#   Lambda Functions Roles
#########################################################################
output "sdl_aws_dc_acct_role" {
  value = aws_iam_role.sdl_aws_dc_acct_role.arn
}

output "sdl_camp_feed_role" {
  value = aws_iam_role.sdl_camp_feed_role.arn
}

output "sdl_aws_feeds_role" {
  value = aws_iam_role.sdl_aws_feeds_role.arn
}

output "sdl_aws_cdm_vuln_feed_role" {
  value = aws_iam_role.sdl_aws_cdm_vuln_feed_role.arn
}

output "sdl_snyk_issues_role" {
  value = aws_iam_role.sdl_snyk_issues_role.arn
}

output "sdl_aws_cdm_config_data_role" {
  value = aws_iam_role.sdl_aws_cdm_config_data_feed_role.arn
}

output "sdl_aws_cdm_csm_feed_role" {
  value = aws_iam_role.sdl_aws_cdm_csm_feed_role.arn
}

output "sdl_cisa_daily_known_exploited_vulnerabilities_role" {
  value = aws_iam_role.sdl_cisa_daily_known_exploited_vulnerabilities_role.arn
}

output "sdl_daily_init_role" {
  value = aws_iam_role.sdl_daily_init_role.arn
}

output "sdl_cdm_securitycenter_role" {
  value = aws_iam_role.sdl_cdm_securitycenter_role.arn
}

output "sdl_aws_networking_feed_role" {
  value = aws_iam_role.sdl_aws_networking_feed_role.arn
}

output "sdl_monitoring_notifications_role" {
  value = aws_iam_role.sdl_monitoring_notifications_role.arn
}

output "sdl_missing_files_notification_role" {
  value = aws_iam_role.sdl_missing_files_notification_role.arn
}

output "sdl_aws_iam_feed_role" {
  value = aws_iam_role.sdl_aws_iam_feed_role.arn
}

output "sdl_cdm_securitycenter_feeds_role" {
  value = aws_iam_role.sdl_securitycenter_feeds_role.arn
}

output "sdl_aws_cdm_feed_role" {
  value = aws_iam_role.sdl_aws_cdm_feed_role.arn
}

output "sdl_split_stream_role" {
  value = aws_iam_role.sdl_split_stream_role.arn
}

