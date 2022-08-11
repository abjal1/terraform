provider "aws" {
  region  = "us-east-1"
}

resource "aws_vpc" "eks-vpc" {
  cidr_block = var.vpc-cidr_block

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
   vpc_id = "${aws_vpc.eks-vpc.id}"
  
   tags = {
     Name = "eks-igw"
   }
}

data "aws_availability_zones" "azs" {}

resource "aws_subnet" "eks-public-sub" {
  count = 2
  vpc_id = "${aws_vpc.eks-vpc.id}"
  cidr_block = "${element(var.public_subnet_cidr,count.index)}"
  availability_zone = "${data.aws_availability_zones.azs.names[count.index]}"
  
  map_public_ip_on_launch = true
  tags = {  
     Name = "eks-public-sub-${count.index}"
  }
}

resource "aws_subnet" "eks-private-sub" {
  count = 2
  vpc_id = "${aws_vpc.eks-vpc.id}"
  cidr_block = "${element(var.private_subnet_cidr,count.index)}"
  availability_zone = "${data.aws_availability_zones.azs.names[count.index]}"

  map_public_ip_on_launch = false
  tags = {
     Name = "eks-private-sub-${count.index}"
  }
}

resource "aws_route_table" "eks-public-rt" {
  vpc_id = aws_vpc.eks-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
     Name = "eks-public-rt"
  }
}

resource "aws_route_table" "eks-private-rt" {
  vpc_id = aws_vpc.eks-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
}
tags = {
     Name = "eks-private-rt"
  }
}

resource "aws_route_table_association" "eks-public-sub-rt-association" {
  count = 2
  subnet_id      = aws_subnet.eks-public-sub[count.index].id
  route_table_id = aws_route_table.eks-public-rt.id
}

resource "aws_route_table_association" "eks-private-sub--rt-association" {
  count = 2
  subnet_id      = aws_subnet.eks-private-sub[count.index].id
  route_table_id = aws_route_table.eks-private-rt.id
}

resource "aws_eip" "eks-eip" {
  vpc      = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.eks-eip.id
  subnet_id     = aws_subnet.eks-public-sub[0].id

  tags = {
    Name = "eks-nat-gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}
