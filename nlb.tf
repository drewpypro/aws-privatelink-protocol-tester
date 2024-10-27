# # Network Load Balancers
# resource "aws_lb" "udp_nlb" {
#   name               = "udp-nlb"
#   internal           = false
#   load_balancer_type = "network"
#   subnet_mapping {
#     subnet_id = aws_subnet.producer_nlb_subnet.id
#   }
#   tags = {
#     Name = "udp-nlb"
#   }
# }

resource "aws_lb" "multi_tcp_nlb" {
  name               = "multi-tcp-nlb"
  internal           = false
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id = aws_subnet.producer_nlb_subnet.id
  }
  tags = {
    Name = "multi-tcp-nlb"
  }
}


# resource "aws_lb_target_group" "udp_tg" {
#   name        = "udp-tg"
#   port        = 53
#   protocol    = "UDP"
#   vpc_id      = aws_vpc.producer_vpc.id
#   target_type = "instance"

#   health_check {
#     protocol            = "TCP"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }

#   tags = {
#     Name = "udp-tg"
#   }
# }

resource "aws_lb_target_group" "tcp_tg_8080" {
  name        = "tcp-tg-8080"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = aws_vpc.producer_vpc.id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "tcp-tg-8080"
  }
}

resource "aws_lb_target_group" "tcp_tg_53" {
  name        = "tcp-tg-53"
  port        = 53
  protocol    = "TCP"
  vpc_id      = aws_vpc.producer_vpc.id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "tcp-tg-53"
  }
}

resource "aws_lb_target_group" "tcp_tg_22" {
  name        = "tcp-tg-22"
  port        = 22
  protocol    = "TCP"
  vpc_id      = aws_vpc.producer_vpc.id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "tcp-tg-22"
  }
}

# resource "aws_lb_listener" "udp_listener" {
#   load_balancer_arn = aws_lb.udp_nlb.arn
#   port              = 53
#   protocol          = "UDP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.udp_tg.arn
#   }

#   tags = {
#     Name = "udp-listener"
#   }
# }

resource "aws_lb_listener" "tcp_80_listener" {
  load_balancer_arn = aws_lb.multi_tcp_nlb.arn
  port              = 8080
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tcp_tg_8080.arn
  }

  tags = {
    Name = "tcp-listener-8080"
  }
}

resource "aws_lb_listener" "tcp_53_listener" {
  load_balancer_arn = aws_lb.multi_tcp_nlb.arn
  port              = 53
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tcp_tg_53.arn
  }

  tags = {
    Name = "tcp-listener-53"
  }
}

resource "aws_lb_listener" "tcp_22_listener" {
  load_balancer_arn = aws_lb.multi_tcp_nlb.arn
  port              = 22
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tcp_tg_22.arn
  }

  tags = {
    Name = "tcp-listener-22"
  }
}


# resource "aws_lb_target_group_attachment" "udp_target_group_attachment" {
#   target_group_arn = aws_lb_target_group.udp_tg.arn
#   target_id        = aws_instance.producer_ec2.id
#   port             = 53
# }


resource "aws_lb_target_group_attachment" "tcp_8080_target_group_attachment" {
  target_group_arn = aws_lb_target_group.tcp_tg_8080.arn
  target_id        = aws_instance.producer_ec2.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "tcp_53_target_group_attachment" {
  target_group_arn = aws_lb_target_group.tcp_tg_53.arn
  target_id        = aws_instance.producer_ec2.id
  port             = 53
}

resource "aws_lb_target_group_attachment" "tcp_22_target_group_attachment" {
  target_group_arn = aws_lb_target_group.tcp_tg_22.arn
  target_id        = aws_instance.producer_ec2.id
  port             = 22
}
