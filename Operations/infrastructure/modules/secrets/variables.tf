######################################################################
# SECRET MANAGER VARIABLES
######################################################################
variable "sdl_govcloud_secret_string" {
    description = "govcloud secret string"
    type        = map(string)
    default     = {
        region: "us-gov-west-1"
        aggregator: "cloud-config-aggregator"
        secret_access_key: "KSWuIRb3+Uk1eI+6tERTYUIOOPOPP"
        access_key_id: "AKIDFGHJKKLLLLJHYYYUH"
    }
}

variable "sdl_commercial_secret_string" {
    description = "commercial secret string"
    type        = map(string)
    default     = {
        region: "us-west-2"
        aggregator: "cloud-delegate-config-org-aggregator"
        external_id: "D4X2sqXmA2amc7nPWxXre9ABcqrKcPghjkkkllyuiop"
        role: "arn:aws:iam::*:role/aws-config"
    }
}

variable "sdl_securitycenter_secret_string" {
    description = "securitycenter secret string"
    type        = map(string)
    default     = {
        host: "10.255.255.110"
        username: "tenable-sdl-service-account"
        password: "Uhuouyt788"
    }
}

variable "sdl_govcloud_crossaccount_secret_string" {
    description = "govcloud-crossaccount secret string"
    type        = map(string)
    default     = {
        partition: "aws-us-gov"
        external_id: "zNz62kmm67jGg56778899000"
        role: "cloud-security-compliance-scanning"
    }
}

variable "sdl_cdm_govcloud_secret" {
    description = "govcloud secret manager"
    type        = string
    default     = "sdl/prod/cdm/govcloud-test"
}

variable "sdl_cdm_commercial_secret" {
    description = "commercial (config delegate) secret manager"
    type        = string
    default     = "sdl/prod/cdm/commercial-test"
}

variable "sdl_cdm_securitycenter_secret" {
    description = "securitycenter secret manager"
    type        = string
    default     = "sdl/prod/cdm/securitycenter-test"
}

variable "sdl_cdm_govcloud_crossaccount_secret" {
    description = "govcloud cross account secret manager"
    type        = string
    default     = "sdl/prod/cdm/govcloud/crossaccount-test"
}