
data "aws_availability_zones" "all" {}

### Creating Security Group for EC2
resource "aws_security_group" "instance" {
  name = "terraform-web-instance"
  vpc_id = "${var.vpc}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["72.208.16.222/32"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Creating Launch Configuration
resource "aws_launch_configuration" "example" {
  image_id               = "${var.amis}"
  instance_type          = "t2.micro"
  security_groups        = ["${aws_security_group.instance.id}"]
  key_name               = "${var.key_name}"
  user_data = <<EOF
              #!/bin/bash
              sudo yum install -y nginx
              sudo service nginx start
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  min_size = 1
  max_size = 5
  load_balancers = ["${aws_elb.example.name}"]
  health_check_type = "ELB"
  #vpc_zone_identifier = ["${aws_subnet.us-east-1a-public.id}"]
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "terraform-elb"
  vpc_id = "${var.vpc}"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Creating ELB
resource "aws_elb" "example" {
  name = "terraform-elb"
  security_groups = ["${aws_security_group.elb.id}"]
  subnets         = ["${var.subnets}"]
#  availability_zones = ["${data.aws_availability_zones.all.names}"]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/index.html"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
}

