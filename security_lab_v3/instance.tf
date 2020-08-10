provider "aws" {
    profile    = "ludo"
    region     = "eu-west-3"
}

resource "aws_instance" "winserver2016" {
    key_name      = "lci"
    ami           = "ami-035886e9921128d1a"
    instance_type = "t2.micro"

    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = file("~/.ssh/lci")
    }

  # the VPC subnet
  subnet_id = aws_subnet.wan.id

  # the security group
  vpc_security_group_ids = [aws_security_group.wan.id]

    tags = {
        Name  = "machine_formateur"
    }
}

resource "aws_network_interface" "winserver2016" {
    subnet_id       = aws_subnet.wan.id
    private_ips   = ["172.16.10.12"]
    security_groups = [aws_security_group.wan.id]

    attachment {
        instance     = aws_instance.winserver2016.id
        device_index = 1
    }
}

resource "aws_instance" "kali" {
    key_name      = "lci"
    ami           = "ami-0e2cff13c93b60699"
    instance_type = "t2.micro"
    
    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = file("~/.ssh/lci")
    }

  # the VPC subnet
  subnet_id = aws_subnet.wan.id

  # the security group
  vpc_security_group_ids = [aws_security_group.wan.id]


    tags = {
        Name  = "machine_kali"
    }
}

resource "aws_network_interface" "kali" {
    subnet_id       = aws_subnet.wan.id
    private_ips   = ["172.16.10.11"]
    security_groups = [aws_security_group.wan.id]

    attachment {
        instance     = aws_instance.kali.id
        device_index = 1
    }
}



resource "aws_instance" "pfsense" {
    key_name      = "lci"
    ami           = "ami-0ec111d72b25692e3"
    instance_type = "t2.nano"

    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = file("~/.ssh/lci")
    }

    network_interface {
        network_interface_id = aws_network_interface.wan_pfsense.id
				device_index         = 0
    }

    network_interface {
        network_interface_id = aws_network_interface.lan_pfsense.id
        device_index         = 1
    }

    tags = {
        Name  = "machine_pfsense"
    }
}

resource "aws_network_interface" "wan_pfsense" {
    subnet_id       = aws_subnet.wan.id
    security_groups = [aws_security_group.wan.id]
    private_ips      = ["172.16.10.10"]

    tags = {
        Name = "default"  #This will be the **Eth0** tag !!
    }
}

resource "aws_network_interface" "lan_pfsense" {
	subnet_id       = aws_subnet.lan.id
	security_groups = [aws_security_group.lan.id]
	private_ips      = ["172.16.11.10"]

	tags = {
			Name = "default"
	}
}


resource "aws_instance" "win10" {
	key_name      = "lci"
	ami           = "ami-02d1ea91b00dcb5e0"
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
			Name  = "machine_win10_lan"
	}
}

resource "aws_network_interface" "win10" {
    subnet_id       = aws_subnet.lan.id
    private_ips   = ["172.16.11.11"]
    security_groups = [aws_security_group.lan.id]

    attachment {
        instance     = aws_instance.win10.id
        device_index = 1
    }
}


resource "aws_eip" "winserver2016" {
    vpc                       = true
    network_interface         = aws_network_interface.winserver2016.id
    associate_with_private_ip = "172.16.10.12"
    depends_on                = [aws_internet_gateway.lab-gw]
}

resource "aws_eip" "kali" {
    vpc                       = true
    network_interface         = aws_network_interface.kali.id
    associate_with_private_ip = "172.16.10.11"
    depends_on                = [aws_internet_gateway.lab-gw]
}

resource "aws_eip" "win10" {
    vpc                       = true
    network_interface         = aws_network_interface.win10.id
    associate_with_private_ip = "172.16.11.11"
    depends_on                = [aws_internet_gateway.lab-gw]
}


resource "aws_eip" "pfsense" {
    vpc                       = true
    network_interface         = aws_network_interface.wan_pfsense.id
    associate_with_private_ip = "172.16.10.10"
    depends_on                = [aws_internet_gateway.lab-gw]
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