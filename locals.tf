locals {
    common_tags = {
        Project  = var.project
        Environment = var.environment
        Terraform = "true"
    }
    azs_name = data.aws_availability_zones.available.names
}
