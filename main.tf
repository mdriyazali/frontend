resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.bucket_name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_object" "frontend_files" {
  bucket = aws_s3_bucket.frontend_bucket.id
  key    = "*"
  source = "${var.frontend_build_dir}/*"

  content_type = filebase64sha256("${var.frontend_build_dir}/*")

  depends_on = [aws_s3_bucket.frontend_bucket]
}
