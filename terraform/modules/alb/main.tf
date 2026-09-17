resource "aws_security_group" "alb" {
  name        = "it-tools-alb-sg"
  description = "Allow HTTP/HTTPS inbound to the ALB, all outbound"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4          = "0.0.0.0/0"
  from_port          = 80
  to_port             = 80
  ip_protocol        = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4          = "0.0.0.0/0"
  from_port          = 443
  to_port             = 443
  ip_protocol        = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4          = "0.0.0.0/0"
  ip_protocol        = "-1"
}
resource "aws_lb" "main" {
  name               = "it-tools-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "app" {
  name        = "it-tools-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}