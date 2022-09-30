##################################################################################
#      LAMBDA FUNCTIONS MODULES
##################################################################################
module "roles" {
  source = "../../modules/policies/"
}

module "secrets" {
  source = "../../modules/secrets/"
}


locals {
  BUCKET_AND_DATACENTERS               = var.BUCKET_AND_DATACENTERS
  SECURITYCENTER_SECRET_NAME           = tomap({SECURITYCENTER         = module.secrets.securitycenter_secret_name})
  CONFIGDELEGATE_GOV_SECRETS_ARN       = tomap({CONFIGDELEGATE         = module.secrets.aws_commercial_secret_arn,
                                                CONFIGDELEGATEGOVCLOUD = module.secrets.govcloud_secret_arn})
  CONFIGDELEGATE_GOV_CROSS_SECRETS_ARN = tomap({CONFIGDELEGATE         = module.secrets.aws_commercial_secret_arn,
                                                CONFIGDELEGATEGOVCLOUD = module.secrets.govcloud_secret_arn,
                                                GOVCLOUDROLE           = module.secrets.govcloud_crossaccount_secret_arn})
  python3_6                        = var.python3_6
  python3_7                        = var.python3_7
  python3_8                        = var.python3_8
  python3_9                        = var.python3_9

  lambda_handler                   = var.lambda_handler

  lambda_timeout_10_sec            = var.lambda_timeout_10_sec
  lambda_timeout_30_sec            = var.lambda_timeout_30_sec
  lambda_timeout_120_sec           = var.lambda_timeout_120_sec
  lambda_timeout_600_sec           = var.lambda_timeout_600_sec
  lambda_timeout_900_sec           = var.lambda_timeout_900_sec

  lambda_memory_size_128_MB        = var.lambda_memory_size_128_MB
  lambda_memory_size_2048_MB       = var.lambda_memory_size_2048_MB
  lambda_memory_size_4096_MB       = var.lambda_memory_size_4096_MB
  lambda_memory_size_10240_MB      = var.lambda_memory_size_10240_MB

  sdl_common_layer                 = var.sdl_common_layer
  sdl_lambda_layer                 = var.sdl_lambda_layer

  sdl_camp_feed_role_arn                = module.roles.sdl_camp_feed_role
  sdl_daily_ingest_role_arn             = module.roles.sdl_daily_ingest_role
  sdl_aws_feeds_role_arn                = module.roles.sdl_aws_feeds_role
  sdl_aws_cdm-vuln_feed_role_arn        = module.roles.sdl_aws_cdm_vuln_feed_role
  sdl_cdm_govcloud_role_arn             = module.roles.sdl_cdm_govcloud_role
  sdl_snyk_issues_role_arn              = module.roles.sdl_snyk_issues_role
  sdl_aws_cdm_config_data_feed_role_arn = module.roles.sdl_aws_cdm_config_data_role
  sdl_aws_cdm_csm_feed_role_arn         = module.roles.sdl_aws_cdm_csm_feed_role
  sdl_daily_ingest_vuln_csm_config_role_arn               = module.roles.sdl_daily_ingest_vuln_csm_config_role
  sdl_cisa_daily_known_exploited_vulnerabilities_role_arn = module.roles.sdl_cisa_daily_known_exploited_vulnerabilities_role
  sdl_daily_init_role_arn                 = module.roles.sdl_daily_init_role
  sdl_cdm_securitycenter_role_arn         = module.roles.sdl_cdm_securitycenter_role
  sdl_aws_networking_feed_role_arn        = module.roles.sdl_aws_networking_feed_role
  sdl_monitoring_notifications_role_arn   = module.roles.sdl_monitoring_notifications_role
  sdl_missing_files_notification_role_arn = module.roles.sdl_missing_files_notification_role
  sdl_aws_iam_feed_role_arn               = module.roles.sdl_aws_iam_feed_role
  sdl_securitycenter_feeds_role_arn       = module.roles.sdl_cdm_securitycenter_feeds_role
  sdl_aws_cdm_feed_role_arn               = module.roles.sdl_aws_cdm_feed_role
  sdl_aws_dc_acct_role_arn                = module.roles.sdl_aws_dc_acct_role
  sdl_split_stream_role_arn               = module.roles.sdl_split_stream_role

  sdl_camp_feed_lambda             = var.sdl_camp_feed_lambda
  SDL_CAMP_FEED_ENV                 = var.SDL_CAMP_FEED_ENV

  sdl_daily_ingest_lambda          = var.sdl_daily_ingest_lambda
  sdl_daily_ingest_ENV             = var.sdl_daily_ingest_ENV

  sdl_aws_feeds_lambda             = var.sdl_aws_feeds_lambda
  sdl_aws_feeds_ENV                = var.sdl_aws_feeds_ENV

  sdl_aws_cdm_vuln_feed_lambda     = var.sdl_aws_cdm_vuln_feed_lambda
  sdl_aws_cdm_vuln_feed_ENV        = var.sdl_aws_cdm_vuln_feed_ENV

  sdl_cdm_govcloud_lambda          = var.sdl_cdm_govcloud_lambda
  sdl_cdm_govcloud_ENV             = var.sdl_cdm_govcloud_ENV

  sdl_snyk_issues_lambda           = var.sdl_snyk_issues_lambda
  sdl_snyk_issues_ENV              = var.sdl_snyk_issues_ENV

  sdl_aws_cdm_config_data_feed_lambda      = var.sdl_aws_cdm_config_data_feed_lambda
  sdl_aws_cdm_config_data_feed_ENV         = var.sdl_aws_cdm_config_data_feed_ENV

  sdl_aws_cdm_csm_feed_lambda              = var.sdl_aws_cdm_csm_feed_lambda
  sdl_aws_cdm_csm_feed_ENV                 = var.sdl_aws_cdm_csm_feed_ENV

  sdl_daily_ingest_vuln_csm_config_lambda                  = var.sdl_daily_ingest_vuln_csm_config_lambda
  sdl_daily_ingest_vuln_csm_config_ENV                     = var.sdl_daily_ingest_vuln_csm_config_ENV

  sdl_cisa_daily_known_exploited_vulnerabilities_lambda    = var.sdl_cisa_daily_known_exploited_vulnerabilities_lambda
  sdl_cisa_daily_known_exploited_vulnerabilities_ENV       = var.sdl_cisa_daily_known_exploited_vulnerabilities_ENV

  sdl_daily_init_lambda              = var.sdl_daily_init_lambda
  sdl_daily_init_ENV                 = var.sdl_daily_init_ENV

  sdl_cdm_securitycenter_lambda      = var.sdl_cdm_securitycenter_lambda
  sdl_cdm_securitycenter_ENV         = var.sdl_cdm_securitycenter_ENV

  sdl_aws_networking_feed_lambda     = var.sdl_aws_networking_feed_lambda
  sdl_aws_networking_feed_ENV        = var.sdl_aws_networking_feed_ENV

  sdl_monitoring_notifications_lambda       = var.sdl_monitoring_notifications_lambda
  sdl_monitoring_notifications_ENV          = var.sdl_monitoring_notifications_ENV

  sdl_missing_files_notification_lambda     = var.sdl_missing_files_notification_lambda
  sdl_missing_files_notification_ENV        = var.sdl_missing_files_notification_ENV

  sdl_aws_iam_feed_lambda                   = var.sdl_aws_iam_feed_lambda
  sdl_aws_iam_feed_ENV                      = var.sdl_aws_iam_feed_ENV

  sdl_cdm_securitycenter_feeds_lambda       = var.sdl_securitycenter_feeds_lambda
  sdl_securitycenter_feeds_ENV              = var.sdl_securitycenter_feeds_ENV

  sdl_aws_cdm_feed_lambda                   = var.sdl_aws_cdm_feed_lambda
  sdl_aws_cdm_feed_ENV                      = var.sdl_aws_cdm_feed_ENV

  sdl_aws_dc_acct_lambda                    = var.sdl_aws_dc_acct_lambda
  sdl_aws_dc_acct_ENV                       = var.sdl_aws_dc_acct_ENV

  sdl_split_stream_lambda                   = var.sdl_split_stream_lambda


}
#data "external" "download_function" {
#  program = ["curl", "-L", "-o",
#"${path.module}/sdl-monitoring-git.zip", " git@github.com:CMSgov/security-datalake.git/sdl-monitoring"]
#}

