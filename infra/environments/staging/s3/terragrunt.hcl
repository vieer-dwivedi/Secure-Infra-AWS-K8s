terraform {
  source = "../../../infra-modules/s3"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  config_path = "${get_terragrunt_dir()}/../config.yml"
  config = yamldecode(file(local.config_path))
}

inputs = {
  bucket_name = local.config.s3.bucket_name
  versioning_enabled = local.config.s3.versioning_enabled
}