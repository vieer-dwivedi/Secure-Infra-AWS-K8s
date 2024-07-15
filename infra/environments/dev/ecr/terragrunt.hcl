terraform {
  source = "tfr:///terraform-aws-modules/ecr/aws?version=2.2.1"
}
# include "root"{
# 	path = find_in_parent_folders()
# }
locals {
  config = yamldecode(file("${find_in_parent_folders("config.yaml")}"))
}
inputs = { 
  repository_name = local.config.ecr.repository_name
  tags = local.config.ecr.tags
  repository_lifecycle_policy = local.config.ecr.repository_lifecycle_policy
}
