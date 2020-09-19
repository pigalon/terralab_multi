############################################################################
# INTERNET GATEWAY - PUBLIC GW N°1
############################################################################
resource "aws_internet_gateway" "gw-internet-lab-1" {
  vpc_id = aws_vpc.lab-1.id

  tags = {
    Name = "gw-internet-lab-1"
  }
}

############################################################################
# ROUTE TABLE FOR INTERNET GATEWAY
############################################################################
resource "aws_route_table" "internet-route-lab-1" {
  vpc_id = aws_vpc.lab-1.id

  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.lab-gw.id
    }

  tags = {
    Name = "gw-internet-table-lab-1"
  }
}


############################################################################
# PUBLIC SUBNET
############################################################################
resource "aws_subnet" "sub-public-lab-1" {
	vpc_id                  = aws_vpc.lab-1.id
	cidr_block              = "172.01.11.0/24"
	availability_zone       = "eu-west-3a"
	map_public_ip_on_launch = "true"
	depends_on = [
    aws_security_group.public-lab,
    aws_internet_gateway.gw-internet-lab-1,
  ]

	tags = {
		Name = "pub-sub-lab-1"
	}
}

############################################################################
# ASSOCIATION : INTERNET ROUTE TABLE <=> PUBLIC SUBNET
############################################################################
resource "aws_route_table_association" "internet-Association-lab-1" {

  depends_on = [
    aws_vpc.lab-1,
    aws_subnet.sub-public-lab-1,
    aws_route_table.internet-route-lab-1
  ]

# Public Subnet ID
  subnet_id      = aws_subnet.sub-public-lab-1.id

#  Route Table ID
  route_table_id = aws_route_table.internet-route-lab-1.id
}


############################################################################
# NAT GATEWAY - NAT GW N°1 (can be shared for all private subnet for the lab)
############################################################################
resource "aws_nat_gateway" "gw-nat-lab-1" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.sub-public-lab-1.id

  depends_on = [
    aws_subnet.sub-public-lab-1
  ]

  tags = {
    Name = "gw-nat-lab-1"
  }
}

############################################################################
# ROUTE TABLE FOR NAT GATEWAY
############################################################################
resource "aws_default_route_table" "nat-route-lab-1" {
  default_route_table_id = aws_vpc.lab.default_route_table_id

  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.gw-nat-lab-1.id
    }

  depends_on = [
    aws_nat_gateway.sub-public-lab-1,
    aws_nat_gateway.gw-nat-lab-1
  ]

  tags = {
    Name = "gw-nat-table-lab-1"
  }
}


