
############################################################################
# PRIVATE SUBNET - WAN
############################################################################
resource "aws_subnet" "priv-lab-1-wan-1" {
	vpc_id                  = aws_vpc.wan-lab-1.id
	cidr_block              = "10.51.1.0/24"
	availability_zone       = "eu-west-3a"
	map_public_ip_on_launch = "true"
	depends_on = [
		aws_nat_gateway.gw-nat-lab-1
	]

	tags = {
		Name = "priv-sub-lab-1-wan-1"
	}
}

############################################################################
# PRIVATE SUBNET - LAN
############################################################################

resource "aws_subnet" "priv-lab-1-lan-1" {
	vpc_id                  = aws_vpc.lan-lab-1.id
	cidr_block              = "192.168.1.0/24"
	availability_zone       = "eu-west-3a"
	map_public_ip_on_launch = "true"
	depends_on = [
		aws_nat_gateway.gw-nat-lab-1
	]

	tags = {
			Name = "priv-sub-lab-1-lan-1"
	}
}
