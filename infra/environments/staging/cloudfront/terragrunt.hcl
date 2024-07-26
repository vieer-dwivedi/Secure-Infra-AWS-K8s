terraform {
  source = "../../../infra-modules/cloudfront"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  config_path = "${get_terragrunt_dir()}/../config.yml"
  config = yamldecode(file(local.config_path))
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
  s3_bucket_name = ""  
  }
}

inputs = {
  bucket_name = dependency.s3.outputs.s3_bucket_name
}
