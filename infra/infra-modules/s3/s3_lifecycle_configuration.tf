resource "aws_s3_bucket_lifecycle_configuration" "s3_lc_configuration" {
  bucket = var.bucket_name

  rule {
      id = "glacier_rule"

      transition {
        days          = 30
        storage_class = "GLACIER"
      }

      noncurrent_version_transition {
        noncurrent_days = 60
        storage_class = "GLACIER"
      }

      expiration {
        days = 365
      }
      status = "Enabled"
    }
}