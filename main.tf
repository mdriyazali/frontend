provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "presentation_bucket" {
  bucket = "riyajkhan-bucket"

  # Enable versioning for the bucket
  versioning {
    enabled = true
  }
}

# IAM Role
resource "aws_iam_role" "riyaz_role" {
  name               = "riyajrole-role"
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

# Attach S3 access policy to the IAM role
resource "aws_iam_policy_attachment" "attach_s3_access_policy" {
  name       = "s3-access-policy-attachment"
  roles      = [aws_iam_role.riyaz_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
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
