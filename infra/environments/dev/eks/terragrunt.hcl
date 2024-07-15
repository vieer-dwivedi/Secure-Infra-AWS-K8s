terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=20.17.2"
}
include "root"{
	path = find_in_parent_folders()
}

locals {
    config_path = "${get_terragrunt_dir()}/../config.yml"
    config = yamldecode(file(local.config_path))
    kms_users = [for users_or_role in local.config.eks.kms_key_owners : "arn:aws:iam::${get_aws_account_id()}:${users_or_role}"]
}

dependency "network" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = ""
    private_subnets = ["subnet-071366122f4ac0e2c"]
    public_subnets = ["subnet-071366122f4ac0e2c"]
  }
}
inputs = { 
  // cluster_name    = "${get_env("RESOURCE_PREFIX", "")}-${local.config.eks.cluster_name}"
  cluster_name    = local.config.eks.cluster_name
  cluster_version = local.config.eks.cluster_version
  create_cloudwatch_log_group = local.config.eks.create_cloudwatch_log_group
  cluster_endpoint_public_access  = local.config.eks.cluster_endpoint_public_access
  cluster_addons = local.config.eks.cluster_addons
  vpc_id                   = dependency.network.outputs.vpc_id
  subnet_ids               = local.config.eks.deploy_worker_in_private_subnet ? dependency.network.outputs.private_subnets : dependency.network.outputs.public_subnets
  control_plane_subnet_ids = local.config.eks.deploy_cluster_in_private_subnet ? dependency.network.outputs.private_subnets : dependency.network.outputs.public_subnets
  create_iam_role = local.config.eks.create_iam_role
  include_oidc_root_ca_thumbprint = local.config.eks.include_oidc_root_ca_thumbprint
  eks_managed_node_group_defaults = local.config.eks.eks_managed_node_group_defaults
  eks_managed_node_groups = local.config.eks.eks_managed_node_groups
  kms_key_owners = local.kms_users
  tags = local.config.eks.tags
  enable_cluster_creator_admin_permissions = local.config.eks.enable_cluster_creator_admin_permissions
}
