variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "riyazkhannn-bucket"
}

variable "role_name" {
  description = "IAM role name"
  type        = string
  default     = "riyazkhannn-role"
}

variable "distribution_enabled" {
  description = "Flag to enable/disable the CloudFront distribution"
  type        = bool
  default     = true
}
