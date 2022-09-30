##################################################################################
#      S3 BUCKET MODULES
##################################################################################

#########################################################################
# variables stored in variables.tf file
#########################################################################
locals {
  sdl_s3_bucket_name          = var.sdl_s3_bucket_name
  sdl_s3_bucket_acl_value     = var.sdl_s3_bucket_acl_value
}

#########################################################################
#  create sdl s3 bucket with default encryption, lifecycle policies
#########################################################################
resource "aws_s3_bucket" "sdl_s3_bucket" {
  bucket = local.sdl_s3_bucket_name
  acl    = local.sdl_s3_bucket_acl_value

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

    lifecycle_rule {
    id      = "fisma_aws_accounts_lifecycle_7_days"
    prefix  = "camp/aws-accounts/*"
    enabled = true
    expiration {
      days = 7
    }
#    transition {
#      days = 0
#      storage_class = "INTELLIGENT_TIERING"
#    }

    abort_incomplete_multipart_upload_days = 1
    noncurrent_version_expiration {
      days = 1
    }

  }

  lifecycle_rule {
    id      = "cdm_lifecycle_90_days"
    prefix  = "cdm/*"
    enabled = true
    expiration {
      days = 90
    }
#    transition {
#      days = 30
#      storage_class = "STANDARD_IA"
#    }

    abort_incomplete_multipart_upload_days = 90
    noncurrent_version_expiration {
      days = 90
    }

  }
  lifecycle {
    prevent_destroy = false
  }

}

#########################################################################
#  create s3 objects (folders path)
#########################################################################
resource "aws_s3_bucket_object" "sdl_s3_objects" {
  for_each = var.sdl_s3_content
  bucket   = aws_s3_bucket.sdl_s3_bucket.bucket
  key      = each.key
}

#########################################################################
#  s3 bucket policy
#########################################################################
resource "aws_s3_bucket_policy" "sdl_bucket_policy" {
  bucket = aws_s3_bucket.sdl_s3_bucket.id
  policy = data.aws_iam_policy_document.sdl_s3_policy.json
}

#########################################################################
#  policy document for sdl s3 bucket
#########################################################################
data "aws_iam_policy_document" "sdl_s3_policy" {
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"

   principals {
     identifiers = ["*"]
     type        = "AWS"
   }
    actions = [
      "s3:*"
    ]
    resources = [
       aws_s3_bucket.sdl_s3_bucket.arn,
      "${aws_s3_bucket.sdl_s3_bucket.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [
        "false"
      ]
    }
  }
}

#########################################################################
#  Event notifications for sdl s3 bucket
#########################################################################
resource "aws_s3_bucket_notification" "sdl_SQS_snowflake_triggers" {
  bucket = aws_s3_bucket.sdl_s3_bucket.id

#  queue {
#    id            = "SnowflakeNucleusAssetsPipeTrigger-test"
#    queue_arn     = "arn:aws:sqs:us-east-1:431216047616:sf-snowpipe-AIDAWIZT2WYAEZPSHLIZC-gB4wVqwlMsAetBNp8nWg_w"
#    events        = ["s3:ObjectCreated:*"]
#    filter_prefix = "nucleus/"
#    filter_suffix = ".json"
#  }

}


#  policy = <<EOF
#  {
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Sid": "AllowSSLRequestsOnly",
#            "Effect": "Deny",
#            "Principal": "*",
#            "Action": "s3:*",
#            "Resource": [
#                "arn:aws:s3:::securitydatalake-staging-daily1",
#                "arn:aws:s3:::securitydatalake-staging-daily1/*"
#            ],
#            "Condition": {
#                "Bool": {
#                    "aws:SecureTransport": "false"
#                }
#            }
#        }
#    ]
#}
#EOF
#}


































