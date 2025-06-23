variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0/16" # Replace with your desired CIDR block 
}

variable "instance_tenancy" {
  description = "The tenancy of the instances launched in the VPC"
  type        = string
  default     = "default" # Replace with your desired instance tenancy 
}

variable "project" {
  description = "The name of the project"
  type        = string# Replace with your desired project name
}

variable "environment" {
  description = "The environment for the VPC"
  type        = string # Replace with your desired environment name
}

variable "public_subnet_cidrs" {
  description = "The CIDR block for the public subnet"
  type        = list
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  
}

variable "vpc_tags" {
    type       = map(string)
    default = {}
  
}

variable "public_subnet_tags" {
    type       = map(string)
    default = {}
}

variable "private_subnet_tags" {
    type       = map(string)
    default = {}
}

variable "database_subnet_tags" {
    type       = map(string)
    default = {}
}

variable "igw_tags" {
    type       = map(string)
    default = {}
}

variable "private_subnet_cidrs" {
  description = "The CIDR block for the private subnet"
  type        = list
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
  
}

variable "database_subnet_cidrs" {
  description = "The CIDR block for the database subnet"
  type        = list
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
  
}

variable "nat_gateway_tags" {
  default = {}
  type    = map(string)
}

variable "eip_tags" {
  default = {}
  type    = map(string)
}

variable "public_route_table_tags" {
  default = {}
  type    = map(string) 
  
}

variable "private_route_table_tags" {
  default = {}
  type    = map(string)     
  
}

variable "database_route_table_tags" {
  default = {}
  type    = map(string)     
  
}

variable "is_peering_required" {
  description = "Flag to indicate if VPC peering is required"
  type        = bool
  default     = false # Set to true if VPC peering is required 
}

variable "peering_connection_tags" {
  description = "Tags for the VPC peering connection"
  type        = map(string)
  default     = {}
  
}