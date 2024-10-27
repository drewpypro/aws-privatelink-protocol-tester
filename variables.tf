variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0427090fd1714168b"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "SOURCE_SSH_NET" {
  description = "Public IP to SSH to consumer ec2"
  type        = string
}

variable "PUBLIC_KEY" {
  description = "Public SSH key"
  type        = string
}

