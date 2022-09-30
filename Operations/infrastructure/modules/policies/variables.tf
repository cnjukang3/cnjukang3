##################################################################################
#   POLICIES/ROLES
##################################################################################
variable "sdl_govcloud_secrets_manager_arn" {
    description = "secret manager for govcloud"
    type        = string
    default     = "arn:aws:secretsmanager:us-east-1:*:secret:sdl/dev/cdm/govcloud*"
}

variable "sdl_commercial_secrets_manager_arn" {
    description = "secret manager for config delegate"
    type        = string
    default     =   "arn:aws:secretsmanager:us-east-1:*:secret:sdl/dev/cdm/commercial*"
}

variable "sdl_securitycenter_secrets_manager_arn" {
    description = "secret manager for security center"
    type        = string
    default     =   "arn:aws:secretsmanager:us-east-1:*:secret:sdl/dev/cdm/securitycenter*"
}

variable "sdl_permission_boundary_for_iam_role" {
    description = "sdl Permission-boundary for IAM role"
    type        = string
    default     = "arn:aws:iam::690322010149:policy/cms-cloud-admin/developer-boundary-policy"
}

variable "sdl_bucket_arn_prefix_with_wildcard" {
    description = "sdl-bucket"
    type        = string
    default     = "arn:aws:s3:::datalake-snowflake-staging/*"
}

variable "sdl_bucket_name" {
    description = "backend bucket"
    type        = string
    default     = "datalake-snowflake-staging"
}
variable "sdl_bucket_arn_prefix" {
    description = "sdl-bucket"
    type        = string
    default     = "arn:aws:s3:::datalake-snowflake-staging"
}

variable "sdl_config_arn_path_with_wildcard" {
    description = "sdl config path"
    type        = string
    default     = "arn:aws:s3:::datalake-snowflake-staging/config/*"
}

variable "sdl_aws_iam_feed" {
    description = "policy/role name for sdl-aws-iam-feed lambda function"
    type        = string
    default     = "sdl-aws-iam-feed-test"
}

variable "sdl_aws_iam_feed_log_group_arn" {
    description = "log group arn for sdl-aws-iam-feed policy"
    type        = string
    default     = "*"
}

variable "sdl_daily_ingest_vuln_csm_config" {
    description = "sdl-daily-ingest-vuln-csm-config lambda policy"
    type        = string
    default     = "sdl-daily-ingest-vuln-csm-config-test"
}

variable "sdl_aws_cdm_vuln_feed" {
    description = "policy/role name for sdl-aws-cdm-vuln-feed lambda function"
    type        = string
    default     = "sdl-aws-cdm-vuln-feed-test"
}

variable "sdl_aws_cdm_csm_feed" {
    description = "policy/role name for sdl-aws-cdm-csm-feed lambda function"
    type        = string
    default     = "sdl-aws-cdm-csm-feed-test"
}

variable "sdl_aws_cdm_config_data_feed" {
    description = "policy/role name for sdl-aws-cdm-config_data-feed lambda function"
    type        = string
    default     = "sdl-aws-cdm-config-data-feed-test"
}

variable "sdl_cisa_daily_known_exploited_vulnerabilities" {
    description = "policy/role name for sdl-cisa-daily-known-exploited-vulnerabilities lambda function"
    type        = string
    default     = "sdl-cisa-daily-known-exploited-vulnerabilities-test"
}

variable "sdl_cdm_securitycenter" {
    description = "sdl-cdm-securitycenter policy name for lambda"
    type        = string
    default     = "sdl-cdm-securitycenter-test"
}

variable "sdl_cdm_govcloud" {
    description = "policy/role name for sdl-cdm-govcloud-feed lambda function"
    type        = string
    default     = "sdl-cdm-govcloud-test"
}

variable "sdl_cdm_aws" {
    description = "policy/role name for sdl-cdm-aws for lambda function"
    type        = string
    default     = "sdl-cdm-aws-test"
}

variable "sdl_monitoring_notifications" {
    description = "policy/role name for sdl-monitoring-notifications lambda function"
    type        = string
    default     = "sdl-monitoring-notifications-test"
}

variable "sdl_daily_init" {
    description = "policy/role name for sdl-daily-init for Step Function"
    type        = string
    default     = "sdl-daily-init-test"
}

variable "sdl_daily_aws_vcc" {
    description = "policy/role name for sdl-daily-aws-vcc Step Function"
    type        = string
    default     = "sdl-daily-aws-vcc-test"
}

variable "sdl_aws_feeds" {
    description = "policy/role name for sdl-aws-feeds lambda function"
    type        = string
    default     = "sdl-aws-feeds-test"
}

variable "sdl_daily_aws" {
    description = "policy/role name for sdl-daily-aws"
    type        = string
    default     = "sdl-daily-aws-test"
}

variable "sdl_aws_networking_feed" {
    description = "policy/role name for sdl-aws-networking-feed"
    type        = string
    default     = "sdl-aws-networking-feed-test"
}

variable "sdl_aws_cdm_feed" {
    description = "policy/role name for sdl-aws-cdm-feed"
    type        = string
    default     = "sdl-aws-cdm-feed-test"
}

variable "sdl_securitycenter_feeds" {
    description = "policy/role name for sdl-securitycenter-feeds"
    type        = string
    default     = "sdl-securitycenter-feeds-test"
}

variable "sdl_daily_ingest" {
    description = "policy/role name for sdl-daily-ingest"
    type        = string
    default     = "sdl-daily-ingest-test"
}

variable "sdl_aws_dc_acct" {
    description = "policy/role name for sdl-aws-dc-acct lambda function"
    type        = string
    default     = "sdl-aws-dc-acct-test"
}

variable "sdl_camp_feed" {
    description = "policy/role name for sdl-camp-feed lambda function"
    type        = string
    default     = "sdl-camp-feed-test"
}

variable "sdl_daily_securitycenter" {
    description = "policy/role name for sdl-daily-securitycenter"
    type        = string
    default     = "sdl-daily-securitycenter-test"
}

variable "sdl_missing_files_notification" {
    description = "policy/role name for sdl-missing-files-notification"
    type        = string
    default     = "sdl-missing-files-notification-test"
}

variable "sdl_snyk_issues" {
    description = "policy/role name for sdl-snyk-issues"
    type        = string
    default     = "sdl-snyk-issues-test"
}

variable "sdl_split_stream" {
    description = "policy/role name for sdl-split-stream"
    type        = string
    default     = "sdl-split-stream-test"
}

variable "sdl_prod_cdm_govcloud_secret" {
    description = "govcloud secret manager"
    type        = string
    default     = "sdl/prod/cdm/govcloud-test"
}

variable "sdl_prod_cdm_commercial_secret" {
    description = "commercial (config delegate) secret manager"
    type        = string
    default     = "sdl/prod/cdm/commercial-test"
}

variable "sdl_prod_cdm_securitycenter_secret" {
    description = "securitycenter secret manager"
    type        = string
    default     = "sdl/prod/cdm/securitycenter-test"
}

variable "sdl_prod_cdm_govcloud_crossaccount_secret" {
    description = "govcloud cross account secret manager"
    type        = string
    default     = "sdl/prod/cdm/govcloud/crossaccount-test"
}

variable "sdl_govcloud_state_machine_arn" {
    description = "govcloud states machine arn"
    type        = string
    default     = "arn:aws:states:*:*:stateMachine:*"
}