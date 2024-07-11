data "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_policy" "allow_cloudfront_access" {
  bucket = data.aws_s3_bucket.bucket.bucket
  policy = data.aws_iam_policy_document.allow_cloudfront_access.json
}

data "aws_iam_policy_document" "allow_cloudfront_access" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${data.aws_s3_bucket.bucket.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.cloudfront_distribution_id}"
        # "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/*"
      ]
    }
    
  }
}

data "aws_caller_identity" "current" {}