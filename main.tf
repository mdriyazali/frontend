provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "presentation_bucket" {
  bucket = "riyaz-dist-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "presentation_bucket_versioning" {
  bucket = aws_s3_bucket.presentation_bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "riyaz_role" {
  name               = "riyaz-dist-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "null_resource" "sync_frontend_dist" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "cd frontend && aws s3 sync dist s3://riyaz-dist-bucket/dist --region us-east-1"
  }
}
