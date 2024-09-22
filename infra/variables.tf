variable "region" {
  description = "AWS region"
  default     = "sa-east-1"
}

variable "vpc_id" {
  description = "ID of the VPC"
  default     = "vpc-0230ad20389106f29"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["subnet-039d5bb4e357b5d8e", "subnet-03493ba700fceaff4"]
}