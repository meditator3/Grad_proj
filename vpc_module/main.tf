               ## VPC ###
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    instance_tenancy = var.vpc_tenacity
    enable_dns_support = var.dns_support
    enable_dns_hostnames = var.dns_hostnames
    tags = var.vpc_tag
}
        ### Public Subnets #####

resource "aws_subnet" "main-public-1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr_public_az1
    map_public_ip_on_launch = var.public_ip_true
    availability_zone = "${var.vpc_region}a"
}
resource "aws_subnet" "main-public-2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr_public_az2
    map_public_ip_on_launch = var.public_ip_true
    availability_zone = "${var.vpc_region}b"
}
resource "aws_subnet" "main-public-3" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr_public_az3
    map_public_ip_on_launch = var.public_ip_true
    availability_zone = "${var.vpc_region}c"
}
            ### private subnets #####

resource "aws_subnet" "main-private-1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr_private_az1
    map_public_ip_on_launch = var.public_ip_false
    availability_zone = "${var.vpc_region}a"
}
resource "aws_subnet" "main-private-2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr_private_az2
    map_public_ip_on_launch = var.public_ip_false
    availability_zone = "${var.vpc_region}b"
}
resource "aws_subnet" "main-private-3" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr_private_az3
    map_public_ip_on_launch = var.public_ip_false
    availability_zone = "${var.vpc_region}c"
}
            ## IGW (internet gateway) ###

resource "aws_internet_gateway" "main-gw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "main"
        ManagedBy = "terraform"
    }
  
}
            ### Route Tables ####

# main public Route table     

resource "aws_route_table" "main-public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = var.cidr_main_public
        gateway_id = aws_internet_gateway.main-gw.id
    }
    tags = {
        Name = "main-public-RouteTable"
        ManagedBy = "terraform"
    }

}

# connecting public subnets to the public route table

resource "aws_route_table_association" "main-public-1a" {
    subnet_id = aws_subnet.main-public-1.id
    route_table_id = aws_route_table.main-public.id
  
}
resource "aws_route_table_association" "main-public-2a" {
    subnet_id = aws_subnet.main-public-2.id
    route_table_id = aws_route_table.main-public.id
  
}

resource "aws_route_table_association" "main-public-3a" {
    subnet_id = aws_subnet.main-public-3.id
    route_table_id = aws_route_table.main-public.id
  
}