##################################################################################
#   Lambda Layer: sdl_common_layer
##################################################################################
data "archive_file" "sdl_common_layer_zip" {
  source_dir  = "${path.module}/layers-files/sdl-common-layer-files/"
  output_path = "${path.module}/layers-zip/sdl-common-layer-zip/python.zip"
  type        = "zip"
}

resource "aws_lambda_layer_version" "sdl_common_layer" {
  layer_name           = local.sdl_common_layer
  filename             = data.archive_file.sdl_common_layer_zip.output_path
  source_code_hash     = filebase64sha256(data.archive_file.sdl_common_layer_zip.output_path)
  compatible_runtimes  = [local.python3_6, local.python3_7, local.python3_8, local.python3_9]
}

##################################################################################
#   Lambda Layer: sdl_lambda_layer
##################################################################################
data "archive_file" "sdl_lambda_layer_zip" {
  source_dir  = "${path.module}/layers-files/sdl-lambda-layer-files/"
  output_path = "${path.module}/layers-zip/sdl-lambda-layer-zip/python.zip"
  type        = "zip"
}

resource "aws_lambda_layer_version" "sdl_lambda_layer" {
  layer_name           = local.sdl_lambda_layer
  filename             = data.archive_file.sdl_lambda_layer_zip.output_path
  source_code_hash     = filebase64sha256(data.archive_file.sdl_lambda_layer_zip.output_path)
  compatible_runtimes  = [local.python3_6, local.python3_7, local.python3_8, local.python3_9]
}

