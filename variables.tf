variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "riyazgit-bucket"
}

variable "distribution_enabled" {
  description = "Flag to enable/disable the CloudFront distribution"
  type        = bool
  default     = true
}
