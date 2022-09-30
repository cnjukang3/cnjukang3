##########################################################################
#   SDL STEP FUNCTIONS
##########################################################################

module "iam_role" {
  source = "../../modules/policies/"

}

locals {
  sdl_daily_ingest_role                 = var.sdl_daily_ingest_role_arn #module.iam_role.sdl_daily_ingest_role
  sdl_daily_aws_role                    = var.sdl_daily_aws_role_arn #module.iam_role.sdl_daily_aws_role
  sdl_daily_securitycenter_role         = var.sdl_daily_securitycenter_role_arn #module.iam_role.sdl_daily_securitycenter_role
  sdl_cdm_govcloud_role                 = var.sdl_cdm_govcloud_role_arn #module.iam_role.sdl_cdm_govcloud_role
  sdl_daily_ingest_vuln_csm_config_role = var.sdl_daily_ingest_vuln_csm_config_role_arn #module.iam_role.sdl_daily_ingest_vuln_csm_config_role
  sdl_daily_aws_vcc_role                = var.sdl_daily_aws_vcc_role_arn #module.iam_role.sdl_daily_aws_vcc_role


  sdl_daily_ingest_sfn                  = var.sdl_daily_ingest_sfn
  sdl_daily_aws_sfn                     = var.sdl_daily_aws_sfn
  sdl_daily_securitycenter_sfn          = var.sdl_daily_securitycenter_sfn
  sdl_cdm_govcloud_machine_sfn          = var.sdl_cdm_govcloud_machine_sfn
  sdl_daily_ingest_vuln_csm_config_sfn  = var.sdl_daily_ingest_vuln_csm_config_sfn
  sdl_daily_aws_vcc_sfn                 = var.sdl_daily_aws_vcc_sfn
}

##########################################################################
#   sdl-daily-ingest step function
##########################################################################
data "template_file" "sdl_daily_ingest_sfn" {
  template = file("${path.module}/stepfunctions/sdl-daily-ingest-sfn.json")
}

resource "aws_sfn_state_machine" "sdl_daily_ingest_sfn" {
  definition = data.template_file.sdl_daily_ingest_sfn.rendered
  name       = local.sdl_daily_ingest_sfn
  role_arn   = local.sdl_daily_ingest_role #aws_iam_role.sdl_daily_ingest_role.arn

}

##########################################################################
#   sdl-daily-aws step function
##########################################################################
data "template_file" "sdl_daily_aws_sfn" {
  template = file("${path.module}/stepfunctions/sdl-daily-aws-sfn.json")
}

resource "aws_sfn_state_machine" "sdl_daily_aws_sfn" {
  definition = data.template_file.sdl_daily_aws_sfn.rendered
  name       = local.sdl_daily_aws_sfn
  role_arn   = local.sdl_daily_aws_role

}

##########################################################################
#   sdl-daily-securitycenter step function
##########################################################################
data "template_file" "sdl_daily_securitycenter_sfn" {
  template = file("${path.module}/stepfunctions/sdl-daily-securitycenter-sfn.json")
}

resource "aws_sfn_state_machine" "sdl_daily_securitycenter_sfn" {
  definition = data.template_file.sdl_daily_securitycenter_sfn.rendered
  name       = local.sdl_daily_securitycenter_sfn
  role_arn   = local.sdl_daily_securitycenter_role

}

##########################################################################
#   sdl-cdm-govcloud-machine step function
##########################################################################
data "template_file" "sdl_cdm_govcloud_machine_sfn" {
  template = file("${path.module}/stepfunctions/sdl-cdm-govcloud-machine-sfn.json")
}

resource "aws_sfn_state_machine" "sdl_cdm-govcloud_machine_sfn" {
  definition = data.template_file.sdl_cdm_govcloud_machine_sfn.rendered
  name       = local.sdl_cdm_govcloud_machine_sfn
  role_arn   = local.sdl_cdm_govcloud_role
}

##########################################################################
#   sdl-daily-ingest-vuln-csm-config step function
##########################################################################
data "template_file" "sdl_daily_ingest_vuln_csm_config_sfn" {
  template = file("${path.module}/stepfunctions/sdl-daily-ingest-vuln-csm-config-sfn.json")
}

resource "aws_sfn_state_machine" "sdl_daily_ingest_vuln_csm_config_sfn" {
  definition = data.template_file.sdl_daily_ingest_vuln_csm_config_sfn.rendered
  name       = local.sdl_daily_ingest_vuln_csm_config_sfn
  role_arn   = local.sdl_daily_ingest_vuln_csm_config_role
}

##########################################################################
#   sdl-daily-aws-vcc step function
##########################################################################
data "template_file" "sdl_daily_aws_vcc_sfn" {
  template = file("${path.module}/stepfunctions/sdl-daily-aws-vcc-sfn.json")
}

resource "aws_sfn_state_machine" "sdl_daily_aws_vcc_sfn" {
  definition = data.template_file.sdl_daily_aws_vcc_sfn.rendered
  name       = local.sdl_daily_aws_vcc_sfn
  role_arn   = local.sdl_daily_aws_vcc_role

}