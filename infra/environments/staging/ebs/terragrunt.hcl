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
  create_addon = true
  addon_name = "aws-ebs-csi-driver"
  addon_version = "v1.32.0-eksbuild.1"
  cluster_name = local.config.eks.cluster_name
  attach_role = true
  role_name            = "${local.config.eks.cluster_name}-ebs-role"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  oidc_arn             = dependency.eks.outputs.oidc_provider_arn
  oidc_id              = dependency.eks.outputs.oidc_provider
  tags = local.config.tags
}
