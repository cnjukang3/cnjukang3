##########################################################################
#       POLICIES/ROLES MODULE
##########################################################################

#########################################################################
# variables stored in variables.tf file
#########################################################################
locals {
  sdl_bucket_prefix_with_wildcard   = var.sdl_bucket_arn_prefix_with_wildcard
  sdl_bucket_prefix                 = var.sdl_bucket_arn_prefix
  sdl_config_path_wildcard          = var.sdl_config_arn_path_with_wildcard
  sdl_permission_boundary           = var.sdl_permission_boundary_for_iam_role

  sdl_govcloud_secrets_manager       = var.sdl_govcloud_secrets_manager_arn
  sdl_commercial_secrets_manager     = var.sdl_commercial_secrets_manager_arn
  sdl_securitycenter_secrets_manager = var.sdl_securitycenter_secrets_manager_arn

  sdl_aws_iam_feed                   = var.sdl_aws_iam_feed
  sdl_aws_iam_feed_log_group         = var.sdl_aws_iam_feed_log_group_arn
  sdl_daily_ingest_vuln_csm_config   = var.sdl_daily_ingest_vuln_csm_config
  sdl_aws_cdm_vuln_feed              = var.sdl_aws_cdm_vuln_feed
  sdl_aws_cdm_config_data_feed       = var.sdl_aws_cdm_config_data_feed

  sdl_aws_cdm_csm_feed               = var.sdl_aws_cdm_csm_feed
  sdl_cisa_daily_known_exploited_vulnerabilities = var.sdl_cisa_daily_known_exploited_vulnerabilities
  sdl_cdm_securitycenter             = var.sdl_cdm_securitycenter
  sdl_cdm_govcloud                   = var.sdl_cdm_govcloud

  sdl_cdm_aws                        = var.sdl_cdm_aws
  sdl_daily_init                     = var.sdl_daily_init
  sdl_daily_aws_vcc                  = var.sdl_daily_aws_vcc
  sdl_aws_feeds                      = var.sdl_aws_feeds
  sdl_aws_networking_feed            = var.sdl_aws_networking_feed
  sdl_aws_cdm_feed                   = var.sdl_aws_cdm_feed
  sdl_securitycenter_feeds           = var.sdl_securitycenter_feeds
  sdl_aws_dc_acct                    = var.sdl_aws_dc_acct
  sdl_camp_feed                      = var.sdl_camp_feed
  sdl_snyk_issues                    = var.sdl_snyk_issues
  sdl_split_stream                   = var.sdl_split_stream

  # Step Function policies/roles variables
  sdl_daily_aws                      = var.sdl_daily_aws
  sdl_daily_ingest                   = var.sdl_daily_ingest
  sdl_daily_securitycenter           = var.sdl_daily_securitycenter

  # lambda function notifications policies/roles variables
  sdl_monitoring_notifications       = var.sdl_monitoring_notifications
  sdl_missing_files_notification     = var.sdl_missing_files_notification

  sdl_govcloud_state_machine         = var.sdl_govcloud_state_machine_arn
}

####################################################################################
#                                IAM POLICIES                                      #
####################################################################################

####################################################################################
# sdl-aws-iam-feed policy document
###################################################################################

