terraform {
  source = "../../../infra-modules/s3_bucket_policy"
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
//   skip_outputs = true
}

dependency "cloudfront" {
    config_path = "../cloudfront"
}

inputs = {
    bucket_name = dependency.s3.outputs.s3_bucket_name
    cloudfront_distribution_id = dependency.cloudfront.outputs.cloudfront_distribution_id

}