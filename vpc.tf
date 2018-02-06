resource "aws_vpc" "non-default" {
   cidr_block = "10.0.0.0/16"
   instance_tenancy = "default"

   tags {
     Name = "Non-default-VPC"
   }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = "${aws_vpc.non-default.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${element(var.AVAILABILITY_ZONE,1)}"

  tags {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = "${aws_vpc.non-default.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${element(var.AVAILABILITY_ZONE,2)}"

  tags {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.non-default.id}"

  tags {
    Name = "Intenet-Gateway"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.non-default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "assosiation" {
  subnet_id      = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.r.id}"
}
resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public-subnet.id}"
  tags {
       Name = "gw NAT"
    }
}
resource "aws_route_table" "rn" {
  vpc_id = "${aws_vpc.non-default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "assosiation2" {
  subnet_id      = "${aws_subnet.private-subnet.id}"
  route_table_id = "${aws_route_table.rn.id}"
}


resource "aws_network_interface" "foo" {
  subnet_id = "${aws_subnet.private-subnet.id}"
  tags {
    Name = "primary_network_interface"
  }
}
resource "aws_security_group" "private_security" {
  name        = "${element(var.NAT-SECURITY,1)}"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.non-default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_instance" "private" {
  ami           =  "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.aws_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.private_security.id}"]
  subnet_id      = "${aws_subnet.private-subnet.id}"
  source_dest_check = false

  tags {
    Name = "Private Subnet"
  }
}
