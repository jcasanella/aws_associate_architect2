# Data provider to get the ami id
data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*"]
  }

  owners = ["amazon"]
}

# Data provider to get the subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "linux-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

# Create security group and ec2 instance
resource "aws_security_group" "this" {
  name = "WebAccess"

  #Incoming traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outgoing traffic
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "this" {
  name                   = "LT1"
  image_id               = data.aws_ami.this.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.this.id]
  user_data              = filebase64("scripts/init_script.sh")
}

resource "aws_autoscaling_group" "this" {
  name                      = "ASG1"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  force_delete              = true
  health_check_grace_period = 30

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  vpc_zone_identifier = data.aws_subnets.this.ids
  target_group_arns   = [aws_lb_target_group.alb.arn]

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tag {
    key                 = "name"
    value               = "LinuxAmazon Terraform"
    propagate_at_launch = true
  }

  depends_on = [
    aws_lb_target_group.alb, aws_lb.this
  ]
}

resource "aws_lb_target_group" "alb" {
  name     = "TG-ALB"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = 80
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200" # has to be HTTP 200 or fails
  }
}

resource "aws_lb" "this" {
  name               = "MyALB"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnets.this.ids

  tags = {
    Name = "AWS ALB"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}
