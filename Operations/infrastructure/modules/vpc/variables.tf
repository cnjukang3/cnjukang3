######################################################################
# Amazon VPC VARIABLES
######################################################################
variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "sdl VPC name"
  type        = string
  default     = "sdl-production-VPC"
}

variable "us_east_1a" {
  description = "availability zone us-east-1a"
  type        = string
  default     = "us-east-1a"
}

variable "us_east_1b" {
  description = "availability zone us-east-1b"
  type        = string
  default     = "us-east-1b"
}

variable "us_east_1c" {
  description = "availability zone us-east-1c"
  type        = string
  default     = "us-east-1c"
}

variable "us_east_1a_tags" {
  description = "tags for us-east-1a"
  type        = map(string)
  default     = {
    Automated = "true"
    "use"     = "private"
    Name      = "ispg-ccic-splunk-sbx-sandbox-private-a"
    stack     = "sandbox"
  }
}

variable "ispg_ccic_splunk_sbx_sandbox_private_1a_cidr" {
  description = "Private Subnet CIDR"
  type = string
  default = "10.0.1.0/24"
}

variable "ispg_ccic_splunk_sbx_sandbox_public_1b_cidr" {
  description = "Public Subnet 2 CIDR"
  type = string
  default = "10.0.2.0/24"
}

variable "ispg_ccic_splunk_sbx_sandbox_public_1c_cidr" {
  description = "Public Subnet CIDR"
  type = string
  default = "10.0.3.0/24"
}


