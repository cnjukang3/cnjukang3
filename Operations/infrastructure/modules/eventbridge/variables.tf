##################################################################################
# EVENT BRIDGE VARIABLES
##################################################################################
variable "event_is_enabled" {
  description = "state of the event (enabled)"
  type        = bool
  default     = true
}

variable "event_is_disabled" {
  description = "state of the event (disabled)"
  type        = bool
  default     = false
}

variable "event_bus_name" {
  description = "EventBusName"
  type        = string
  default     = "default"
}

##################################################################################
#1   sdl-aws-accounts-trigger eventbridge rule
##################################################################################
variable "sdl_aws_accounts_trigger_eventbridge_name" {
  description = "event rule name for sdl-aws-accounts-trigger"
  type        = string
  default     = "sdl-aws-accounts-trigger-test"
}

variable "sdl_aws_accounts_trigger_schedule_expression" {
  description = "schedule expression for sdl-aws-accounts-trigger"
  type        = string
  default     = "cron(0 5 * * ? *)"
}

variable "sdl_aws_dc_acct_target_by_rule" {
  description = "The intended target this rule will trigger is lambda: sdl-aws-dc-acct"
  type        = string
  default     = "arn:aws:lambda:us-east-1:*:function:sdl-aws-dc-acct"
}

##################################################################################
#2   sdl-cisa-daily-known-exploited-vulnerabilities
##################################################################################
variable "sdl_cisa_daily_known_exp_vuln_eventbridge_name" {
  description = "event rule name for sdl-cisa-daily-known-exploited-vulnerabilities"
  type        = string
  default     = "sdl-cisa-daily-known-exploited-vulnerabilities-test"
}

variable "sdl_cisa_known_exp_vuln_schedule_expression" {
  description = "schedule expression for sdl-cisa-daily-known-exploited-vulnerabilities"
  type        = string
  default     = "cron(0 10 * * ? *)"
}

variable "sdl_cisa_known_exp_vuln_target_by_rule" {
  description = "The intended target this rule will trigger is lambda: sdl-cisa-daily-known-exploited-vulnerabilities"
  type        = string
  default     = "arn:aws:lambda:us-east-1:*:function:sdl-cisa-daily-known-exploited-vulnerabilities"
}

##################################################################################
#3   sdl-daily-ingest-govcloud eventbridge rule
##################################################################################
variable "sdl_daily_ingest_govcloud_eventbridge_name" {
  description = "event rule name for sdl-daily-ingest-govcloud"
  type        = string
  default     = "sdl-daily-ingest-govcloud-test"
}

variable "sdl_daily_ingest_govcloud_schedule_expression" {
  description = "schedule expression for sdl-daily-ingest-govcloud"
  type        = string
  default     = "cron(0 9 * * ? *)"
}

variable "sdl_daily_ingest_govcloud_target_by_rule" {
  description = "The intended target this rule will trigger is lambda: sdl-daily-ingest-govcloud"
  type        = string
  default     = "arn:aws:lambda:us-east-1:*:function:sdl-cdm-govcloud"
}

##################################################################################
#4   sdl-daily-ingest-vuln-csm-config_data eventbridge rule
##################################################################################
variable "sdl_daily_ingest_vcc_eventbridge_name" {
  description = "event rule name for sdl-daily-ingest-vuln-csm-config-data"
  type        = string
  default     = "sdl-daily-ingest-vuln-csm-config-data-test"
}

variable "sdl_daily_ingest_vcc_schedule_expression" {
  description = "schedule expression for sdl-daily-ingest-vuln-csm-config-data"
  type        = string
  default     = "cron(0 8 * * ? *)"
}

variable "sdl_daily_ingest_vcc_target_by_rule" {
  description = "The intended target this rule will trigger is lambda: sdl-daily-ingest-vuln-csm-config-data"
  type        = string
  default     = "arn:aws:lambda:us-east-1:*:function:sdl-daily-ingest-vuln-csm-config-data"
}

##################################################################################
#5   sdl-init-gather-resources eventbridge rule
##################################################################################
variable "sdl_init_gather_resources_eventbridge_name" {
  description = "event rule name for sdl-daily-ingest"
  type        = string
  default     = "sdl-init-gather-resources-test"
}

variable "sdl_init_gather_resources_schedule_expression" {
  description = "schedule expression for sdl-daily-ingest"
  type        = string
  default     = "cron(0 8 * * ? *)"
}

variable "sdl_daily_ingest_target_by_rule" {
  description = "The intended target this rule will trigger is lambda: sdl-daily-ingest"
  type        = string
  default     = "arn:aws:lambda:us-east-1:*:function:sdl-daily-ingest"
}
##################################################################################
#6   sdl-monitoring-notifications eventbridge rule
##################################################################################
variable "sdl_monitoring_notifications_eventbridge_name" {
  description = "event rule name for sdl-monitoring-notifications"
  type        = string
  default     = "sdl-monitoring-notifications-test"
}

variable "sdl_monitoring_notifications_event_pattern" {
  description = "This event rule receives multiple state functions state-change"
  type        = string
  default     =  "{\"source\":[\"aws.states\"],\"detail-type\":[\"Step Functions Execution Status Change\"],\"detail\":{\"status\":[\"FAILED\",\"TIMED_OUT\",\"ABORTED\"],\"stateMachineArn\":[\"arn:aws:states:us-east-1:690322010149:stateMachine:sdl-daily-aws\",\"arn:aws:states:us-east-1:690322010149:stateMachine:sdl-cdm-govcloud-machine\",\"arn:aws:states:us-east-1:690322010149:stateMachine:sdl-daily-securitycenter\"]}}"
}

variable "sdl_monitoring_notifications_target_by_rule" {
  description = "The intended target this rule will trigger is lambda: sdl-monitoring-notifications"
  type        = string
  default     = "arn:aws:lambda:us-east-1:*:function:sdl-monitoring-notifications"
}

##################################################################################
#6   sdl-event-rule eventbridge rule
##################################################################################
variable "sdl_event_rule_eventbridge_name" {
  description = "This can be use to trigger a lambda function"
  type        = string
  default     = "sdl-event-rule-test"
}

variable "sdl_event_rule_schedule_expression" {
  description = "schedule expression for sdl-event-rule"
  type        = string
  default     = "cron(0 9 * * ? *)"
}

variable "sdl_event_rule_target_by_rule" {
  description = "This rule can be used to trigger a lambda function"
  type        = string
  default     = "arn:aws:lambda:us-east-1:*:function:sdl-aws-dc-acct"
}




















