resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 3000 #backend Node.js tourne sur 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "app-tg"
  }
}