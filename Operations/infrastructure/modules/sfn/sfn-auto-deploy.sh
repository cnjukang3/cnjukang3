#!/usr/bin/env bash
 echo 'SDL AWS Terraform Step Function Provisioning'
 terraform init -reconfigure --backend-config="sdl-sfn.config"
 echo '+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+'
 echo '+                         Terraform Options                           +'
 echo '+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+'
 echo '+                        validate : plan : apply                      +'
 echo '+---------------------------------------------------------------------+'
 terraform validate
 terraform plan -out tf.plan
 #terraform apply tf.plan










