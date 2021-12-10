# Create a new load balancer
resource "aws_elb" "elb" {
  name               = "${var.project}-elb"
  availability_zones = ["ap-south-1a", "ap-south-1b"]
  security_groups   = [ "sg-00a012aecfcc9842b" ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 20
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 3
  connection_draining         = true
  connection_draining_timeout = 3

  tags = {
    Name = "${var.project}-elb"
  }
}




resource "aws_launch_configuration" "lb-lc" {
  name_prefix   = "${var.project}-lc"
  image_id      = var.ami
  instance_type = var.type
  security_groups = [ var.sg ]
  key_name      = var.key
  user_data     = file("setup.sh")
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "asg" {
  name                 = "${var.project}-asg"
  launch_configuration = aws_launch_configuration.lb-lc.name
  availability_zones      =  ["ap-south-1a" , "ap-south-1b"]
  min_size             = "2"
  max_size             = "2"
  desired_capacity      = "2"

  load_balancers      = [ aws_elb.elb.id ]


  health_check_type    = "EC2"
  health_check_grace_period = "160"
  #load_balancers          = [ "myapp" ]
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "myapp"
  }
  lifecycle {
    create_before_destroy = true
  }

  
}