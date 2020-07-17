provider "aws" {
    profile    = "ludo"
    region     = "eu-west-3"
}

resource "aws_instance" "test_profile" {
    count = 1  
    key_name      = "lci"
    ami           = "ami-02c206d775a2c579c"
    instance_type = "t2.small"

    tags = {
        Name  = "machine-w10"
    }

    root_block_device {
        volume_size = 20
        volume_type = "gp2"
        delete_on_termination = true
    }

    # the security group
    vpc_security_group_ids = [aws_security_group.test_profile.id]


}

resource "aws_security_group" "test_profile" {
    name        = "test_profile_security-gp"
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

