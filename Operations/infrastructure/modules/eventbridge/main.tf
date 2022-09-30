###########################################################
# EVENT BRIDGE MODULE
###########################################################
locals {
  event_is_enabled           = var.event_is_enabled
  event_is_disabled          = var.event_is_disabled
  event_bus_name             = var.event_bus_name

  sdl_aws_accounts_trigger_eventbridge_name      = var.sdl_aws_accounts_trigger_eventbridge_name
  sdl_aws_accounts_trigger_schedule_expression   = var.sdl_aws_accounts_trigger_schedule_expression
  sdl_aws_dc_acct_target_by_rule                 = var.sdl_aws_dc_acct_target_by_rule

  sdl_cisa_daily_known_exp_vuln_eventbridge_name = var.sdl_cisa_daily_known_exp_vuln_eventbridge_name
  sdl_cisa_known_exp_vuln_schedule_expression    = var.sdl_cisa_known_exp_vuln_schedule_expression
  sdl_cisa_known_exp_vuln_target_by_rule         = var.sdl_cisa_known_exp_vuln_target_by_rule

  sdl_daily_ingest_govcloud_eventbridge_name     = var.sdl_daily_ingest_govcloud_eventbridge_name
  sdl_daily_ingest_govcloud_schedule_expression  = var.sdl_daily_ingest_govcloud_schedule_expression
  sdl_daily_ingest_govcloud_target_by_rule       = var.sdl_daily_ingest_govcloud_target_by_rule

  sdl_daily_ingest_vcc_eventbridge_name          = var.sdl_daily_ingest_vcc_eventbridge_name
  sdl_daily_ingest_vcc_schedule_expression       = var.sdl_daily_ingest_vcc_schedule_expression
  sdl_daily_ingest_vcc_target_by_rule            = var.sdl_daily_ingest_vcc_target_by_rule

  sdl_init_gather_resources_eventbridge_name     = var.sdl_init_gather_resources_eventbridge_name
  sdl_init_gather_resources_schedule_expression  = var.sdl_init_gather_resources_schedule_expression
  sdl_daily_ingest_target_by_rule                = var.sdl_daily_ingest_target_by_rule

  sdl_monitoring_notifications_eventbridge_name  = var.sdl_monitoring_notifications_eventbridge_name
  sdl_monitoring_notifications_event_pattern     = var.sdl_monitoring_notifications_event_pattern
  sdl_monitoring_notifications_target_by_rule    = var.sdl_monitoring_notifications_target_by_rule

  sdl_event_rule_eventbridge_name                = var.sdl_event_rule_eventbridge_name
  sdl_event_rule_schedule_expression             = var.sdl_event_rule_schedule_expression
  sdl_event_rule_target_by_rule                  = var.sdl_event_rule_target_by_rule
}

##############################################################################
#1    sdl-aws-accounts-trigger eventbridge rule
##############################################################################
resource "aws_cloudwatch_event_rule" "sdl_aws_accounts_trigger" {
  description         = "This triggers the sdl-aws-dc-acct lambda on a schedule to extract account numbers"
  name                = local.sdl_aws_accounts_trigger_eventbridge_name
  schedule_expression = local.sdl_aws_accounts_trigger_schedule_expression
  is_enabled          = local.event_is_disabled
  event_bus_name      = local.event_bus_name
}

resource "aws_cloudwatch_event_target" "sdl_aws_accounts_trigger_target" {
  arn  = local.sdl_aws_dc_acct_target_by_rule
  rule = aws_cloudwatch_event_rule.sdl_aws_accounts_trigger.name
}

##############################################################################
#2    sdl-cisa-daily-known-exploited-vulnerabilities eventbridge rule
##############################################################################
resource "aws_cloudwatch_event_rule" "sdl_cisa_daily_known_exploited_vulnerabilities" {
  description         = "Daily pull from cisa known CVE registry"
  name                = local.sdl_cisa_daily_known_exp_vuln_eventbridge_name
  schedule_expression = local.sdl_cisa_known_exp_vuln_schedule_expression
  is_enabled          = local.event_is_disabled
  event_bus_name      = local.event_bus_name
}

