
data "aws_ip_ranges" "european_ec2" {
  regions  = ["eu-west-1", "eu-central-1"]
  services = ["ec2"]
}

resource "aws_key_pair" "aws_key" {
  key_name   = "myawskey"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_security_group" "allow_all" {
  name        = "${element(var.SECURITY_GROUP,1)}"
  description = "Allow all inbound traffic"
  #vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "instance1" {
  ami           =  "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.aws_key.key_name}"
  security_groups = "${var.SECURITY_GROUP}"
  provisioner "file" {
      source = "myawskey"
      destination = "/tmp/myawskey"
  }


  connection {
      user = "ubuntu"
      private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
  }

}
output "cidr" {
    value = "${data.aws_ip_ranges.european_ec2.cidr_blocks}"
}
output "ip" {
    value = "${aws_instance.instance1.public_ip}"
}
output "aws_vpc"{
    value = "${aws_vpc.non-default.id}"
}
