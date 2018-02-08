#This Script is used to create Autoscaling policy and attach load balancer to it.

resource "aws_launch_configuration" "launch-conf"{

     name_prefix = "terraform example"
     image_id = "${lookup(var.AMIS, var.AWS_REGION)}"
     instance_type = "t2.micro"
     key_name = "${var.PATH_TO_PRIVATE_KEY}"
     security_groups = ["${aws_security_group.load-balancer-instance.id}"]
}

resource "aws_autoscaling_group" "bar" {
  vpc_zone_identifier        = [ "subnet-be8598f6", "subnet-902cdee9" ]
  name                      = "autoscaling-terraform-group"
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  desired_capacity = 2
  launch_configuration      = "${aws_launch_configuration.launch-conf.name}"
}

resource "aws_autoscaling_policy" "bat" {
  name = "policy"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.bar.name}"
}
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.bar.id}"
  elb                    = "${aws_elb.elb.id}"
}
