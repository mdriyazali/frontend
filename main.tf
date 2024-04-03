provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "presentation_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "presentation_bucket_versioning" {
  bucket = aws_s3_bucket.presentation_bucket.id
  enabled = true
}

resource "aws_cloudfront_distribution" "presentation_distribution" {
  origin {
    domain_name = aws_s3_bucket.presentation_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.presentation_bucket.id}"
  }

  enabled             = var.distribution_enabled
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-${aws_s3_bucket.presentation_bucket.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# IAM Role
resource "aws_iam_role" "riyaz_role" {
  name               = "riyaz-role"
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