##################################################################################
#   Lambda: sdl-camp-feed
##################################################################################
data "archive_file" "sdl_camp_feed_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-camp-feed-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-camp-feed.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_camp_feed" {
  function_name    = local.sdl_camp_feed_lambda
  filename         = data.archive_file.sdl_camp_feed_zip.output_path #"${path.module}/sdlzip/sdl-camp-feed.zip"
  role             = local.sdl_camp_feed_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_camp_feed_zip.output_path)
  timeout          = local.lambda_timeout_120_sec
  memory_size      = local.lambda_memory_size_128_MB

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.SDL_CAMP_FEED_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-daily-ingest
##################################################################################
data "archive_file" "sdl_daily_ingest_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-daily-ingest-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-daily-ingest.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_daily_ingest" {
  function_name    = local.sdl_daily_ingest_lambda
  filename         = data.archive_file.sdl_daily_ingest_zip.output_path #"${path.module}/sdlzip/sdl-daily-ingest.zip"
  role             = local.sdl_daily_ingest_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_daily_ingest_zip.output_path)
  timeout          = local.lambda_timeout_10_sec
  memory_size      = local.lambda_memory_size_128_MB

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.sdl_daily_ingest_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-aws-feeds
##################################################################################
data "archive_file" "sdl_aws_feeds_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-aws-feeds-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-aws-feeds.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_aws_feeds" {
  function_name    = local.sdl_aws_feeds_lambda
  filename         = data.archive_file.sdl_aws_feeds_zip.output_path
  role             = local.sdl_aws_feeds_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_aws_feeds_zip.output_path)
  timeout          = local.lambda_timeout_600_sec
  memory_size      = local.lambda_memory_size_2048_MB
  layers           = [aws_lambda_layer_version.sdl_lambda_layer.arn]

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.CONFIGDELEGATE_GOV_SECRETS_ARN, local.sdl_aws_feeds_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}