# sts assume role
data "aws_iam_policy_document" "sdl_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = [
        "lambda.amazonaws.com",
        "states.amazonaws.com",
        "events.amazonaws.com",
        ]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "sdl_aws_iam_feed" {
  version = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = [local.sdl_aws_iam_feed_log_group]
  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
  statement {
    effect    = "Allow"
    sid       = "AssumeRoleConfigCommercial"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

# resource for sdl-aws-iam-feed policy
resource "aws_iam_policy" "policy_document_sdl_aws_iam_feed" {
  description = "lambda Policy: sdl-aws-iam-feed for read/write and list s3"
  name        = local.sdl_aws_iam_feed
  policy      = data.aws_iam_policy_document.sdl_aws_iam_feed.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

resource "aws_iam_role"  "sdl_aws_iam_feed_role"{
  description           = "lambda role for sdl-aws-iam-feed policy"
  name                  = local.sdl_aws_iam_feed
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-aws-iam-feed policy
resource "aws_iam_role_policy_attachment" "attach_sdl_aws_iam_feed" {
  role       = aws_iam_role.sdl_aws_iam_feed_role.name
  policy_arn = aws_iam_policy.policy_document_sdl_aws_iam_feed.arn
}

########################################################################
# sdl-daily-ingest-vuln-csm-config policy document
########################################################################
data aws_iam_policy_document "sdl_daily_ingest_vuln_csm_config" {
   version = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
  statement {
    sid       = "InvokeLambdas"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["arn:aws:lambda:us-east-1:*:function:*"]
  }
  statement {
    sid     = "InvokeStepFunctions"
    effect  = "Allow"
    actions = [
      "states:StartExecution",
      "states:StopExecution"
    ]
    resources = ["arn:aws:states:us-east-1:*:stateMachine:*"]
  }
  statement {
    sid     = "StepFunctionSync"
    effect  = "Allow"
    actions = [
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]
    resources = ["*"]
  }
}

# resource policy for sdl-daily-ingest-vuln-csm-config
resource "aws_iam_policy" "sdl_daily_ingest_vuln_csm_config" {
  description = "lambda Policy: sdl-daily-ingest-vuln-csm-config for read/write and list s3"
  name = local.sdl_daily_ingest_vuln_csm_config
  policy = data.aws_iam_policy_document.sdl_daily_ingest_vuln_csm_config.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-daily-ingest-vuln-csm-config
resource "aws_iam_role" "sdl_daily_ingest_vuln_csm_config_role" {
  description = "lambda role for sdl-daily-ingest-vuln_csm-config"
  name = local.sdl_daily_ingest_vuln_csm_config
  assume_role_policy = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach the sdl-daily-ingest-vuln-csn-config policy
resource "aws_iam_role_policy_attachment" "attach_sdl_daily_ingest_vuln_csm_config" {
  policy_arn = aws_iam_policy.sdl_daily_ingest_vuln_csm_config.arn
  role       = aws_iam_role.sdl_daily_ingest_vuln_csm_config_role.name
}

########################################################################
# sdl-aws-cdm-vuln-feed policy document
########################################################################

data "aws_iam_policy_document" "sdl_aws_cdm_vuln_feed" {
  version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
  statement {
    sid       = "SDLGovCloudSecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.sdl_govcloud_secrets_manager, local.sdl_commercial_secrets_manager]

  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
}
# resource for sdl-aws-cdm-vuln-feed policy
resource "aws_iam_policy" "policy_document_sdl_aws_cdm_vuln_feed" {
  description = "lambda Policy: sdl-aws-cdm-vuln-feed for read/write and list s3"
  name        = local.sdl_aws_cdm_vuln_feed
  policy      = data.aws_iam_policy_document.sdl_aws_cdm_vuln_feed.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-aws-cdm-vuln-feed
resource "aws_iam_role"  "sdl_aws_cdm_vuln_feed_role"{
  description           = "lambda role for sdl-aws-cdm-vuln-feed policy"
  name                  = local.sdl_aws_cdm_vuln_feed
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-aws-cdm-vuln-feed policy
resource "aws_iam_role_policy_attachment" "attach_sdl_aws_cdm_vuln_feed" {
  policy_arn = aws_iam_policy.policy_document_sdl_aws_cdm_vuln_feed.arn
  role       = aws_iam_role.sdl_aws_cdm_vuln_feed_role.name
}

########################################################################
# sdl-aws-cdm-csm-feed policy document
########################################################################
data "aws_iam_policy_document" "sdl_aws_cdm_csm_feed" {
  version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "SDLGovCloudSecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.sdl_govcloud_secrets_manager, local.sdl_commercial_secrets_manager]

  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
}

# resource policy for sdl-aws-cdm-csm-feed
resource "aws_iam_policy" "policy_document_sdl_aws_cdm_csm_feed" {
  description = "lambda Policy: sdl-aws-cdm-vuln-feed for read/write and list s3"
  name        = local.sdl_aws_cdm_csm_feed
  policy      = data.aws_iam_policy_document.sdl_aws_cdm_csm_feed.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-aws-cdm-csm-feed
resource "aws_iam_role"  "sdl_aws_cdm_csm_feed_role"{
  description           = "lambda role for sdl-aws-cdm-csm-feed policy"
  name                  = local.sdl_aws_cdm_csm_feed
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-aws-cdm-csm-feed policy
resource "aws_iam_role_policy_attachment" "attach_sdl_aws_cdm_csm_feed" {
  policy_arn = aws_iam_policy.policy_document_sdl_aws_cdm_csm_feed.arn
  role       = aws_iam_role.sdl_aws_cdm_csm_feed_role.name
}

########################################################################
# sdl-aws-cdm-config_data-feed policy document
########################################################################
data "aws_iam_policy_document" "sdl_aws_cdm_config_data_feed" {
  version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "SDLGovCloudSecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.sdl_govcloud_secrets_manager, local.sdl_commercial_secrets_manager]

  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
}
# resource for sdl-aws-cdm-config_data-feed policy
resource "aws_iam_policy" "policy_document_sdl_aws_cdm_config_data_feed" {
  description = "lambda Policy: sdl-aws-cdm-config_data-feed for read/write and list s3"
  name        = local.sdl_aws_cdm_config_data_feed
  policy      = data.aws_iam_policy_document.sdl_aws_cdm_config_data_feed.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-aws-cdm-config_data-feed
resource "aws_iam_role"  "sdl_aws_cdm_config_data_feed_role"{
  description           = "lambda role for sdl-aws-cdm-config_data-feed policy"
  name                  = local.sdl_aws_cdm_config_data_feed
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-aws-cdm-config_data-feed policy
resource "aws_iam_role_policy_attachment" "attach_sdl_aws_cdm_config_data_feed" {
  policy_arn = aws_iam_policy.policy_document_sdl_aws_cdm_config_data_feed.arn
  role       = aws_iam_role.sdl_aws_cdm_config_data_feed_role.name
}

########################################################################
# sdl-cisa-daily-known-exploited-vulnerabilities policy document
########################################################################
data "aws_iam_policy_document" "sdl_cisa_daily_known_exploited_vulnerabilities" {
  version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "SDLGovCloudSecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.sdl_govcloud_secrets_manager, local.sdl_commercial_secrets_manager]

  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
}
# resource for sdl-cisa-daily-known-exploited-vulnerabilities policy
resource "aws_iam_policy" "policy_document_sdl_cisa_daily_known_exploited_vulnerabilities" {
  description = "lambda Policy: sdl-cisa-daily-known-exploited-vulnerabilities for read/write and list s3"
  name        = local.sdl_cisa_daily_known_exploited_vulnerabilities
  policy      = data.aws_iam_policy_document.sdl_cisa_daily_known_exploited_vulnerabilities.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-cisa-daily-known-exploited-vulnerabilities
resource "aws_iam_role"  "sdl_cisa_daily_known_exploited_vulnerabilities_role"{
  description           = "lambda role for sdl_cisa_daily_known_exploited_vulnerabilities policy"
  name                  = local.sdl_cisa_daily_known_exploited_vulnerabilities
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-cisa-daily-known-exploited-vulnerabilities policy
resource "aws_iam_role_policy_attachment" "attach_sdl_cisa_daily_known_exploited_vulnerabilities" {
  policy_arn = aws_iam_policy.policy_document_sdl_cisa_daily_known_exploited_vulnerabilities.arn
  role       = aws_iam_role.sdl_cisa_daily_known_exploited_vulnerabilities_role.name
}

########################################################################
# sdl-aws-cdm-govcloud-feed policy document
########################################################################
data "aws_iam_policy_document" "sdl_cdm_govcloud" {
  version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "SDLGovCloudSecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.sdl_govcloud_secrets_manager, local.sdl_commercial_secrets_manager]

  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
  statement {
    sid = "InitStateMachine"
    effect = "Allow"
    actions = ["states:StartExecution"]
    resources = [local.sdl_govcloud_state_machine]
  }
}

# resource for sdl-cdm-govcloud policy
resource "aws_iam_policy" "policy_document_sdl_cdm_govcloud" {
  description = "lambda Policy: sdl-cdm-govcloud for read/write and list s3"
  name        = local.sdl_cdm_govcloud
  policy      = data.aws_iam_policy_document.sdl_cdm_govcloud.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-cdm-govcloud
resource "aws_iam_role"  "sdl_cdm_govcloud_role" {
  description             = "lambda role for sdl-cdm-govcloud policy"
  name                    = local.sdl_cdm_govcloud
  assume_role_policy      = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-cdm-govcloud policy
resource "aws_iam_role_policy_attachment" "attach_sdl_cdm_govcloud" {
  policy_arn = aws_iam_policy.policy_document_sdl_cdm_govcloud.arn
  role       = aws_iam_role.sdl_cdm_govcloud_role.name
}

########################################################################
# sdl-cdm-securitycenter policy document for lambda function
########################################################################

data "aws_iam_policy_document" "sdl-cdm-securitycenter" {
   version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
  statement {
    sid     = "CreateNetWorking"
    effect  = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
   statement {
    sid       = "SDLSecuritycenterSecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.sdl_securitycenter_secrets_manager]

  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
}

# resource policy for sdl-cdm-securitycenter
resource "aws_iam_policy" "policy_document_sdl_cdm_securitycenter" {
  description = "lambda Policy: sdl-cdm-securitycenter for read/write and list s3"
  name         = local.sdl_cdm_securitycenter
  policy       = data.aws_iam_policy_document.sdl-cdm-securitycenter.json

  depends_on   = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-cdm-securitycenter
resource "aws_iam_role" "sdl_cdm_securitycenter_role" {
  description             = "lambda role for sdl-cdm-securitycenter"
  name                    = local.sdl_cdm_securitycenter
  assume_role_policy      =  data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-cdm-securitycenter policy
resource "aws_iam_role_policy_attachment" "attach_sdl_cdm_securitycenter" {
  policy_arn = aws_iam_policy.policy_document_sdl_cdm_securitycenter.arn
  role       = aws_iam_role.sdl_cdm_securitycenter_role.name
}

########################################################################
# sdl-cdm-aws policy document
########################################################################
data "aws_iam_policy_document" "sdl_cdm_aws" {
  version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "SDLGovCloudSecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.sdl_govcloud_secrets_manager, local.sdl_commercial_secrets_manager]

  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
}
# resource for sdl-cdm-aws policy
resource "aws_iam_policy" "policy_document_sdl_cdm_aws" {
  description = "lambda Policy: sdl-cdm-aws for read/write and list s3"
  name        = local.sdl_cdm_aws
  policy      = data.aws_iam_policy_document.sdl_cdm_aws.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-cdm-aws
resource "aws_iam_role"  "sdl_cdm_aws_role"{
  description           = "lambda role for sdl-cdm-aws policy"
  name                  = local.sdl_cdm_aws
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-cdm-aws policy
resource "aws_iam_role_policy_attachment" "attach_sdl_cdm_aws" {
  policy_arn = aws_iam_policy.policy_document_sdl_cdm_aws.arn
  role       = aws_iam_role.sdl_cdm_aws_role.name
}

########################################################################
# sdl-monitoring-notifications policy document for lambda function
########################################################################
data "aws_iam_policy_document" "sdl_monitoring_notifications" {
  version = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
  statement {
    sid = "InvokeLambdaSNS"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "sns:Publish",
      "sns:Subscribe",
      "sns:CreateTopic",
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:TagResource",
      "sns:UntagResource",
      "sns:ListTagsForResource",
      "sns:ListSubscriptionsByTopic"
    ]
    resources = ["arn:aws:lambda:us-east-1:*:function:*"]
  }

}

# resource for sdl-monitoring-notifications policy
resource "aws_iam_policy" "policy_document_sdl_monitoring_notifications" {
  description = "lambda Policy: sdl-monitoring-notifications for read/write and list s3"
  name        = local.sdl_monitoring_notifications
  policy      = data.aws_iam_policy_document.sdl_monitoring_notifications.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-monitoring-notifications
resource "aws_iam_role"  "sdl_monitoring_notifications_role"{
  description           = "lambda role for sdl-monitoring-notifications policy"
  name                  = local.sdl_monitoring_notifications
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-monitoring-notifications policy
resource "aws_iam_role_policy_attachment" "attach_sdl_monitoring_notifications" {
  policy_arn = aws_iam_policy.policy_document_sdl_monitoring_notifications.arn
  role       = aws_iam_role.sdl_monitoring_notifications_role.name
}

########################################################################
# sdl-missing-files-notification policy document for lambda function
########################################################################
data "aws_iam_policy_document" "sdl_missing_files_notification" {
  version = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
  statement {
    sid = "InvokeLambdaSNS"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "sns:Publish",
      "sns:Subscribe",
      "sns:CreateTopic",
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:TagResource",
      "sns:UntagResource",
      "sns:ListTagsForResource",
      "sns:ListSubscriptionsByTopic"
    ]
    resources = ["arn:aws:lambda:us-east-1:*:function:*"]
  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid = "ReadWriteConfigResults"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject*",
      "s3:DeleteObject*"
    ]
    resources = [local.sdl_config_path_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
}

# resource for sdl-missing-files-notification policy
resource "aws_iam_policy" "policy_document_sdl_missing_files_notification" {
  description = "lambda Policy: sdl-missing-files-notification for checking the missing files in s3"
  name        = local.sdl_missing_files_notification
  policy      = data.aws_iam_policy_document.sdl_missing_files_notification.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-missing-files-notification
resource "aws_iam_role"  "sdl_missing_files_notification_role"{
  description           = "lambda role for sdl-missing-files-notification policy"
  name                  = local.sdl_missing_files_notification
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-missing-files-notification policy
resource "aws_iam_role_policy_attachment" "attach_sdl_missing_files_notification" {
  policy_arn = aws_iam_policy.policy_document_sdl_missing_files_notification.arn
  role       = aws_iam_role.sdl_missing_files_notification_role.name
}

########################################################################
# sdl-daily-init policy document for Step Function
########################################################################
data "aws_iam_policy_document" "sdl_daily_init" {
  version = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivered",
      "logs:UpdateLogDelivered",
      "logs:DeleteLogDelivered",
      "logs:ListLogDelivered",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }
  statement {
    sid     = "StepFunctionSync"
    effect  = "Allow"
    actions = [
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "InvokeStepFunction"
    effect    = "Allow"
    actions   = ["states:StartExecution"]
    resources = ["arn:aws:states:us-east-1:*:stateMachine:*"]
  }
  statement {
    sid       = "InvokeLambda"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["arn:aws:lambda:us-east-1:*:functions:*"]
  }
}

# resource for sdl-daily-init policy
resource "aws_iam_policy" "policy_document_sdl_daily_init" {
  description = "lambda Policy: sdl-daily-init for read/write and list s3"
  name        = local.sdl_daily_init
  policy      = data.aws_iam_policy_document.sdl_daily_init.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-daily-init
resource "aws_iam_role"  "sdl_daily_init_role"{
  description           = "lambda role for sdl-daily-init policy"
  name                  = local.sdl_daily_init
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-daily-init policy
resource "aws_iam_role_policy_attachment" "attach_sdl_daily_init" {
  policy_arn = aws_iam_policy.policy_document_sdl_daily_init.arn
  role       = aws_iam_role.sdl_daily_init_role.name
}

########################################################################
# sdl-daily-aws-vcc policy document for Step Function
########################################################################
data "aws_iam_policy_document" "sdl_daily_aws_vcc" {
  version = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivered",
      "logs:UpdateLogDelivered",
      "logs:DeleteLogDelivered",
      "logs:ListLogDelivered",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "InvokeLambda"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["arn:aws:lambda:us-east-1:*:functions:*"]
  }
}

# resource for sdl-daily-aws_vcc policy
resource "aws_iam_policy" "policy_document_sdl_daily_aws_vcc" {
  description = "lambda Policy: sdl-daily-aws-vcc for Step Function"
  name        = local.sdl_daily_aws_vcc
  policy      = data.aws_iam_policy_document.sdl_daily_aws_vcc.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-daily-aws-vcc
resource "aws_iam_role"  "sdl_daily_aws_vcc_role"{
  description           = "lambda role for sdl-daily-aws-vcc policy"
  name                  = local.sdl_daily_aws_vcc
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-daily-aws-vcc policy
resource "aws_iam_role_policy_attachment" "attach_sdl_daily_aws_vcc" {
  policy_arn = aws_iam_policy.policy_document_sdl_daily_aws_vcc.arn
  role       = aws_iam_role.sdl_daily_aws_vcc_role.name
}

########################################################################
# sdl-aws-feeds policy document for lambda function
########################################################################

data "aws_iam_policy_document" "sdl_aws_feeds" {
  version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
  statement {
    sid       = "SDLGovCloudSecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.sdl_govcloud_secrets_manager, local.sdl_commercial_secrets_manager]

  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
}

# resource for sdl-aws-feeds policy
resource "aws_iam_policy" "policy_document_sdl_aws_feeds" {
  description = "lambda Policy: sdl-aws-feeds for read/write and list s3"
  name        = local.sdl_aws_feeds
  policy      = data.aws_iam_policy_document.sdl_aws_feeds.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-aws-feeds
resource "aws_iam_role"  "sdl_aws_feeds_role"{
  description           = "lambda role for sdl-aws-feeds policy"
  name                  = local.sdl_aws_feeds
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-aws-feeds policy
resource "aws_iam_role_policy_attachment" "attach_sdl_aws_feeds" {
  policy_arn = aws_iam_policy.policy_document_sdl_aws_feeds.arn
  role       = aws_iam_role.sdl_aws_feeds_role.name
}

########################################################################
# sdl-daily-aws policy document for Step Function
########################################################################
data "aws_iam_policy_document" "sdl_daily_aws" {
  version = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivered",
      "logs:UpdateLogDelivered",
      "logs:DeleteLogDelivered",
      "logs:ListLogDelivered",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "InvokeLambda"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["arn:aws:lambda:us-east-1:*:functions:*"]
  }
}

# resource for sdl-daily-aws policy
resource "aws_iam_policy" "policy_document_sdl_daily_aws" {
  description = "lambda Policy: sdl-daily-aws Step Function"
  name        = local.sdl_daily_aws
  policy      = data.aws_iam_policy_document.sdl_daily_aws.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-daily-aws
resource "aws_iam_role"  "sdl_daily_aws_role"{
  description           = "lambda role for sdl-daily-aws policy"
  name                  = local.sdl_daily_aws
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-daily-aws policy
resource "aws_iam_role_policy_attachment" "attach_sdl_daily_aws" {
  policy_arn = aws_iam_policy.policy_document_sdl_daily_aws.arn
  role       = aws_iam_role.sdl_daily_aws_role.name
}

########################################################################
# sdl-aws-networking-feed policy document for lambda function
########################################################################

data "aws_iam_policy_document" "sdl_aws_networking_feed" {
  version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
  statement {
    sid       = "SDLGovCloudSecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.sdl_govcloud_secrets_manager, local.sdl_commercial_secrets_manager]

  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
}
# resource for sdl-aws-networking-feed policy
resource "aws_iam_policy" "policy_document_sdl_aws_networking_feed" {
  description = "lambda Policy: sdl-aws-networking-feed for read/write and list s3"
  name        = local.sdl_aws_networking_feed
  
  policy      = data.aws_iam_policy_document.sdl_aws_networking_feed.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-aws-networking-feed
resource "aws_iam_role"  "sdl_aws_networking_feed_role"{
  description           = "lambda role for sdl-aws-networking-feed policy"
  name                  = local.sdl_aws_networking_feed
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-aws-networking-feed policy
resource "aws_iam_role_policy_attachment" "attach_sdl_aws_networking_feed" {
  policy_arn = aws_iam_policy.policy_document_sdl_aws_networking_feed.arn
  role       = aws_iam_role.sdl_aws_networking_feed_role.name
}

########################################################################
# sdl-aws-cdm--feed policy document for lambda function
########################################################################

data "aws_iam_policy_document" "sdl_aws_cdm_feed" {
  version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
  statement {
    sid       = "SDLGovCloudSecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.sdl_govcloud_secrets_manager, local.sdl_commercial_secrets_manager]

  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
}
# resource for sdl-aws-cdm-feed policy
resource "aws_iam_policy" "policy_document_sdl_aws_cdm_feed" {
  description = "lambda Policy: sdl-aws-cdm-feed for read/write and list s3"
  name        = local.sdl_aws_cdm_feed
  
  policy      = data.aws_iam_policy_document.sdl_aws_cdm_feed.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-aws-cdm-feed
resource "aws_iam_role"  "sdl_aws_cdm_feed_role"{
  description           = "lambda role for sdl-aws-cdm-feed policy"
  name                  = local.sdl_aws_cdm_feed
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-aws-cdm-feed policy
resource "aws_iam_role_policy_attachment" "attach_sdl_aws_cdm_feed" {
  policy_arn = aws_iam_policy.policy_document_sdl_aws_cdm_feed.arn
  role       = aws_iam_role.sdl_aws_cdm_feed_role.name
}

########################################################################
# sdl-securitycenter-feeds policy document for lambda function
########################################################################

data "aws_iam_policy_document" "sdl-securitycenter-feeds" {
   version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
  statement {
    sid     = "CreateNetWorking"
    effect  = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
   statement {
    sid       = "SDLSecuritycenterSecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.sdl_securitycenter_secrets_manager]

  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid = "ReadWriteConfigResults"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject*",
      "s3:DeleteObject*"
    ]
    resources = [local.sdl_config_path_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
}

# resource policy for sdl-securitycenter-feeds
resource "aws_iam_policy" "policy_document_sdl_securitycenter_feeds" {
  description = "lambda Policy: sdl-securitycenter-feeds for read/write and list s3"
  name         = local.sdl_securitycenter_feeds
  policy       = data.aws_iam_policy_document.sdl-securitycenter-feeds.json

  depends_on   = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-securitycenter-feeds
resource "aws_iam_role" "sdl_securitycenter_feeds_role" {
  description             = "lambda role for sdl-securitycenter-feeds"
  name                    = local.sdl_securitycenter_feeds
  assume_role_policy      =  data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-securitycenter-feeds policy
resource "aws_iam_role_policy_attachment" "attach_sdl_securitycenter-feeds" {
  policy_arn = aws_iam_policy.policy_document_sdl_securitycenter_feeds.arn
  role       = aws_iam_role.sdl_securitycenter_feeds_role.name
}

########################################################################
# sdl-daily-ingest policy document for Step Function
########################################################################
data "aws_iam_policy_document" "sdl_daily_ingest" {
  version = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivered",
      "logs:UpdateLogDelivered",
      "logs:DeleteLogDelivered",
      "logs:ListLogDelivered",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }
  statement {
    sid     = "StepFunctionSync"
    effect  = "Allow"
    actions = [
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "InvokeStepFunction"
    effect    = "Allow"
    actions   = [
      "states:StartExecution",
      "states:StopExecution"
    ]
    resources = ["arn:aws:states:us-east-1:*:stateMachine:*"]
  }
  statement {
    sid       = "InvokeLambda"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["arn:aws:lambda:us-east-1:*:functions:*"]
  }
}

# resource for sdl-daily-ingest policy
resource "aws_iam_policy" "policy_document_sdl_daily_ingest" {
  description = "lambda Policy: sdl-daily-init for Step Function"
  name        = local.sdl_daily_ingest
  
  policy      = data.aws_iam_policy_document.sdl_daily_ingest.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-daily-ingest
resource "aws_iam_role"  "sdl_daily_ingest_role"{
  description           = "lambda role for sdl-daily-ingest policy"
  name                  = local.sdl_daily_ingest
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-daily-ingest policy
resource "aws_iam_role_policy_attachment" "attach_sdl_daily_ingest" {
  policy_arn = aws_iam_policy.policy_document_sdl_daily_ingest.arn
  role       = aws_iam_role.sdl_daily_ingest_role.name
}

########################################################################
# sdl-aws-dc-acct policy document
########################################################################

data "aws_iam_policy_document" "sdl_aws_dc_acct" {
  version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
  statement {
    sid       = "SDLGovCloudSecretsManager"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.sdl_govcloud_secrets_manager, local.sdl_commercial_secrets_manager]

  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
}

# resource for sdl-aws-dc-acct policy
resource "aws_iam_policy" "policy_document_sdl_aws_dc_acct" {
  description = "lambda Policy: sdl-aws-dc-acct lambda function"
  name        = local.sdl_aws_dc_acct
  policy      = data.aws_iam_policy_document.sdl_aws_dc_acct.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-aws-dc-acct
resource "aws_iam_role"  "sdl_aws_dc_acct_role"{
  description           = "lambda role for sdl-aws-dc-acct policy"
  name                  = local.sdl_aws_dc_acct
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-aws-dc-acct policy
resource "aws_iam_role_policy_attachment" "attach_sdl_aws_dc_acct" {
  policy_arn = aws_iam_policy.policy_document_sdl_aws_dc_acct.arn
  role       = aws_iam_role.sdl_aws_dc_acct_role.name
}

########################################################################
# sdl-camp-feed policy document
########################################################################

data "aws_iam_policy_document" "sdl_camp_feed" {
  version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
 statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
}

# resource for sdl-camp-feed policy
resource "aws_iam_policy" "policy_document_sdl_camp_feed" {
  description = "lambda Policy: sdl-camp-feed lambda function"
  name        = local.sdl_camp_feed
  policy      = data.aws_iam_policy_document.sdl_camp_feed.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-camp-feed
resource "aws_iam_role"  "sdl_camp_feed_role"{
  description           = "lambda role for sdl-camp-feed policy"
  name                  = local.sdl_camp_feed
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-camp-feed policy
resource "aws_iam_role_policy_attachment" "attach_sdl_camp_feed" {
  policy_arn = aws_iam_policy.policy_document_sdl_camp_feed.arn
  role       = aws_iam_role.sdl_camp_feed_role.name
}

########################################################################
# sdl-daily-securitycenter policy document for Step Function
########################################################################
data "aws_iam_policy_document" "sdl_daily_securitycenter" {
  version = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivered",
      "logs:UpdateLogDelivered",
      "logs:DeleteLogDelivered",
      "logs:ListLogDelivered",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "InvokeLambda"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["arn:aws:lambda:us-east-1:*:functions:*"]
  }
}

# resource for sdl-daily-securitycenter policy
resource "aws_iam_policy" "policy_document_sdl_daily_securitycenter" {
  description = "lambda Policy: sdl-daily-securitycenter for Step Function"
  name        = local.sdl_daily_securitycenter
  policy      = data.aws_iam_policy_document.sdl_daily_securitycenter.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-daily-securitycenter
resource "aws_iam_role"  "sdl_daily_securitycenter_role"{
  description           = "lambda role for sdl-daily-securitycenter policy"
  name                  = local.sdl_daily_securitycenter
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-daily-securitycenter policy
resource "aws_iam_role_policy_attachment" "attach_sdl_daily_securitycenter" {
  policy_arn = aws_iam_policy.policy_document_sdl_daily_securitycenter.arn
  role       = aws_iam_role.sdl_daily_securitycenter_role.name
}

########################################################################
# sdl-snyk-issues policy document
########################################################################

data "aws_iam_policy_document" "sdl_snyk_issues" {
  version   = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
 statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
}

# resource for sdl-snyk-issues policy
resource "aws_iam_policy" "policy_document_sdl_snyk_issues" {
  description = "lambda Policy: sdl-snyk-issues lambda function"
  name        = local.sdl_snyk_issues
  policy      = data.aws_iam_policy_document.sdl_snyk_issues.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-snyk-issues
resource "aws_iam_role"  "sdl_snyk_issues_role"{
  description           = "lambda role for sdl-aws-dc-acct policy"
  name                  = local.sdl_snyk_issues
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-snyk-issues policy
resource "aws_iam_role_policy_attachment" "attach_sdl_snyk_issues" {
  policy_arn = aws_iam_policy.policy_document_sdl_snyk_issues.arn
  role       = aws_iam_role.sdl_snyk_issues_role.name
}

########################################################################
# sdl-split-stream policy document
########################################################################

data "aws_iam_policy_document" "sdl_split_stream" {
  version = "2012-10-17"

  statement {
    sid     = "CloudWatchLogging"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
  statement {
    sid     = "ReadWriteResults"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [local.sdl_bucket_prefix_with_wildcard]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.sdl_bucket_prefix]
  }
  statement {
    sid       = "ReadWriteConfigResults"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [local.sdl_config_path_wildcard]
  }
}

# resource for sdl-split-stream policy
resource "aws_iam_policy" "policy_document_sdl_split_stream" {
  description = "lambda Policy: sdl-split-stream lambda function"
  name        = local.sdl_split_stream
  policy      = data.aws_iam_policy_document.sdl_split_stream.json

  depends_on  = [
    local.sdl_bucket_prefix_with_wildcard
  ]
}

# resource role for sdl-split-stream
resource "aws_iam_role"  "sdl_split_stream_role"{
  description           = "lambda role for sdl-split-stream policy"
  name                  = local.sdl_split_stream
  assume_role_policy    = data.aws_iam_policy_document.sdl_assume_role.json
}

# attach sdl-split-stream policy
resource "aws_iam_role_policy_attachment" "attach_sdl_split_stream" {
  policy_arn = aws_iam_policy.policy_document_sdl_split_stream.arn
  role       = aws_iam_role.sdl_split_stream_role.name
}