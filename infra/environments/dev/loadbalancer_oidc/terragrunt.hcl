terraform {
  source = "../../../additional_modules/oidc_policy"
}
include "root"{
	path = find_in_parent_folders()
}
locals {
  config_path = "${get_terragrunt_dir()}/../config.yml"
  config = yamldecode(file(local.config_path))
}

dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    oidc_provider = ""
    oidc_provider_arn = ""
  }
}

inputs = {
  create_custom_policy = false
  create_addon = false
  cluster_name = local.config.eks.cluster_name
  attach_role = true
  role_name            = "${local.config.eks.cluster_name}-ebs-role"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"]
  oidc_arn             = dependency.eks.outputs.oidc_provider_arn
  oidc_id              = dependency.eks.outputs.oidc_provider
  tags = local.config.tags
}
