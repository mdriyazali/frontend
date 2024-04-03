provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "presentation_bucket" {
  bucket = "riyaz-tf-frontend-bucket"
}

resource "aws_s3_bucket_versioning" "presentation_bucket_versioning" {
  bucket = aws_s3_bucket.presentation_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "frontend_role" {
  name = "riyaz-frontend-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "s3_access_attachment" {
  name       = "s3_access_attachment"
  roles      = [aws_iam_role.frontend_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "null_resource" "sync_frontend_dist" {
  provisioner "local-exec" {
    command = <<EOF
      cd frontend
      aws s3 sync dist s3://${aws_s3_bucket.presentation_bucket.bucket}/dist --region=us-east-1
    EOF
  }
}
