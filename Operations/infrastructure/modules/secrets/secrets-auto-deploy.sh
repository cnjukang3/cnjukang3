#!/usr/bin/env bash
 echo 'SDL AWS Terraform Secrets Manager Provisioning'
 terraform init -reconfigure --backend-config="sdl-secrets.config"
 echo '+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+'
 echo '+                         Terraform Options                           +'
 echo '+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+'
 echo '+                        validate : plan : apply                      +'
 echo '+---------------------------------------------------------------------+'
 terraform validate
 terraform plan -out tf.plan
 #terraform apply tf.plan










