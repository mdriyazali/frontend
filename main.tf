provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "presentation_bucket" {
  bucket = "riyaz-lf-bucket"
}

resource "aws_iam_role" "riyaz_role" {
  name = "riyaz-lf-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy for S3 access"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.riyaz_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.presentation_bucket.bucket
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": aws_s3_bucket.presentation_bucket.arn
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "presentation_bucket_versioning" {
  bucket = aws_s3_bucket.presentation_bucket.bucket

  versioning_configuration {
    enabled = true
  }
}

resource "null_resource" "sync_frontend_dist" {
  provisioner "local-exec" {
    command = <<-EOT
      cd frontend
      aws s3 sync dist s3://riyaz-lf-bucket/dist
    EOT
  }
}

output "bucket_name" {
  value = aws_s3_bucket.presentation_bucket.bucket
}

output "role_name" {
  value = aws_iam_role.riyaz_role.name
}
