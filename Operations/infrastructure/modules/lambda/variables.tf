##################################################################################
#   securitydatalake s3 bucket and datacenters
##################################################################################
variable "BUCKET_AND_DATACENTERS" {
  description = "security datalake bucket and datacenters file path"
  type        = map(string)
  default     = {
    BUCKET: "securitydatalake-staging-daily"
    DATACENTERS: "fisma"
  }
}

##################################################################################
#   LAMBDA VARIABLES
##################################################################################

##################################################################################
#    Handler
##################################################################################
variable "lambda_handler" {
  description = "lambda handler"
  type        = string
  default     = "lambda_function.lambda_handler"
}

##################################################################################
#   Runtime Environment for Lambda
##################################################################################
variable "python3_6" {
  description = "runtime environment for lambda"
  type        = string
  default     = "python3.6"
}

variable "python3_7" {
  description = "runtime environment for lambda"
  type        = string
  default     = "python3.7"
}

variable "python3_8" {
  description = "runtime environment for lambda"
  type        = string
  default     = "python3.8"
}

variable "python3_9" {
  description = "runtime environment for lambda"
  type        = string
  default     = "python3.9"
}

##################################################################################
#   Minutes lambda take to run
##################################################################################
variable "lambda_timeout_10_sec" {
  description = "Lambda timeout in 10 seconds"
  type        = number
  default     = 10
}

variable "lambda_timeout_30_sec" {
  description = "Lambda timeout in 30 seconds"
  type        = number
  default     = 30
}

variable "lambda_timeout_120_sec" {
  description = "Lambda timeout in 120 seconds"
  type        = number
  default     = 120
}

variable "lambda_timeout_600_sec" {
  description = "Lambda timeout in 600 seconds (10 min)"
  type        = number
  default     = 600
}

variable "lambda_timeout_900_sec" {
  description = "Lambda timeout in 900 seconds (15 min)"
  type        = number
  default     = 900
}

##################################################################################
#    memory size for lambda functions
##################################################################################
variable "lambda_memory_size_128_MB" {
  description = "128MB memory size for the lambda function"
  type        = number
  default     = 128
}

variable "lambda_memory_size_2048_MB" {
  description = "2048MB memory size for the lambda function"
  type        = number
  default     = 2048
}

variable "lambda_memory_size_4096_MB" {
  description = "4096MB memory size for the lambda function"
  type        = number
  default     = 4096
}

variable "lambda_memory_size_10240_MB" {
  description = "10240MB memory size for the lambda function"
  type        = number
  default     = 10240
}

##################################################################################
#  LAMBDA LAYERS
##################################################################################

##################################################################################
#  lambda layer for sdl_common_layer
##################################################################################
variable "sdl_common_layer" {
  description = "common layer name for sdl_common_layer"
  type        = string
  default     = "sdl_common_layer_test"
}

variable "sdl_common_layer_arn" {
  description = "lambda layer arn"
  type        = string
  default     = "arn:aws:lambda:us-east-1:690322010149:layer:sdl_common_layer_test"
}

##################################################################################
#  lambda layer for sdl_lambda_layer
##################################################################################
variable "sdl_lambda_layer" {
  description = "lambda layer name for sdl_lambda_layer"
  type        = string
  default     = "sdl_lambda_layer_test"
}

variable "sdl_lambda_layer_arn" {
  description = "lambda layer arn"
  type        = string
  default     = "arn:aws:lambda:us-east-1:690322010149:layer:sdl_lambda_layer_test"
}

##################################################################################
#   LAMBDA FUNCTIONS
##################################################################################

##################################################################################
#    sdl-camp-feed lambda function
##################################################################################
variable "sdl_camp_feed_lambda" {
  description = "lambda function name for sdl-camp-feed"
  type        = string
  default     = "sdl-camp-feed-test"
}

variable "sdl_camp_feed_role_arn" {
  description = "role arn for sdl-camp-feed lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-aws-dc-acct-test"
}

variable "SDL_CAMP_FEED_ENV" {
    description = "Environment variables for sdl-camp-feed"
    type        = map(string)
    default     = {
      APIKEY: "d453d955-4bf2-48a4-86da-cf20de6a26f3"
      CAMPURL: "https://api.cloud.cms.gov/campdb/listsplunk_view"
    }
}

