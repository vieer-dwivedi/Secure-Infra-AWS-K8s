provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

resource "helm_release" "this" {
  name             = var.deployment_name
  repository       = var.repository_link
  chart            = var.chart_name
  values           = var.values
  namespace        = var.namespace
  create_namespace = var.create_namespace
  
  dynamic "set" {
    for_each = var.parameters
    iterator = itt
    content {
      name  = itt.value.key
      value = itt.value.value
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

variable "parameters" {
  type = list(object({
    key   = string
    value = string
  }))
  default = [ {
    key = "value"
    value = "value"
  } ]
}
variable "cluster_name" {
  type = string
}
variable "deployment_name" {
  type = string
}
variable "repository_link" {
  type = string
}
variable "chart_name" {
  type = string
}
variable "values" {
  type = list(string)
}
variable "namespace" {
  type = string
  default = "kube-system"
}
variable "create_namespace" {
  type = bool
  default = false
}