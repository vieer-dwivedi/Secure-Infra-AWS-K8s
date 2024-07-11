resource "aws_s3_bucket_ownership_controls" "s3_ownership_controls" {
  bucket = var.bucket_name
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [ aws_s3_bucket.s3_bucket ]
}

resource "aws_s3_bucket_acl" "s3_acl" {
  depends_on = [aws_s3_bucket.s3_bucket, aws_s3_bucket_ownership_controls.s3_ownership_controls]
  bucket = var.bucket_name
  acl    = "private"
}