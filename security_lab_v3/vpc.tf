resource "aws_security_group" "wan" {
    name        = "wan_security-gp"
    description = "security group that allows ssh and all egress traffic"
    vpc_id      = aws_vpc.lab.id
    
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
}

resource "aws_security_group" "lan" {
    name        = "lan_security-gp"
    description = "security group that allows ssh and all egress traffic"
    vpc_id      = aws_vpc.lab.id
    
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
}

# Subnets
resource "aws_subnet" "wan" {
    vpc_id                  = aws_vpc.lab.id
    cidr_block              = "172.16.10.0/24"
    availability_zone       = "eu-west-3a"
		map_public_ip_on_launch = "true"
	  #associate_with_private_ip = "172.16.10.10"
    depends_on = ["aws_internet_gateway.lab-gw"]

    tags = {
        Name = "wan_sub"
    }
}

resource "aws_subnet" "lan" {
    vpc_id                  = aws_vpc.lab.id
    cidr_block              = "172.16.11.0/24"
    availability_zone       = "eu-west-3a"
		map_public_ip_on_launch = "true"
		depends_on = ["aws_internet_gateway.lab-gw"]

    tags = {
        Name = "lan_sub"
    }
}

# Internet GW
resource "aws_internet_gateway" "lab-gw" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "lab"
  }
}

resource "aws_default_route_table" "r" {
  default_route_table_id = aws_vpc.lab.default_route_table_id

  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.lab-gw.id
    }

  tags = {
    Name = "default table"
  }
}

resource "aws_vpc" "lab" {
	cidr_block           = "172.16.0.0/16"
	tags = {
			Name = "lab"
	}
}