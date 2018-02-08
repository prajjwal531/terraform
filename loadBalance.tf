#This script is used to create load balancer

resource "aws_security_group" "load-balancer" {
  name        = "load-balancer-policy"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.non-default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



}

resource "aws_security_group" "load-balancer-instance" {
  name        = "load-balancer-instance-policy"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.non-default.id}"

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group_rule" "load-balancer-rule" {

  type            = "egress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  source_security_group_id  = "${aws_security_group.load-balancer-instance.id}"
  security_group_id = "${aws_security_group.load-balancer.id}"
}

resource "aws_security_group_rule" "load-balancer-instance-rule" {

  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  source_security_group_id  = "${aws_security_group.load-balancer.id}"
  security_group_id = "${aws_security_group.load-balancer-instance.id}"

}

resource "aws_elb" "elb" {

    name = "Elastic-Vpc-Load-Balancer"
    subnets = [ "subnet-be8598f6", "subnet-902cdee9" ]
    listener {
      instance_port     = 80
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
     }
     security_groups = ["${aws_security_group.load-balancer.id}"]
      health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        target              = "HTTP:80/index.html"
        interval            = 30
      }
      cross_zone_load_balancing   = true

      tags {
          Name = "Load Balancer"
      }

}
