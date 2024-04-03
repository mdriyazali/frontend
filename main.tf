provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "your-bucket-name"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "frontend_files" {
  for_each = fileset(".", "**/*")

  bucket = aws_s3_bucket.frontend_bucket.id
  key    = each.key
  source = each.key

  etag = filemd5(each.key)
}
