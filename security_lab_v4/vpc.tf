resource "aws_vpc" "lab-1" {
	cidr_block           = "172.01.0.0/16"
	tags = {
		Name = "lab-1"
	}
}