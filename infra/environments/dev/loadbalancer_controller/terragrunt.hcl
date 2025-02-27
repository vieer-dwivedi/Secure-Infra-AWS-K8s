terraform {
  source = "../../../additional_modules/helm"
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
  }
}
dependency "loadbalancer_oidc" {
  config_path = "../loadbalancer_oidc"
  mock_outputs = {
    role_arn = "arn"
  }
}
inputs = {
  cluster_name = local.config.eks.cluster_name
  deployment_name = local.config.loadbalancer_controler.deployment_name
  repository_link = local.config.loadbalancer_controler.repository_link
  chart_name = local.config.loadbalancer_controler.chart_name
  values = ["${file("${local.config.loadbalancer_controler.config_file}")}"]
  parameters = concat(
    local.config.loadbalancer_controler.parameters,
    [
      {
        key = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value =  dependency.loadbalancer_oidc.outputs.role_arn
      }
    ]
  )
}