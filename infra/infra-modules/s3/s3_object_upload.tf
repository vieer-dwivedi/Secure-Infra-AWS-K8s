resource "aws_s3_object" "upload_object" {
    depends_on = [aws_s3_bucket.s3_bucket]
    for_each = fileset("dist/base-project/", "*")
    bucket = aws_s3_bucket.s3_bucket.id
    key    = each.value
    source = "dist/base-project/${each.value}"
    etag = filemd5("dist/base-project/${each.value}")
}