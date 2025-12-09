variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "allowed_ips" {
  description = "Your IP address for secure access"
  type        = list(string)
}