##################################################################################
#   Lambda: sdl-cdm-govcloud
##################################################################################
data "archive_file" "sdl_cdm_govcloud_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-cdm-govcloud-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-cdm-govcloud.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_cdm_govcloud" {
  function_name    = local.sdl_cdm_govcloud_lambda
  filename         = data.archive_file.sdl_cdm_govcloud_zip.output_path
  role             = local.sdl_cdm_govcloud_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_cdm_govcloud_zip.output_path)
  timeout          = local.lambda_timeout_900_sec
  memory_size      = local.lambda_memory_size_4096_MB

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.CONFIGDELEGATE_GOV_SECRETS_ARN, local.sdl_cdm_govcloud_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-snyk-issues
##################################################################################
data "archive_file" "sdl_snyk_issues_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-snyk-issues-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-snyk-issues.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_snyk_issues" {
  function_name    = local.sdl_snyk_issues_lambda
  filename         = data.archive_file.sdl_snyk_issues_zip.output_path
  role             = local.sdl_snyk_issues_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_snyk_issues_zip.output_path)
  timeout          = local.lambda_timeout_900_sec
  memory_size      = local.lambda_memory_size_128_MB

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.sdl_snyk_issues_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##################################################################################
#   Lambda: sdl-daily-ingest-vuln-csm-config
##################################################################################
data "archive_file" "sdl_daily_ingest_vuln_csm_config_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-daily-ingest-vuln-csm-config-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-daily-ingest-vuln-csm-config.zip"
  type        = "zip"
}

resource "aws_lambda_function" "sdl_daily_ingest_vuln_csm_config_data" {
  function_name    = local.sdl_daily_ingest_vuln_csm_config_lambda
  filename         = data.archive_file.sdl_daily_ingest_vuln_csm_config_zip.output_path
  role             = local.sdl_daily_ingest_vuln_csm_config_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_daily_ingest_vuln_csm_config_zip.output_path)
  timeout          = local.lambda_timeout_10_sec
  memory_size      = local.lambda_memory_size_128_MB

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.sdl_daily_ingest_vuln_csm_config_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-aws-cdm-vuln-feed
##################################################################################
data "archive_file" "sdl_aws_cdm_vuln_feed_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-aws-cdm-vuln-feed-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-aws-cdm-vuln-feed.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_aws_cdm_vuln_feed" {
  function_name    = local.sdl_aws_cdm_vuln_feed_lambda
  filename         = data.archive_file.sdl_aws_cdm_vuln_feed_zip.output_path
  role             = local.sdl_aws_cdm-vuln_feed_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_aws_cdm_vuln_feed_zip.output_path)
  timeout          = local.lambda_timeout_600_sec
  memory_size      = local.lambda_memory_size_4096_MB
  layers           = [aws_lambda_layer_version.sdl_common_layer.arn]

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.CONFIGDELEGATE_GOV_CROSS_SECRETS_ARN, local.sdl_aws_cdm_vuln_feed_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-aws-cdm-csm-feed
##################################################################################
data "archive_file" "sdl_aws_cdm_csm_feed_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-aws-cdm-csm-feed-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-aws-cdm-csm-feed.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_aws_cdm_csm_feed" {
  function_name    = local.sdl_aws_cdm_csm_feed_lambda
  filename         = data.archive_file.sdl_aws_cdm_csm_feed_zip.output_path
  role             = local.sdl_aws_cdm_csm_feed_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_aws_cdm_csm_feed_zip.output_path)
  timeout          = local.lambda_timeout_600_sec
  memory_size      = local.lambda_memory_size_4096_MB
  layers           = [aws_lambda_layer_version.sdl_common_layer.arn]

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.CONFIGDELEGATE_GOV_CROSS_SECRETS_ARN, local.sdl_aws_cdm_vuln_feed_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}


