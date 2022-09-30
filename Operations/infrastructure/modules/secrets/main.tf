####################################################################################
#                                    SECRETS MANAGER                               #
####################################################################################
locals {
  # secrets manager variables
  sdl_cdm_govcloud_secret              = var.sdl_cdm_govcloud_secret
  sdl_cdm_commercial_secret            = var.sdl_cdm_commercial_secret
  sdl_cdm_securitycenter_secret        = var.sdl_cdm_securitycenter_secret
  sdl_cdm_govcloud_crossaccount_secret = var.sdl_cdm_govcloud_crossaccount_secret

  sdl_govcloud_secret_string                = var.sdl_govcloud_secret_string
  sdl_commercial_secret_string              = var.sdl_commercial_secret_string
  sdl_securitycenter_secret_string          = var.sdl_securitycenter_secret_string
  sdl_govcloud_crossaccount_secret_string   = var.sdl_govcloud_crossaccount_secret_string
}
####################################################################################
#  secret manager for govcloud                                                     #
####################################################################################
resource "aws_secretsmanager_secret" "sdl_prod_cdm_govcloud_secret" {
  name = local.sdl_cdm_govcloud_secret
}

resource "aws_secretsmanager_secret_version" "govcloud_secret_version" {
  secret_id     = aws_secretsmanager_secret.sdl_prod_cdm_govcloud_secret.id
  secret_string = jsonencode(local.sdl_govcloud_secret_string)
 }

###################################################################################
# secret manager for aws commercial (config delegate)
###################################################################################

resource "aws_secretsmanager_secret" "sdl_cdm_commercial_secret" {
  name = local.sdl_cdm_commercial_secret
}

resource "aws_secretsmanager_secret_version" "aws_commercial_secret_version" {
  secret_id     = aws_secretsmanager_secret.sdl_cdm_commercial_secret.id
  secret_string = jsonencode(local.sdl_commercial_secret_string)
}

###################################################################################
# secret manager for aws securitycenter
###################################################################################

resource "aws_secretsmanager_secret" "sdl_cdm_securitycenter_secret" {
  name = local.sdl_cdm_securitycenter_secret
}

resource "aws_secretsmanager_secret_version" "securitycenter_secret_version" {
  secret_id     = aws_secretsmanager_secret.sdl_cdm_securitycenter_secret.id
  secret_string = jsonencode(local.sdl_securitycenter_secret_string)
}

###################################################################################
# secret manager for aws govcloud cross account
###################################################################################

resource "aws_secretsmanager_secret" "sdl_prod_cdm_govcloud_crossaccount_secret" {
  name = local.sdl_cdm_govcloud_crossaccount_secret
}

resource "aws_secretsmanager_secret_version" "govcloud_crossaccount_secret_version" {
  secret_id     = aws_secretsmanager_secret.sdl_prod_cdm_govcloud_crossaccount_secret.id
  secret_string = jsonencode(local.sdl_govcloud_crossaccount_secret_string)
}