resource "aws_cloudwatch_event_target" "sdl_cisa_daily_known_exploited_vulnerabilities_target" {
  arn  = local.sdl_cisa_known_exp_vuln_target_by_rule
  rule = aws_cloudwatch_event_rule.sdl_cisa_daily_known_exploited_vulnerabilities.name
}

##############################################################################
#3    sdl-daily-ingest-govcloud eventbridge rule
##############################################################################
resource "aws_cloudwatch_event_rule" "sdl_daily_ingest_govcloud" {
  description         = "This rule triggers the lambda function for for govcloud feed"
  name                = local.sdl_daily_ingest_govcloud_eventbridge_name
  schedule_expression = local.sdl_daily_ingest_govcloud_schedule_expression
  is_enabled          = local.event_is_disabled
  event_bus_name      = local.event_bus_name
}

resource "aws_cloudwatch_event_target" "sdl_daily_ingest_govcloud_target" {
  arn  = local.sdl_daily_ingest_govcloud_target_by_rule
  rule = aws_cloudwatch_event_rule.sdl_daily_ingest_govcloud.name
}

##############################################################################
#4    sdl_daily_ingest_vuln_csm_config_data eventbridge rule
##############################################################################
resource "aws_cloudwatch_event_rule" "sdl_daily_ingest_vuln_csm_config" {
  description         = "This rule triggers the lambda function that initiates the vuln, csm and config_data feeds"
  name                = local.sdl_daily_ingest_vcc_eventbridge_name
  schedule_expression = local.sdl_daily_ingest_vcc_schedule_expression
  is_enabled          = local.event_is_disabled
  event_bus_name      = local.event_bus_name
}

resource "aws_cloudwatch_event_target" "sdl_daily_ingest_vuln_csm_config_target" {
  arn  = local.sdl_daily_ingest_vcc_target_by_rule
  rule = aws_cloudwatch_event_rule.sdl_daily_ingest_vuln_csm_config.name
}

##############################################################################
#5   sdl-init-gather-resources eventbridge rule
##############################################################################
resource "aws_cloudwatch_event_rule" "sdl_init_gather_resources" {
  description         = "This rule triggers the lambda function sdl-daily-ingest"
  name                = local.sdl_init_gather_resources_eventbridge_name
  schedule_expression = local.sdl_init_gather_resources_schedule_expression
  is_enabled          = local.event_is_disabled
  event_bus_name      = local.event_bus_name
}

resource "aws_cloudwatch_event_target" "sdl_daily_ingest_target" {
  arn  = local.sdl_daily_ingest_target_by_rule
  rule = aws_cloudwatch_event_rule.sdl_init_gather_resources.name
}

##############################################################################
#6   sdl-monitoring-notifications eventbridge rule
##############################################################################
resource "aws_cloudwatch_event_rule" "sdl_monitoring_notifications" {
  description      = "This rule will be trigger when the Step Function State Change occurred for security datalake"
  name             = local.sdl_monitoring_notifications_eventbridge_name
  event_pattern    = local.sdl_monitoring_notifications_event_pattern
  is_enabled       = local.event_is_disabled
  event_bus_name   = local.event_bus_name
}

resource "aws_cloudwatch_event_target" "sdl_monitoring_notifications_target" {
  arn  = local.sdl_monitoring_notifications_target_by_rule
  rule = aws_cloudwatch_event_rule.sdl_monitoring_notifications.name
}

##############################################################################
#7   sdl-event-rule eventbridge rule
##############################################################################
resource "aws_cloudwatch_event_rule" "sdl_event_rule" {
  name                  = local.sdl_event_rule_eventbridge_name
  schedule_expression   = local.sdl_event_rule_schedule_expression
  is_enabled            = local.event_is_disabled
  event_bus_name        = local.event_bus_name
}

resource "aws_cloudwatch_event_target" "sdl_event_rule_target" {
  arn  = local.sdl_event_rule_target_by_rule
  rule = aws_cloudwatch_event_rule.sdl_event_rule.name
}