##################################################################################
#    sdl-daily-ingest lambda function
##################################################################################
variable "sdl_daily_ingest_lambda" {
  description = "lambda function name for sdl-daily-ingest"
  type        = string
  default     = "sdl-daily-ingest-test"
}

variable "sdl_daily_ingest_role_arn" {
  description = "role arn for sdl-daily-ingest lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-daily-ingest-test"
}

variable "sdl_daily_ingest_ENV" {
    description = "Environment variables for sdl-daily-ingest"
    type        = map(string)
    default     = {
      SDLMACHINE: "arn:aws:states:us-east-1:690322010149:stateMachine:sdl-daily-ingest"
    }
}

##################################################################################
#    sdl-aws-feeds lambda function
##################################################################################
variable "sdl_aws_feeds_lambda" {
  description = "lambda function name for sdl-aws-feeds"
  type        = string
  default     = "sdl-aws-feeds-test"
}

variable "sdl_aws_feeds_role_arn" {
  description = "role arn for sdl-aws-feeds lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-aws-feeds-test"
}

variable "sdl_aws_feeds_ENV" {
    description = "Environment variables for sdl-aws-feeds"
    type        = map(string)
    default     = {
      BUCKETPATH: "aws/"
      BUCKET: "securitydatalake-staging-daily"
      CONFIGDELEGATE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/commercial-Nj1yda"
      CONFIGDELEGATEGOVCLOUD: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud-umIUHb"
      DATACENTERS: "fisma"
    }
}

##################################################################################
#    sdl-aws-cdm-vuln-feed lambda function
##################################################################################
variable "sdl_aws_cdm_vuln_feed_lambda" {
  description = "lambda function name for sdl-aws-cdm-vuln-feed"
  type        = string
  default     = "sdl-aws-cdm-vuln-feed-test"
}

variable "sdl_aws_cdm_vuln_feed_role_arn" {
  description = "role arn for sdl-aws-cdm-vuln-feed lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-aws-cdm-vuln-feed-test"
}

variable "sdl_aws_cdm_vuln_feed_ENV" {
    description = "Environment variables for sdl-aws-cdm-vuln-feed"
    type        = map(string)
    default     = {
      BUCKETPATH: "cdm/"
      BUCKET: "securitydatalake-staging-daily"
      CONFIGDELEGATE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/commercial-Nj1yda"
      CONFIGDELEGATEGOVCLOUD: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud-umIUHb"
      GOVCLOUDROLE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud/crossaccount-9qiuEJ"
      DATACENTERS: "fisma"
    }
}

##################################################################################
#    sdl-cdm-govcloud lambda function
##################################################################################
variable "sdl_cdm_govcloud_lambda" {
  description = "lambda function name for sdl-cdm-govcloud"
  type        = string
  default     = "sdl-cdm-govcloud-test"
}

variable "sdl_cdm_govcloud_role_arn" {
  description = "role arn for sdl-cdm-govcloud-feed lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-cdm-govcloud-test"
}

variable "sdl_cdm_govcloud_ENV" {
    description = "Environment variables for sdl-cdm-govcloud lambda"
    type        = map(string)
    default     = {
      CONFIGDELEGATE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/commercial-Nj1yda"
      CONFIGDELEGATEGOVCLOUD: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud-umIUHb"
      SDLMACHINE: "arn:aws:states:us-east-1:690322010149:stateMachine:sdl-cdm-govcloud-machine"
    }
}

##################################################################################
#    sdl-snyk-issues lambda function
##################################################################################
variable "sdl_snyk_issues_lambda" {
  description = "lambda function name for sdl-snyk-issues"
  type        = string
  default     = "sdl-snyk-issues-test"
}

variable "sdl_snyk_issues_role_arn" {
  description = "role arn for sdl-snyk-issues lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-snyk-issues-test"
}

variable "sdl_snyk_issues_ENV" {
    description = "Environment variables for sdl-snyk-issues lambda"
    type        = map(string)
    default     = {
      APIKEY: "15d895e3-409d-4f0d-adbb-f0cf80967d58"
      SNYKURLURL: "https://snyk.io/api/v1"
      BUCKETPATH: "snyk/issues/lambda"
      BUCKET: "securitydatalake-staging-daily"
    }
}

