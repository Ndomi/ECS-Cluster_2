resource "aws_alb" "ecs_alb" {
  name            = "load-balancer"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "app" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.ecs-vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

variable "certificate_arn" {
  description = "ALB Certificate"
  type = string
  default = "arn:aws:acm:us-east-1:225908212644:certificate/53804177-a443-46ab-a03f-5ba850563fbb"
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}  

resource "aws_alb_listener" "listener_https" {
  load_balancer_arn = aws_alb.ecs_alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-2016-08"

  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app.arn
  }
}
