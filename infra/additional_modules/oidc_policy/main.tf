locals {
  asume_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Principal": {
                "Federated": "${var.oidc_arn}"
            },
            "Condition": {
                "StringEquals": {
                    "${var.oidc_id}:aud": [
                        "sts.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF

}

resource "aws_iam_role" "this" {
  name                = var.role_name
  assume_role_policy  = local.asume_policy
  managed_policy_arns = var.create_custom_policy ? [] : var.managed_policy_arns
}
resource "aws_iam_role_policy" "this" {
  count  = var.create_custom_policy ? 1 : 0
  policy = var.policy
  name   = var.policy_name
  role   = aws_iam_role.this.arn
}

resource "aws_eks_addon" "this" {
  count                    = var.create_addon ? 1 : 0
  cluster_name             = var.cluster_name
  addon_name               = var.addon_name
  service_account_role_arn = var.attach_role ? aws_iam_role.this.arn : null

}