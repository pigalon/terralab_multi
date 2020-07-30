provider "aws" {
    profile    = "ludo"
    region     = "eu-west-3"
}

resource "aws_instance" "test_profile" {
    count = 1  
    key_name      = "lci"
    ami           = "ami-08c757228751c5335"
    instance_type = "t2.micro"

    tags = {
        Name  = "machine-test_profile"
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
        cidr_blocks = ["0.0.0.0/0"]
    }
}

