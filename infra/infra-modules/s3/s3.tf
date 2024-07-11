resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  tags = {
    Name = var.bucket_name
  }  
}
resource "aws_s3_bucket_logging" "s3_logging" {
  bucket = var.bucket_name
  target_bucket = var.bucket_name
  target_prefix = "s3-logs/"
}

resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = var.bucket_name
  versioning_configuration {
    status = "Enabled"
  }
}