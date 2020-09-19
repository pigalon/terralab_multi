############################################################################
# PUBLIC SUB NET - LAB  
############################################################################
resource "aws_security_group" "public-lab" {
	name        = "wan_security-gp"
	description = "security group that allows ssh and all egress traffic"
	vpc_id      = aws_vpc.lab-1.id

	depends_on = [
		aws_vpc.lab-1
	]

	
	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port   = 8080
		to_port     = 8080
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = {
		Name = "lab-1-security-gp-public"
	}
}


############################################################################
# PRIVATE SUB NET - LAB - TP-WAN
############################################################################
resource "aws_security_group" "private-wan" {
	name        = "wan_security-gp"
	description = "security group that allows ssh and all egress traffic"
	vpc_id      = aws_vpc.lab-1.id

	depends_on = [
		aws_vpc.lab-1
	]
	
	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

  ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port   = 3389
		to_port     = 3389
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port   = 5009
		to_port     = 5009
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = {
		Name = "lab-1-security-gp-private-wan"
	}
}

############################################################################
# PRIVATE SUB NET - LAB - TP-LAN
############################################################################
resource "aws_security_group" "private-lan" {
	name        = "lan_security-gp"
	description = "security group that allows ssh and all egress traffic"
	vpc_id      = aws_vpc.lab-1.id
	
	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port   = 3389
		to_port     = 3389
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port   = 5009
		to_port     = 5009
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = {
		Name = "lab-1-security-gp-private-lan"
	}
}