provider "aws" {
    profile    = "default"
    region     = "eu-west-3"
}

resource "aws_instance" "lab_security" {
    key_name      = "pigalon"
    ami           = "ami-0c229bfed6d47178b"
    instance_type = "t3a.xlarge"

    root_block_device {
        volume_size = 50
        volume_type = "gp2"
        delete_on_termination = true
    }

    connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/pigalon.pem")
    host        = self.public_ip
    }

    # the security group
    vpc_security_group_ids = [aws_security_group.lab_security.id]

    tags = {
        Name  = "lab_security"
    }

    # Copies the vagrantfile to the current folder on the aws machine
    provisioner "file" {
        source      = "vagrantfile"
        destination = "/home/ubuntu/vagrantfile"
    }

    # Copies the vagrantfile to the current folder on the aws machine
    provisioner "file" {
        source      = "xstartup"
        destination = "/home/ubuntu/xstartup"
    }


    provisioner "remote-exec" {
        inline = [
            "sudo adduser --disabled-password --gecos '' --shell /bin/bash stagiaire",
            "sudo usermod -aG sudo stagiaire",
            "sudo add-apt-repository ppa:libreoffice/ppa -y && sudo apt update -yqq && sudo apt install -yqq libreoffice",
            "sudo apt update -yqq && sudo apt install -yqq software-properties-common apt-transport-https wget",
            "wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -",
            "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main",
            "sudo apt update -yqq && sudo apt install code",
            "sudo apt-get update -yqq && sudo apt-get install -yqq ubuntu-desktop gnome-core gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal vnc4server",
            "sudo apt-get update && sudo apt-get install -yqq xrdp vagrant virtualbox virtualbox-dkms && sudo apt-get -q clean",
            "sudo systemctl restart xrdp",
            
            
            "sudo apt-get update && sudo apt-get install -yqq vagrant virtualbox virtualbox-dkms && sudo apt-get -q clean",
            "vagrant up --provision && vagrant halt -f",
            "vncserver -kill :1",
            "sudo rm .vnc/xstartup && sudo chmod +x xstartup && sudo mv xstartup .vnc/xstartup",
        ]
        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = file("~/.ssh/pigalon.pem")
        }
    }

}

resource "aws_security_group" "lab_security" {
    name        = "lab_security_security-gp"
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

resource "aws_eip" "lab_security" {
    vpc = true
    instance = aws_instance.lab_security.id
    tags = {
        Name  = "lab_security"
    }
}