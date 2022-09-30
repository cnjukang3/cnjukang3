######################################################################
# Amazon s3 VARIABLES
######################################################################
variable "sdl_s3_bucket_name" {
    description = "sdl bucket name"
    type        = string
    default     = "datalake-snowflake-staging-test"
}

variable "sdl_s3_bucket_acl_value" {
  description = "the access control list for s3 bucket"
  type        = string
  default     = "private"
}

variable "sdl_s3_content" {
  description = "the folders in the sdl bucket"
  type        = set(string)
  default     = ["aws1/", "camp1/", "cdm1/", "config1/", "fisma1/", "db_lookup1/", "DW1/", "ispg-risk-pilot1/", "nucleus1/", "securitycenter1/", "snyk-qpp1/", "snyk1/"]
}

variable "sdl_s3_fisma_arn_path_with_wildcard" {
    description = "sdl fisma path"
    type        = string
    default     = "arn:aws:s3:::datalake-snowflake-staging/fisma/*"
}


































