variable "aws_region" {
  type        = string
  description = "AWS region to use"
  default     = "eu-west-1"
  validation {
    condition     = can(regex("^eu-", var.aws_region))
    error_message = "The AWS region must be in the EU"
  }
}
