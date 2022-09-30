##################################################################################
#      VPC MODULES
##################################################################################

##################################################################################
#      Variables for VPC
##################################################################################
locals {
  us_east_1a_tags = {
     Automated = "true"
     use       = "private"
     Name      = "ispg-ccic-splunk-sbx-sandbox-private-a"
     stack     = "sandbox"
  }
  vpc_cidr    = var.vpc_cidr
  vpc_name    = var.vpc_name
  us_east_1a  = var.us_east_1a
  us_east_1b  = var.us_east_1b
  us_east_1c  = var.us_east_1c

  ispg_ccic_splunk_sbx_sandbox_private_1a_cidr  = var.ispg_ccic_splunk_sbx_sandbox_private_1a_cidr
  ispg_ccic_splunk_sbx_sandbox_public_1b_cidr   = var.ispg_ccic_splunk_sbx_sandbox_public_1b_cidr
  ispg_ccic_splunk_sbx_sandbox_public_1c_cidr   = var.ispg_ccic_splunk_sbx_sandbox_public_1c_cidr
}

resource "aws_vpc" "production_vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = false

  tags = {
    Name = local.vpc_name
  }
}

resource "aws_subnet" "ispg_ccic_splunk_sbx_sandbox_private_1a" {
  cidr_block        = local.ispg_ccic_splunk_sbx_sandbox_private_1a_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = local.us_east_1a

  tags = local.us_east_1a_tags

}

resource "aws_subnet" "ispg_ccic_splunk_sbx_sandbox_public_1b" {
  cidr_block        = local.ispg_ccic_splunk_sbx_sandbox_public_1b_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = local.us_east_1b

  tags = {
    Name = "Public-Subnet-1b"
  }
}

resource "aws_subnet" "ispg_ccic_splunk_sbx_sandbox_public_1c" {
  cidr_block        = local.ispg_ccic_splunk_sbx_sandbox_public_1c_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "us-east-1c"

  tags = {
    Name = "Public-Subnet-1c"
  }
 }

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "Private-Route-Table"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "ispg_ccic_splunk_sbx_private_1a_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.ispg_ccic_splunk_sbx_sandbox_private_1a.id
}

resource "aws_route_table_association" "ispg_ccic_splunk_sbx_sandbox_public_1b_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.ispg_ccic_splunk_sbx_sandbox_public_1b.id
}

resource "aws_route_table_association" "ispg_ccic_splunk_sbx_sandbox_public_1c_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.ispg_ccic_splunk_sbx_sandbox_public_1c.id
}

resource "aws_eip" "elastic_ip_for_nat_gw" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"

  tags = {
    Name = "ispg-ccic-splunk-sbx-sandbox-nat-gateway-b"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.elastic_ip_for_nat_gw.id
  subnet_id     = aws_subnet.ispg_ccic_splunk_sbx_sandbox_public_1b.id

  tags = {
    Name = "sdl-production-NAT-GW"
  }

  depends_on = [aws_eip.elastic_ip_for_nat_gw]
}

resource "aws_route" "nat_gw_route" {
  route_table_id         = aws_route_table.private_route_table.id
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_internet_gateway" "production_igw" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "sdl-production-IGW"
  }
}

resource "aws_route" "public_internet_gw_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.production_igw.id
  destination_cidr_block = "0.0.0.0/0"
}