##################################################################################
#   Lambda: sdl-aws-cdm-config_data-feed
##################################################################################
data "archive_file" "sdl_aws_cdm_config_data_feed_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-aws-cdm-config-data-feed-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-aws-cdm-config-data-feed.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_aws_cdm_config_data_feed" {
  function_name    = local.sdl_aws_cdm_config_data_feed_lambda
  filename         = data.archive_file.sdl_aws_cdm_config_data_feed_zip.output_path
  role             = local.sdl_aws_cdm_config_data_feed_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_aws_cdm_config_data_feed_zip.output_path)
  timeout          = local.lambda_timeout_600_sec
  memory_size      = local.lambda_memory_size_4096_MB
  layers           = [aws_lambda_layer_version.sdl_common_layer.arn]

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.CONFIGDELEGATE_GOV_CROSS_SECRETS_ARN, local.sdl_aws_cdm_config_data_feed_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##################################################################################
#   Lambda: sdl-daily-known-exploited-vulnerabilities
##################################################################################
data "archive_file" "sdl_cisa_daily_known_exploited_vulnerabilities_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-cisa-daily-known-exploited-vulnerabilities-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-cisa-daily-known-exploited-vulnerabilities.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_cisa_daily_known_exploited_vulnerabilities" {
  function_name    = local.sdl_cisa_daily_known_exploited_vulnerabilities_lambda
  filename         = data.archive_file.sdl_cisa_daily_known_exploited_vulnerabilities_zip.output_path
  role             = local.sdl_cisa_daily_known_exploited_vulnerabilities_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_cisa_daily_known_exploited_vulnerabilities_zip.output_path)
  timeout          = local.lambda_timeout_10_sec
  memory_size      = local.lambda_memory_size_128_MB

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.sdl_cisa_daily_known_exploited_vulnerabilities_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-daily-init
##################################################################################
data "archive_file" "sdl_daily_init_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-daily-init-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-daily-init.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_daily_init" {
  function_name    = local.sdl_daily_init_lambda
  filename         = data.archive_file.sdl_daily_init_zip.output_path
  role             = local.sdl_daily_init_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_daily_init_zip.output_path)
  timeout          = local.lambda_timeout_10_sec
  memory_size      = local.lambda_memory_size_128_MB

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.sdl_daily_init_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-cdm-securitycenter
##################################################################################
data "archive_file" "sdl_cdm_securitycenter_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-cdm-securitycenter-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-cdm-securitycenter.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_cdm_securitycenter" {
  function_name    = local.sdl_cdm_securitycenter_lambda
  filename         = data.archive_file.sdl_cdm_securitycenter_zip.output_path
  role             = local.sdl_cdm_securitycenter_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_cdm_securitycenter_zip.output_path)
  timeout          = local.lambda_timeout_900_sec
  memory_size      = local.lambda_memory_size_10240_MB
  layers           = [aws_lambda_layer_version.sdl_lambda_layer.arn]

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.SECURITYCENTER_SECRET_NAME, local.sdl_cdm_securitycenter_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-cdm-securitycenter-feeds
##################################################################################
data "archive_file" "sdl_cdm_securitycenter_feeds_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-cdm-securitycenter-feeds-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-cdm-securitycenter-feeds.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_cdm_securitycenter_feeds" {
  function_name    = local.sdl_cdm_securitycenter_feeds_lambda
  filename         = data.archive_file.sdl_cdm_securitycenter_feeds_zip.output_path
  role             = local.sdl_securitycenter_feeds_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_cdm_securitycenter_feeds_zip.output_path)
  timeout          = local.lambda_timeout_600_sec
  memory_size      = local.lambda_memory_size_4096_MB
  layers           = [aws_lambda_layer_version.sdl_lambda_layer.arn]

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.SECURITYCENTER_SECRET_NAME, local.sdl_securitycenter_feeds_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-aws-networking-feed
##################################################################################
data "archive_file" "sdl_aws_networking_feed_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-aws-networking-feed-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-aws-networking-feed.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_aws_networking_feed" {
  function_name    = local.sdl_aws_networking_feed_lambda
  filename         = data.archive_file.sdl_aws_networking_feed_zip.output_path
  role             = local.sdl_aws_networking_feed_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_aws_networking_feed_zip.output_path)
  timeout          = local.lambda_timeout_900_sec
  memory_size      = local.lambda_memory_size_4096_MB
  layers           = [aws_lambda_layer_version.sdl_lambda_layer.arn]

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.CONFIGDELEGATE_GOV_CROSS_SECRETS_ARN, local.sdl_aws_networking_feed_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-monitoring-notifications
##################################################################################
data "archive_file" "sdl_monitoring_notifications_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-monitoring-notifications-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-monitoring-notifications.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_monitoring_notifications" {
  function_name    = local.sdl_monitoring_notifications_lambda
  filename         = data.archive_file.sdl_monitoring_notifications_zip.output_path
  role             = local.sdl_monitoring_notifications_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_monitoring_notifications_zip.output_path)
  timeout          = local.lambda_timeout_30_sec
  memory_size      = local.lambda_memory_size_128_MB

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.sdl_monitoring_notifications_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-missing-files-notification
##################################################################################
data "archive_file" "sdl_missing_files_notification_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-missing-files-notification-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-missing-files-notification.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_missing_files_notification" {
  function_name    = local.sdl_missing_files_notification_lambda
  filename         = data.archive_file.sdl_missing_files_notification_zip.output_path
  role             = local.sdl_missing_files_notification_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_missing_files_notification_zip.output_path)
  timeout          = local.lambda_timeout_600_sec
  memory_size      = local.lambda_memory_size_10240_MB

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.sdl_missing_files_notification_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-aws-iam-feed
##################################################################################
data "archive_file" "sdl_aws_iam_feed_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-aws-iam-feed-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-aws-iam-feed.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_aws_iam_feed" {
  function_name    = local.sdl_aws_iam_feed_lambda
  filename         = data.archive_file.sdl_aws_iam_feed_zip.output_path
  role             = local.sdl_aws_iam_feed_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_aws_iam_feed_zip.output_path)
  timeout          = local.lambda_timeout_900_sec
  memory_size      = local.lambda_memory_size_2048_MB
  layers           = [aws_lambda_layer_version.sdl_lambda_layer.arn]

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.CONFIGDELEGATE_GOV_SECRETS_ARN, local.sdl_aws_iam_feed_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}


