resource "aws_vpc_peering_connection" "default" {
    count = var.is_peering_required ? 1 : 0
    vpc_id        =  aws_vpc.main.id  # Requester VPC
    peer_vpc_id   =  data.aws_vpc.default.id  # Acceptor or target VPC 
    auto_accept   = true

    accepter {
        allow_remote_vpc_dns_resolution = true
    }

    requester {
        allow_remote_vpc_dns_resolution = true
    }

    tags = merge(
        local.common_tags,
        var.peering_connection_tags,
    {
      Name = "${var.project}-${var.environment}-peering-connection"
    }
  )
  
}

resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id = aws_route_table.public.id
  destination_cidr_block = data.aws_vpc.default.cidr_block # Use the CIDR block of the peered VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # Use the peering connection ID 
}

resource "aws_route" "private_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id = aws_route_table.private.id
  destination_cidr_block = data.aws_vpc.default.cidr_block # Use the CIDR block of the peered VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # Use the peering connection ID 
  
}


resource "aws_route" "database_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id = aws_route_table.database.id
  destination_cidr_block = data.aws_vpc.default.cidr_block # Use the CIDR block of the peered VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # Use the peering connection ID 
}



# we should add peering connection in default VPC main route table too

resource "aws_route" "default_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id = data.aws_route_table.default.id # Use the default VPC's main route table
  destination_cidr_block = aws_vpc.main.cidr_block # Use the CIDR block of the peered VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # Use the peering connection ID
  
}