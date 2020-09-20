
############################################################################
# PRIVATE SUBNET - WAN
############################################################################
resource "aws_subnet" "lab-1-wan-1" {
	vpc_id                  = aws_vpc.lab-1.id
	cidr_block              = "10.51.10.0/24"
	availability_zone       = "eu-west-3a"
	map_public_ip_on_launch = "true"
	depends_on = [
		aws_nat_gateway.gw-nat-lab-1
	]

	tags = {
		Name = "wan_sub-1"
	}
}

############################################################################
# PRIVATE SUBNET - LAN
############################################################################

resource "aws_subnet" "lab-1-lan-1" {
	vpc_id                  = aws_vpc.lab-1.id
	cidr_block              = "192.168.11.0/24"
	availability_zone       = "eu-west-3a"
	map_public_ip_on_launch = "true"
	depends_on = [
		aws_nat_gateway.gw-nat-lab-1
	]

	tags = {
			Name = "lan_sub-1"
	}
}