##################################################################################
#    sdl-aws-cdm-config_data-feed lambda function
##################################################################################
variable "sdl_aws_cdm_config_data_feed_lambda" {
  description = "lambda function name for sdl-aws-cdm-config_data-feed"
  type        = string
  default     = "sdl-aws-cdm-config_data-feed-test"
}

variable "sdl_aws_cdm_config_data_feed_role_arn" {
  description = "role arn for sdl-aws-cdm-config_data-feed lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-aws-cdm-config-data-feed-test"
}

variable "sdl_aws_cdm_config_data_feed_ENV" {
    description = "Environment variables for sdl-aws-cdm-config_data-feed"
    type        = map(string)
    default     = {
      BUCKETPATH: "cdm/"
      BUCKET: "securitydatalake-staging-daily"
      CONFIGDELEGATE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/commercial-Nj1yda"
      CONFIGDELEGATEGOVCLOUD: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud-umIUHb"
      GOVCLOUDROLE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud/crossaccount-9qiuEJ"
      DATACENTERS: "fisma"
    }
}

##################################################################################
#    sdl-aws-cdm-csm-feed lambda function
##################################################################################
variable "sdl_aws_cdm_csm_feed_lambda" {
  description = "lambda function name for sdl-aws-cdm-csm-feed"
  type        = string
  default     = "sdl-aws-cdm-csm-feed-test"
}

variable "sdl_aws_cdm_csm_feed_role_arn" {
  description = "role arn for sdl-aws-cdm-csm-feed lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-aws-cdm-csm-feed-test"
}

variable "sdl_aws_cdm_csm_feed_ENV" {
    description = "Environment variables for sdl-aws-cdm-csm-feed"
    type        = map(string)
    default     = {
      BUCKETPATH: "cdm/"
      BUCKET: "securitydatalake-staging-daily"
      CONFIGDELEGATE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/commercial-Nj1yda"
      CONFIGDELEGATEGOVCLOUD: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud-umIUHb"
      GOVCLOUDROLE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud/crossaccount-9qiuEJ"
      DATACENTERS: "fisma"
    }
}

##################################################################################
#    sdl-daily-ingest-vuln-csm-config-data lambda function
##################################################################################

variable "sdl_daily_ingest_vuln_csm_config_lambda" {
  description = "lambda function name for sdl-daily-ingest-vuln-csm-config"
  type        = string
  default     = "sdl-daily-ingest-vuln-csm-config-test"
}

variable "sdl_daily_ingest_vuln_csm_config_role_arn" {
  description = "role arn for sdl-daily-ingest-vuln-csm-config lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-daily-ingest-vuln-csm-config-test"
}

variable "sdl_daily_ingest_vuln_csm_config_ENV" {
    description = "Environment variables for sdl_daily_ingest_vuln-csm-config"
    type        = map(string)
    default     = {
      SDLMACHINE: "arn:aws:states:us-east-1:690322010149:stateMachine:sdl-daily-ingest-vuln-csm-config"
    }
}

##################################################################################
#    sdl-cisa-daily-known-exploited-vulnerabilities lambda function
##################################################################################
variable "sdl_cisa_daily_known_exploited_vulnerabilities_lambda" {
  description = "lambda function name for sdl-cisa-daily-known-exploited-vulnerabilities"
  type        = string
  default     = "sdl-cisa-daily-known-exploited-vulnerabilities-test"
}

variable "sdl_cisa_daily_known_exploited_vulnerabilities_role_arn" {
  description = "role arn for sdl-cisa-daily-known-exploited-vulnerabilities lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-cisa-daily-known-exploited-vulnerabilities-test"
}

variable "sdl_cisa_daily_known_exploited_vulnerabilities_ENV" {
    description = "Environment variables for sdl-cisa-daily-known-exploited-vulnerabilities lambda"
    type        = map(string)
    default     = {
      KEY: "db_lookup/BOD_KEV_Catalog.json.gz"
      CISA_URL: "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json"
      BUCKETNAME: "securitydatalake-staging-daily"
    }
}

