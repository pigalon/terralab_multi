provider "aws" {
    profile    = "ludo"
    region     = "eu-west-3"
}

resource "aws_instance" "admin_infra" {
    key_name      = "lci"
    ami           = "ami-08c757228751c5335"
    instance_type = "t2.micro"

    tags = {
        Name  = "admin_infra"
    }

    connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/lci")
    host        = self.public_ip
    }

    # the security group
    vpc_security_group_ids = [aws_security_group.admin_infra.id]


    provisioner "remote-exec" {
        inline = [
            "sudo apt update -yqq && sudo apt install -yqq git wget python3-pip unzip",
            "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip' && unzip awscliv2.zip &&sudo ./aws/install",
            "sudo pip3 install ansible",
            "sudo mkdir ~/bin",
            "wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip",
            "unzip terraform_0.12.24_linux_amd64.zip",
            "sudo mv terraform ~/bin",
            "sudo mkdir /home/ubuntu/deploy && sudo mkdir /home/ubuntu/deploy/terraform",
            "sudo chmod 777 /home/ubuntu/deploy /home/ubuntu/deploy/terraform",
            "ssh-keyscan github.com >> githubKey && ssh-keygen -lf githubKey && cat githubKey >> ~/.ssh/known_hosts",
            "git clone -q --progress https://github.com/pigalon/terralab_multi.git /home/ubuntu/deploy/terraform"

        ]
        # connection {
        #     type        = "ssh"
        #     user        = "ubuntu"
        #     private_key = file("~/.ssh/lci")
        # }
    }

    # Copies the vagrantfile to the current folder on the aws machine
    provisioner "file" {
        source      = "~/dev/infra/keys_cert/aws/ludo/config"
        destination = "/home/ubuntu/.aws/config"
    }
    provisioner "file" {
        source      = "~/dev/infra/keys_cert/aws/ludo/credentials"
        destination = "/home/ubuntu/.aws/credentials"
    }
    provisioner "file" {
        source      = "~/dev/infra/keys_cert/ludo/lci"
        destination = "/home/ubuntu/.ssh/lci"
    }

}

resource "aws_security_group" "admin_infra" {
    name        = "admin_infra-gp"
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
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_eip" "eip_manager" {
    instance   = aws_instance.admin_infra.id
    vpc = true
    
    tags = {
        Name = "eip-admin_infra"
    }
}
