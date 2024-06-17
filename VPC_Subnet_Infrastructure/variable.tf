variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
}

variable "availability_zones" {
  type        = string
  description = "List of availability zones for subnets"
  default     = "us-west-1a"
}

variable "hosts_per_subnet" {
  type        = number
  description = "Number of hosts per subnet"
}

variable "public_subnet_count" {
  type        = number
  description = "The number of public subnets to create."
}

variable "private_subnet_count" {
  type        = number
  description = "The number of private subnets to create."
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways to create"
  type        = number
}