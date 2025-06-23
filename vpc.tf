# roboshop-dev
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  instance_tenancy = var.instance_tenancy
  enable_dns_hostnames = true

  tags= merge(
    local.common_tags,
    var.vpc_tags,
    {
      Name = "${var.project}-${var.environment}"
    }
  ) 
}

# IGW roboshop-dev
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # associate the internet gateway with the VPC

  tags = merge(
    local.common_tags,
    var.igw_tags,
    {
      Name = "${var.project}-${var.environment}"
    }
  ) 
}

# roboshop-dev-us-east-1a
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs) # Create multiple subnets based on the provided CIDR blocks
    vpc_id = aws_vpc.main.id

    cidr_block = var.public_subnet_cidrs[count.index] # Adjust the subnet CIDR block as needed
    availability_zone = local.azs_name[count.index] # Use the availability zones from the data source
    map_public_ip_on_launch = true # Enable public IP assignment for instances in this subnet
    tags = merge(
        local.common_tags,
        var.public_subnet_tags,
        {
        Name = "${var.project}-${var.environment}-public-${local.azs_name[count.index]}"
        }
    )
}

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs) # Create multiple subnets based on the provided CIDR blocks
    vpc_id = aws_vpc.main.id

    cidr_block = var.private_subnet_cidrs[count.index] # Adjust the subnet CIDR block as needed
    availability_zone = local.azs_name[count.index] # Use the availability zones from the data source
    tags = merge(
        local.common_tags,
        var.private_subnet_tags,
        {
        Name = "${var.project}-${var.environment}-private-${local.azs_name[count.index]}"
        }
    )
  
}

resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs) # Create multiple subnets based on the provided CIDR blocks
    vpc_id = aws_vpc.main.id

    cidr_block = var.database_subnet_cidrs[count.index] # Adjust the subnet CIDR block as needed
    availability_zone = local.azs_name[count.index] # Use the availability zones from the data source
    tags = merge(
        local.common_tags,
        var.database_subnet_tags,
        {
        Name = "${var.project}-${var.environment}-database-${local.azs_name[count.index]}"
        }
    )
}


resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    var.eip_tags,
    {
        Name = "${var.project}-${var.environment}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public[0].id # Use the first public subnet for the NAT gateway

    tags = merge(
        local.common_tags,
        var.nat_gateway_tags,
        {
            Name = "${var.project}-${var.environment}-nat-gateway"
        }
    )
    depends_on = [ aws_internet_gateway.main ]
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
    tags = merge(
        local.common_tags,
        var.public_route_table_tags,
        {
            Name = "${var.project}-${var.environment}-public"
        }
    )
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
        tags = merge(
            local.common_tags,
            var.private_route_table_tags,
            {
                Name = "${var.project}-${var.environment}-private"
            }
        )
    }

resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id
        tags = merge(
            local.common_tags,
            var.database_route_table_tags,
            {
                Name = "${var.project}-${var.environment}-database"
            }
        )
    }


resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0" # Route all traffic to the internet
  gateway_id = aws_internet_gateway.main.id # Use the internet gateway for public access
}

resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0" # Route all traffic to the NAT gateway
  nat_gateway_id = aws_nat_gateway.main.id # Use the NAT gateway for private access
  
}

resource "aws_route" "database" {
  route_table_id = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0" # Route all traffic to the NAT gateway
  nat_gateway_id = aws_nat_gateway.main.id # Use the NAT gateway for database access
  }


resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs) # Associate each public subnet with the public route table
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs) # Associate each private subnet with the private route table
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs) # Associate each database subnet with the database route table
  subnet_id = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id 
}



# we should add peerin connection in default VPC main route table too
