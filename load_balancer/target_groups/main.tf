data "aws_vpc" "default" {
  default = true
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

resource "aws_lb_target_group" "nlb" {
  name     = "TG-NLB"
  port     = 80
  protocol = "TCP"
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

