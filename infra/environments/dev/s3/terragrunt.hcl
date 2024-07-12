terraform {
    source = "../../../infra-modules/s3"
}

include "root"{
    path = find_in_parent_folders()
}

locals {
  config = yamldecode(file("${find_in_parent_folders("config.yaml")}"))
}

// include "env"{
//     path = find_in_parent_folders("env.hcl")
//     expose = true
//     merge_strategy = "no_merge"
// }

inputs = {
    // env = include.env.locals.env
    bucket_name = "${get_env("RESOURCE_PREFIX", "")}-${local.config.s3.bucket_name}"
    // bucket_name = "v2-boilerplate-sagar-dev"
    versioning_enabled = local.config.s3.versioning_enabled
}
