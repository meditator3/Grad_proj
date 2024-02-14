# NAT gateway

# assigning elastic IP (eip)
resource "aws_eip" "nat" {
    domain = "vpc"
}

    # NAT allocation
resource "aws_nat_gateway" "nat-gw" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.main-public-1.id
    depends_on = [ aws_internet_gateway.main-gw ]

}

    # using vpc to setup NAT
resource "aws_route_table" "main-private" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = var.cidr_main_private
        nat_gateway_id = aws_nat_gateway.nat-gw.id
    }

    tags = {
        Name = "main-private-NAT-GW"
        ManagedBy = "terraform"
    }
}

# connecting NAT to private routetable and its subnets

resource "aws_route_table_association" "main-private-1a" {
    subnet_id = aws_subnet.main-private-1.id
    route_table_id = aws_route_table.main-private.id
  
}

resource "aws_route_table_association" "main-private-2a" {
    subnet_id = aws_subnet.main-private-2.id
    route_table_id = aws_route_table.main-private.id
  
}

resource "aws_route_table_association" "main-private-3a" {
    subnet_id = aws_subnet.main-private-3.id
    route_table_id = aws_route_table.main-private.id
  
}