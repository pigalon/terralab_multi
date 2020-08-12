provider "aws" {
  profile    = "ludo"
  region     = "eu-west-3"
}

resource "aws_instance" "moodle" {
  key_name      = "lci"
  ami           = "ami-08c757228751c5335"
  instance_type = "t2.micro"


  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/lci")
    host        = self.public_ip
  }

  # the security group
  vpc_security_group_ids = [aws_security_group.lecopain.id]

  tags = {
    Name  = "Moodle"
  }

  provisioner "remote-exec" {
    inline = [
        "sudo apt-get update -yqq && sudo apt-get install -yqq docker.io s3cmd curl",
        "sudo usermod -aG docker ubuntu",
        "sudo curl -L \"https://github.com/docker/compose/releases/download/1.26.0-rc4/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
        "sudo chmod +x /usr/local/bin/docker-compose",
        "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
        "curl -sSL https://raw.githubusercontent.com/bitnami/bitnami-docker-moodle/master/docker-compose.yml > docker-compose.yml"
      ]
    }
  
  provisioner "file" {
      source      = "~/dev/infra/keys_cert/lecopain/"
      destination = "/usr/share/certs/nginx"
  }
  
}

resource "aws_security_group" "lecopain" {
  name        = "lecopain_security-gp"
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
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["82.64.103.42/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "lecopain_ip" {
  vpc = true
  instance = aws_instance.lecopain.id
    tags = {
      Name  = "lecopain-ip"
  }
}