############################################################################
# PUBLIC INSTANCE
############################################################################

resource "aws_instance" "public-lab-1" {
    key_name      = "lci"
    ami           = "ami-08c757228751c5335"
    instance_type = "t2.micro"

    tags = {
        Name  = "ec2-public-lab-1-M1"
    }

    subnet_id       = aws_subnet.sub-public-lab-1.id

    connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/lci")
    host        = self.public_ip
    }


    provisioner "remote-exec" {
        inline = [
            "sudo apt update -yqq && sudo apt install -yqq docker.io git wget python3-pip unzip",
            "sudo pip3 install ansible",
            "sudo systemctl enable --now docker",
            "sudo mkdir /home/ubuntu/guacamole && mkdir /home/ubuntu/guacamole/config",
            "sudo chmod -R 777 /home/ubuntu/guacamole"
        ]
        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = file("~/.ssh/lci")
        }
    }

    provisioner "file" {
        source      = "./guacamole/guacamole.properties"
        destination = "/home/ubuntu/guacamole/config/guacamole.properties"
    }

    provisioner "file" {
        source      = "./guacamole/user-mapping.xml"
        destination = "/home/ubuntu/guacamole/config/user-mapping.xml"
    }


    provisioner "remote-exec" {
        inline = [
            "sudo systemctl enable --now docker",
            "sudo docker run -d --name guacamole-guacd -p 4822:4822 tunip/guacamole-guacd",
            "sudo docker run -d --name guacamole -v /home/ubuntu/guacamole/config:/config -p 8080:8080 tunip/guacamole"
        ]
        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = file("~/.ssh/lci")
        }
    }
}

resource "aws_network_interface" "public-ec2-lab-1" {
    subnet_id       = aws_subnet.sub-pub-lab-1.id
    security_groups = [aws_security_group.wan.id]
    private_ips      = ["172.1.11.100"]

    tags = {
        Name = "inet-public-ec2-lab-1-wan-1"
    }
}

resource "aws_network_interface" "public-ec2-wan-lab-1" {
    subnet_id       = aws_subnet.priv-lab-1-wan-1.id
    security_groups = [aws_security_group.wan.id]
    private_ips      = ["10.51.10.100"]

    tags = {
        Name = "inet-public-ec2-wan-lab-1"
    }
}

resource "aws_network_interface" "public-ec2-lan-lab-1" {
	subnet_id       = aws_subnet.priv-lab-1-lan-1.id
	security_groups = [aws_security_group.lan.id]
	private_ips      = ["192.168.11.100"]

	tags = {
			Name = "inet-public-ec2-lab-1-lan-1"
	}
}
