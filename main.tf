provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "presentation_bucket" {
  bucket = var.bucket_name

  # Enable versioning for the bucket
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_versioning" "presentation_bucket_versioning" {
  bucket = aws_s3_bucket.presentation_bucket.id

  versioning_configuration {
    enabled = true
  }
}

# IAM Role
resource "aws_iam_role" "riyaz_role" {
  name               = var.role_name
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "IAM policy for accessing S3 bucket"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.presentation_bucket.arn}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_access_policy" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.riyaz_role.name
}

# Execute local shell command to sync the dist directory to S3
resource "null_resource" "sync_frontend_dist" {
  provisioner "local-exec" {
    command = <<EOF
      cd frontend
      aws s3 sync frontend/dist s3://${aws_s3_bucket.presentation_bucket.bucket}/dist
    EOF
  }
}
