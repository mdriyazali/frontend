provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "riyaz-khan-s3-tf-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "riyaz-khan-tf-lockfile"
  }
}

locals {
  bucket_name = "${var.s3_dist_bucket}-${terraform.workspace}"
}

resource "aws_s3_bucket" "frontend_dist" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_versioning" "frontend_dist_versioning" {
  bucket = aws_s3_bucket.frontend_dist.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_dist_encryption" {
  bucket = aws_s3_bucket.frontend_dist.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}
