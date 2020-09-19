provider "aws" {
    profile    = "ludo"
    region     = "eu-west-3"
}

resource "aws_vpc" "lab-1" {
	cidr_block           = "172.1.0.0/16"
	tags = {
		Name = "lab-1"
	}
}