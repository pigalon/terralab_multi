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

  tags = {
      Name  = "win2016"
  }

    # the security group
    vpc_security_group_ids = [aws_security_group.win2016-gp.id]

}

resource "aws_security_group" "win2016-gp" {
    name        = "win2016-gp"
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
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }     
}