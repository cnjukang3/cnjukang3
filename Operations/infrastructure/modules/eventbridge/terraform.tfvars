###################################################################
#  EVENT BRIDGE VARIABLES
###################################################################
event_bus_name           = "default"
event_is_enabled         = true
event_is_disabled        = false

sdl_aws_accounts_trigger_eventbridge_name      = "sdl-aws-accounts-trigger-test"
sdl_aws_accounts_trigger_schedule_expression   = "cron(0 5 * * ? *)"
sdl_aws_dc_acct_target_by_rule                 = "arn:aws:lambda:us-east-1:690322010149:function:sdl-aws-dc-acct"

sdl_cisa_daily_known_exp_vuln_eventbridge_name = "sdl-cisa-daily-known-exploited-vulnerabilities-test"
sdl_cisa_known_exp_vuln_schedule_expression    = "cron(0 10 * * ? *)"
sdl_cisa_known_exp_vuln_target_by_rule         = "arn:aws:lambda:us-east-1:690322010149:function:sdl-cisa-daily-known-exploited-vulnerabilities"


sdl_daily_ingest_govcloud_eventbridge_name     = "sdl-daily-ingest-govcloud-test"
sdl_daily_ingest_govcloud_schedule_expression  = "cron(0 9 * * ? *)"
sdl_daily_ingest_govcloud_target_by_rule       = "arn:aws:lambda:us-east-1:690322010149:function:sdl-cdm-govcloud"

sdl_daily_ingest_vcc_eventbridge_name          = "sdl-daily-ingest-vuln-csm-config-data-test"
sdl_daily_ingest_vcc_schedule_expression       = "cron(0 8 * * ? *)"
sdl_daily_ingest_vcc_target_by_rule            = "arn:aws:lambda:us-east-1:690322010149:function:sdl-daily-ingest-vuln-csm-config-data"

sdl_init_gather_resources_eventbridge_name     = "sdl-init-gather-resources-test"
sdl_init_gather_resources_schedule_expression  = "cron(0 8 * * ? *)"
sdl_daily_ingest_target_by_rule                = "arn:aws:lambda:us-east-1:690322010149:function:sdl-daily-ingest"

sdl_monitoring_notifications_eventbridge_name  = "sdl-monitoring-notifications-test"
sdl_monitoring_notifications_event_pattern     =  "{\"source\":[\"aws.states\"],\"detail-type\":[\"Step Functions Execution Status Change\"],\"detail\":{\"status\":[\"FAILED\",\"TIMED_OUT\",\"ABORTED\"],\"stateMachineArn\":[\"arn:aws:states:us-east-1:690322010149:stateMachine:sdl-daily-aws\",\"arn:aws:states:us-east-1:690322010149:stateMachine:sdl-cdm-govcloud-machine\",\"arn:aws:states:us-east-1:690322010149:stateMachine:sdl-daily-securitycenter\"]}}"
sdl_monitoring_notifications_target_by_rule    = "arn:aws:lambda:us-east-1:690322010149:function:sdl-monitoring-notifications"

sdl_event_rule_eventbridge_name                = "sdl-event-rule-test"
sdl_event_rule_schedule_expression             = "cron(0 8 * * ? *)"
sdl_event_rule_target_by_rule                  = "arn:aws:lambda:us-east-1:690322010149:function:sdl-aws-dc-acct"

