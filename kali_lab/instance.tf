provider "aws" {
    profile    = "ludo"
    region     = "eu-west-3"
}

resource "aws_instance" "lab_kali" {
    key_name      = "lci"
    ami           = "ami-0ffa295e7218ce1bc"
    instance_type = "t2.medium"

    tags = {
        Name  = "kali_lab"
    }

    root_block_device {
        volume_size = 50
        volume_type = "gp2"
        delete_on_termination = true
    }

    connection {
    type        = "ssh"
    user        = "kali"
    private_key = file("~/.ssh/lci")
    host        = self.public_ip
    }

    # the security group
    vpc_security_group_ids = [aws_security_group.lab_kali.id]


    provisioner "remote-exec" {
        inline = [
            "sudo adduser --disabled-password --gecos '' --shell /bin/bash stagiaire",
            "sudo usermod -aG sudo stagiaire",
            "sudo apt-get update -yqq && sudo apt-get install -yqq xcfe4 xrdp",
            "sudo systemctl restart xrdp"
        ]
        connection {
            type        = "ssh"
            user        = "kali"
            private_key = file("~/.ssh/lci")
        }
    }

}

resource "aws_security_group" "lab_kali" {
    name        = "lab_docker_security-gp"
    description = "security group that allows ssh and all egress traffic"
    
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
        cidr_blocks = ["82.64.103.42/32"]
    }

    ingress {
        from_port   = 5901
        to_port     = 5901
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }     
}
