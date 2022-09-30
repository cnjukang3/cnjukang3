#!/usr/bin/env bash
 echo 'SDL AWS Terraform Roles/Policies Provisioning'
 terraform init -reconfigure --backend-config="sdl-roles-policies.config"
 echo '+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+'
 echo '+                         Terraform Options                           +'
 echo '+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+'
 echo '+                        validate : plan : apply                      +'
 echo '+---------------------------------------------------------------------+'
 terraform validate
 terraform plan -out tf.plan
 #terraform apply tf.plan










