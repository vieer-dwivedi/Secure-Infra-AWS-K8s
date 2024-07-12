variable "oidc_arn" {
  type = string
}
variable "oidc_id" {
  type = string
}
variable "policy" {
  type    = string
  default = ""
}
variable "policy_name" {
  type    = string
  default = "bib"
}

variable "create_custom_policy" {
  type    = bool
  default = false
}
variable "tags" {
  type = map(string)
  default = {
    "name" = "value"
  }
}
variable "managed_policy_arns" {
  type    = list(string)
  default = []
}
variable "role_name" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "addon_name" {
  type    = string
  default = "val"
}
variable "attach_role" {
  type    = bool
  default = false
}
variable "create_addon" {
  type    = bool
  default = true
}