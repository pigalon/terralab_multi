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
    vpc_security_group_ids = [aws_security_group.lab_docker.id]

}