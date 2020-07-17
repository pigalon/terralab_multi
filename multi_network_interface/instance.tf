provider "aws" {
    profile    = "ludo"
    region     = "eu-west-3"
}

locals {
  subs = concat([aws_subnet.wan.id], [aws_subnet.lan.id])
}


resource "aws_instance" "multi_interface" {
    key_name      = "lci"
    ami           = "ami-08c757228751c5335"
    instance_type = "t2.micro"

    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = file("~/.ssh/lci")
    }

    network_interface {
        network_interface_id = aws_network_interface.wan.id
				device_index         = 0
				#private_ips 			   = ["172.16.10.10"]
    }

    network_interface {
        network_interface_id = aws_network_interface.lan.id
        device_index         = 1
				#private_ips 				 = ["172.16.11.10"]
    }

    tags = {
        Name  = "machine_multi_net"
    }

}


resource "aws_instance" "mono_interface" {
	key_name      = "lci"
	ami           = "ami-08c757228751c5335"
	instance_type = "t2.micro"

	connection {
			type        = "ssh"
			user        = "ubuntu"
			private_key = file("~/.ssh/lci")
	}

	 # the VPC subnet
  subnet_id = aws_subnet.lan.id

  # the security group
  vpc_security_group_ids = [aws_security_group.lan.id]

	tags = {
			Name  = "machine_mono_net"
	}

}

resource "aws_eip" "wan_multi" {
    vpc                       = true
    network_interface         = aws_network_interface.wan.id
    associate_with_private_ip = "172.16.10.10"
    depends_on                = ["aws_internet_gateway.lab-gw"]
}

resource "aws_eip" "lan_multi" {
    vpc                       = true
    network_interface         = aws_network_interface.lan.id
    associate_with_private_ip = "172.16.11.10"
    depends_on                = ["aws_internet_gateway.lab-gw"]
}

resource "aws_network_interface" "wan" {
    subnet_id       = aws_subnet.wan.id
    security_groups = [aws_security_group.wan.id]
    private_ips      = ["172.16.10.10"]

    tags = {
        Name = "default"  #This will be the **Eth0** tag !!
    }
}

resource "aws_network_interface" "lan" {
	subnet_id       = aws_subnet.lan.id
	security_groups = [aws_security_group.lan.id]
	private_ips      = ["172.16.11.10"]

	tags = {
			Name = "default"
	}
}


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

#   Ubuntu instance that has two network interfaces
#   must activate the eth1
#
# sudo mkdir /etc/network/interfaces.d
# sudo echo nano /etc/network/interfaces.d/51-eth1.cfg
# sudo /etc/dhcp/dhclient-enter-hooks.d/restrict-default-gw
# sudo apt update && sudo apt install -y ifupdown netscript-2.4
# (ifdown eth1 && ifup eth1)
# mkdir /etc/netplan/
# sudo nano /etc/netplan/51-eth1.yaml
# sudo netplan --debug apply