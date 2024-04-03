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

# Execute local shell command to sync the dist directory to S3
resource "null_resource" "sync_frontend_dist" {
  provisioner "local-exec" {
    command = <<EOF
      cd frontend
      aws s3 sync frontend/dist s3://${aws_s3_bucket.presentation_bucket.bucket}/dist --region ${var.region}
    EOF
  }
}