##################################################################################
#    sdl-daily-init lambda function
##################################################################################

variable "sdl_daily_init_lambda" {
  description = "lambda function name for sdl-daily-init"
  type        = string
  default     = "sdl-daily-init-test"
}

variable "sdl_daily_init_role_arn" {
  description = "role arn for sdl-daily-init lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-daily-init-test"
}

variable "sdl_daily_init_ENV" {
    description = "Environment variables for sdl_daily_init"
    type        = map(string)
    default     = {
      SDLMACHINE: "arn:aws:states:us-east-1:690322010149:stateMachine:sdl-daily-ingest"
    }
}

##################################################################################
#    sdl-cdm-securitycenter lambda function
##################################################################################
variable "sdl_cdm_securitycenter_lambda" {
  description = "lambda function name for sdl-cdm-securitycenter"
  type        = string
  default     = "sdl-cdm-securitycenter-test1"
}

variable "sdl_cdm_securitycenter_role_arn" {
  description = "role arn for sdl-cdm-securitycenter lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-cdm-securitycenter-test"
}

variable "sdl_cdm_securitycenter_ENV" {
    description = "Environment variables for sdl-cdm-securitycenter lambda"
    type        = map(string)
    default     = {
       SECURITYCENTER: "sdl/sbx/cdm/securitycenter"
    }
}

##################################################################################
#    sdl-aws-networking-feed lambda function
##################################################################################
variable "sdl_aws_networking_feed_lambda" {
  description = "lambda function name for sdl-aws-networking-feed"
  type        = string
  default     = "sdl-aws-networking-test"
}

variable "sdl_aws_networking_feed_role_arn" {
  description = "role arn for sdl-aws-networking-feed lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-aws-networking-feed-test"
}

variable "sdl_aws_networking_feed_ENV" {
    description = "Environment variables for sdl-aws-networking-feed"
    type        = map(string)
    default     = {
      BUCKET: "securitydatalake-staging-daily"
      BUCKETPATH: "aws/"
      DATACENTERS: "fisma"
      CONFIGDELEGATE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/commercial-Nj1yda"
      CONFIGDELEGATEGOVCLOUD: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud-umIUHb"
      GOVCLOUDROLE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud/crossaccount-9qiuEJ"
    }
}

##################################################################################
#    sdl-monitoring-notifications lambda function
##################################################################################
variable "sdl_monitoring_notifications_lambda" {
  description = "lambda function name for sdl-monitoring-notifications"
  type        = string
  default     = "sdl-monitoring-notifications-test"
}

variable "sdl_monitoring_notifications_role_arn" {
  description = "role arn for sdl-monitoring-notifications lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-monitoring-notifications-test"
}

variable "sdl_monitoring_notifications_ENV" {
    description = "Environment variables for sdl-monitoring-notifications"
    type        = map(string)
    default     = {
      SLACK_URL: "https://hooks.slack.com/services/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"
      CHANNEL_ID: "#security-datalake-alerts"
    }
}

##################################################################################
#    sdl-missing-files-notification lambda function
##################################################################################
variable "sdl_missing_files_notification_lambda" {
  description = "lambda function name for sdl-missing-files-notification"
  type        = string
  default     = "sdl-missing-files-notification-test"
}

variable "sdl_missing_files_notification_role_arn" {
  description = "role arn for sdl-missing-files-notification lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-missing-files-notification-test"
}

variable "sdl_missing_files_notification_ENV" {
    description = "Environment variables for sdl-missing-files-notification"
    type        = map(string)
    default     = {
      ION_PATH: "ion/"
      DB_LOOKUP_PATH: "db_lookup/"
      SECURITY_CENTER_PATH: "security-center"
      CDM_PATH: "cdm"
      SNYK_PATH: "snyk/"
      BUCKET: "securitydatalake-staging-daily"
      ISPG_RISK_PILOT_PATH: "ispg-risk-pilot/"
      AWS_PATH: "aws"
      DW_PATH: "DW/"
      NUCLEUS_PATH: "nucleus/"
      SLACK_URL: "https://hooks.slack.com/services/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"
      CHANNEL_ID: "#security-datalake-alerts"
    }
}

