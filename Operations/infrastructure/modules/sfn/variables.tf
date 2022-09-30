##################################################################################
#   STEP FUNCTIONS
##################################################################################

variable "sdl_daily_ingest_vuln_csm_config_sfn" {
    description = "name for sdl-daily-ingest-vuln-csm-config step function"
    type        = string
    default     = "sdl-daily-ingest-vuln-csm-config-test"
}

variable "sdl_daily_aws_vcc_sfn" {
    description = "name for sdl-daily-aws-vcc step function"
    type        = string
    default     = "sdl-daily-aws-vcc-test"
}

variable "sdl_daily_ingest_sfn" {
    description = "name for sdl-daily-ingest step function"
    type        = string
    default     = "sdl-daily-ingest-test"
}

variable "sdl_daily_aws_sfn" {
    description = "name for sdl-daily-aws step function"
    type        = string
    default     = "sdl-daily-aws-test"
}

variable "sdl_daily_securitycenter_sfn" {
    description = "name for sdl-daily-securitycenter step function"
    type        = string
    default     = "sdl-daily-securitycenter-test"
}

variable "sdl_cdm_govcloud_machine_sfn" {
    description = "name for sdl-cdm-govcloud-machine step function"
    type        = string
    default     = "sdl-cdm-govcloud-machine-test"
}


variable "sdl_daily_ingest_role_arn" {
  description = "role arn for sdl-daily-ingest lambda/step function"
  type        = string
  default     = "arn:aws:iam::*:role/sdl-daily-ingest-test"
}

variable "sdl_daily_aws_role_arn" {
  description = "role arn for sdl-daily-aws lambda/step function"
  type        = string
  default     = "arn:aws:iam::*:role/sdl-daily-aws-test"
}

variable "sdl_daily_securitycenter_role_arn" {
  description = "role arn for sdl-daily-securitycenter lambda/step function"
  type        = string
  default     = "arn:aws:iam::*:role/sdl-daily-securitycenter-test"
}

variable "sdl_cdm_govcloud_role_arn" {
  description = "role arn for sdl-cdm-govcloud lambda/step function"
  type        = string
  default     = "arn:aws:iam::*:role/sdl-cdm-govcloud-test"
}

variable "sdl_daily_ingest_vuln_csm_config_role_arn" {
  description = "role arn for sdl-daily-ingest-vuln-csm-config step function"
  type        = string
  default     = "arn:aws:iam::*:role/sdl-daily-ingest-vuln-csm-config-test"
}

variable "sdl_daily_aws_vcc_role_arn" {
  description = "role arn for sdl-daily-aws-vcc lambda/step function"
  type        = string
  default     = "arn:aws:iam::*:role/sdl-daily-aws-vcc-test"
}
