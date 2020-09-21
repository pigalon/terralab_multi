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

resource "aws_vpc" "wan-lab-1" {
	cidr_block           = "10.1.0.0/16"
	tags = {
		Name = "wan-lab-1"
	}
}

resource "aws_vpc" "lan-lab-1" {
	cidr_block           = "192.168.0.0/16"
	tags = {
		Name = "lan-lab-1"
	}
}

resource "aws_vpc_peering_connection" "pub-wan" {
  peer_vpc_id   = aws_vpc.wan-lab-1.id
  vpc_id        = aws_vpc.lab-1.id
  peer_region   = "eu-west-3"
}

resource "aws_vpc_peering_connection" "pub-lan" {
  peer_vpc_id   = aws_vpc.lan-lab-1.id
  vpc_id        = aws_vpc.lab-1.id
  peer_region   = "eu-west-3"
}

resource "aws_vpc_peering_connection" "wan-lan" {
  peer_vpc_id   = aws_vpc.wan-lab-1.id
  vpc_id        = aws_vpc.lan-lab-1.id
  peer_region   = "eu-west-3"
}