##################################################################################
#    sdl-aws-iam-feed lambda function
##################################################################################
variable "sdl_aws_iam_feed_lambda" {
  description = "lambda function name for sdl-aws-iam-feed"
  type        = string
  default     = "sdl-aws-iam-feed-test"
}

variable "sdl_aws_iam_feed_role_arn" {
  description = "role arn for sdl-aws-iam-feed lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-aws-iam-feed-test"
}

variable "sdl_aws_iam_feed_ENV" {
    description = "Environment variables for sdl-aws-iam-feed"
    type        = map(string)
    default     = {
      BUCKET: "securitydatalake-staging-daily"
      BUCKETPATH: "aws/"
      DATACENTERS: "fisma"
      CONFIGDELEGATE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/commercial-Nj1yda"
      CONFIGDELEGATEGOVCLOUD: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud-umIUHb"
    }
}

##################################################################################
#    sdl-securitycenter-feed lambda function
##################################################################################
variable "sdl_securitycenter_feeds_lambda" {
  description = "lambda function name for sdl-securitycenter-feeds "
  type        = string
  default     = "sdl-securitycenter-feeds-test"
}

variable "sdl_securitycenter_feeds_role_arn" {
  description = "role arn for sdl-securitycenter-feeds lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-securitycenter-feeds-test"
}

variable "sdl_securitycenter_feeds_ENV" {
    description = "Environment variables for sdl-securitycenter-feeds lambda"
    type        = map(string)
    default     = {
      BUCKET: "securitydatalake-staging-daily"
      BUCKETPATH: "security-center/"
      DATACENTERS: "config"
      SECURITYCENTER: "sdl/sbx/cdm/securitycenter"
    }
}

##################################################################################
#    sdl-aws-cdm-feed lambda function
##################################################################################
variable "sdl_aws_cdm_feed_lambda" {
  description = "lambda function name for sdl-aws-cdm-feed"
  type        = string
  default     = "sdl-aws-cdm-feed-test"
}

variable "sdl_aws_cdm_feed_role_arn" {
  description = "role arn for sdl-aws-cdm-feed lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-aws-cdm-feed-test"
}

variable "sdl_aws_cdm_feed_ENV" {
    description = "Environment variables for sdl-aws-cdm-feed"
    type        = map(string)
    default     = {
      BUCKET: "securitydatalake-staging-daily"
      BUCKETPATH: "cdm/"
      DATACENTERS: "fisma"
      GOVCLOUDROLE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud/crossaccount-9qiuEJ"
      CONFIGDELEGATE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/commercial-Nj1yda"
      CONFIGDELEGATEGOVCLOUD: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud-umIUHb"
    }
}

##################################################################################
#    sdl-aws-dc-acct lambda function
##################################################################################
variable "sdl_aws_dc_acct_lambda" {
  description = "lambda function name for sdl-aws-dc-acct"
  type        = string
  default     = "sdl-aws-dc-acct-test"
}

variable "sdl_aws_dc_acct_role_arn" {
  description = "role arn for sdl-aws-dc-acct lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-aws-dc-acct-test"
}

variable "sdl_aws_dc_acct_ENV" {
    description = "Environment variables for sdl-aws-dc-acct"
    type        = map(string)
    default     = {
      BUCKET: "securitydatalake-staging-daily"
      BUCKETPATH: "cdm/"
      CONFIGDELEGATE: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/commercial-Nj1yda"
      CONFIGDELEGATEGOVCLOUD: "arn:aws:secretsmanager:us-east-1:690322010149:secret:sdl/sbx/cdm/govcloud-umIUHb"
    }
}

##################################################################################
#    sdl-split-stream lambda function
##################################################################################
variable "sdl_split_stream_lambda" {
  description = "lambda function name for sdl-split-stream"
  type        = string
  default     = "sdl-split-stream-test"
}

variable "sdl_split_stream_role_arn" {
  description = "role arn for sdl-split-stream lambda"
  type        = string
  default     = "arn:aws:iam::690322010149:role/delegatedadmin/developer/sdl-split-stream-test"
}




















































