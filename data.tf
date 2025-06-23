data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
}


data "aws_route_table" "default" { 
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

output "azs_info" {
  description = "List of available availability zones in the region"
  value       = data.aws_availability_zones.available
}