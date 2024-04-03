provider "aws" {
  region = "us-east-1" # Change to your desired region
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "riyaz-name" # Change to your bucket name
  acl    = "public-read"      # Adjust permissions as needed

  website {
    index_document = "index.html"
  }
}

output "bucket_domain_name" {
  value = aws_s3_bucket.frontend_bucket.website_endpoint
}
