#!/usr/bin/env bash
 echo 'SDL AWS Terraform S3 Bucket Provisioning'
 terraform init -reconfigure --backend-config="sdl-s3.config"
 echo '+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+'
 echo '+                         Terraform Options                           +'
 echo '+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+'
 echo '+                        validate : plan : apply                      +'
 echo '+---------------------------------------------------------------------+'
 terraform validate
 terraform plan -out tf.plan
 #terraform apply tf.plan