##################################################################################
#   Lambda: sdl-aws-cdm-feed
##################################################################################
data "archive_file" "sdl_aws_cdm_feed_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-aws-cdm-feed-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-aws-cdm-feed.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_aws_cdm_feed" {
  function_name    = local.sdl_aws_cdm_feed_lambda
  filename         = data.archive_file.sdl_aws_cdm_feed_zip.output_path
  role             = local.sdl_aws_cdm_feed_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_aws_cdm_feed_zip.output_path)
  timeout          = local.lambda_timeout_900_sec
  memory_size      = local.lambda_memory_size_4096_MB
  layers           = [aws_lambda_layer_version.sdl_lambda_layer.arn]

  environment {
    variables      = merge(local.BUCKET_AND_DATACENTERS, local.CONFIGDELEGATE_GOV_CROSS_SECRETS_ARN, local.sdl_aws_cdm_feed_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-aws-dc-acct
##################################################################################
data "archive_file" "sdl_aws_dc_acct_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-aws-dc-acct-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-aws-dc-acct.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_aws_dc_acct" {
  function_name    = local.sdl_aws_dc_acct_lambda
  filename         = data.archive_file.sdl_aws_dc_acct_zip.output_path
  role             = local.sdl_aws_dc_acct_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_aws_dc_acct_zip.output_path)
  timeout          = local.lambda_timeout_900_sec
  memory_size      = local.lambda_memory_size_4096_MB

  environment {
    #variables      = merge(local.BUCKET_AND_DATACENTERS, local.sdl_aws_dc_acct_ENV, {CONFIGDELEGATE = local.CONFIGDELEGATE_SECRET_ARN, CONFIGDELEGATEGOVCLOUD = local.CONFIGDELEGATEGOVCLOUD_SECRET_ARN})
     variables = merge(local.BUCKET_AND_DATACENTERS, local.CONFIGDELEGATE_GOV_SECRETS_ARN, local.sdl_aws_dc_acct_ENV)
  }

  tracing_config {
    mode = "PassThrough"
  }
}

##################################################################################
#   Lambda: sdl-split-stream
##################################################################################
data "archive_file" "sdl_split_stream_zip" {
  source_dir  = "${path.module}/sdl-lambda-files/sdl-split-stream-files/"
  output_path = "${path.module}/sdl-lambda-zip/sdl-split-stream.zip"
  type        = "zip"

}

resource "aws_lambda_function" "sdl_split_stream" {
  function_name    = local.sdl_split_stream_lambda
  filename         = data.archive_file.sdl_split_stream_zip.output_path
  role             = local.sdl_split_stream_role_arn
  handler          = local.lambda_handler
  runtime          = local.python3_9
  source_code_hash = filebase64sha256(data.archive_file.sdl_split_stream_zip.output_path)
  timeout          = local.lambda_timeout_900_sec
  memory_size      = local.lambda_memory_size_4096_MB

  environment {
    variables      = local.BUCKET_AND_DATACENTERS
  }

  tracing_config {
    mode = "PassThrough"
  }
}









































































































































































































































































































































































































































































































































































































































































