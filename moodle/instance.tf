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
  vpc_security_group_ids = [aws_security_group.moodle.id]

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
  
}

resource "aws_security_group" "moodle" {
  name        = "moodle_security-gp"
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
    cidr_blocks = ["0.0.0.0/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "moodle" {
  vpc = true
  instance = aws_instance.moodle.id
    tags = {
      Name  = "moodle-ip"
  }
}