data "aws_caller_identity" "account" {
}

# resource "aws_vpc_endpoint_service" "producer_udp_privatelink_service" {
#   acceptance_required        = false
#   network_load_balancer_arns = [aws_lb.udp_nlb.arn]
#   allowed_principals         = ["arn:aws:iam::${data.aws_caller_identity.account.account_id}:root"]

#   tags = {
#     Name = "producer-udp-privatelink-service"
#   }
# }

resource "aws_vpc_endpoint_service" "producer_tcp_privatelink_service" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.tcp_nlb.arn]
  allowed_principals         = ["arn:aws:iam::${data.aws_caller_identity.account.account_id}:root"]

  tags = {
    Name = "producer-tcp-privatelink-service"
  }
}

# resource "aws_vpc_endpoint" "consumer_udp_privatelink_endpoint" {
#   vpc_id                = aws_vpc.consumer_vpc.id
#   service_name          = aws_vpc_endpoint_service.producer_udp_privatelink_service.service_name
#   vpc_endpoint_type     = "Interface"
#   security_group_ids    = [aws_security_group.consumer_privatelink_sg.id]

#   subnet_configuration {
#     ipv4      = "10.1.2.169"
#     subnet_id = aws_subnet.consumer_endpoint_subnet.id
#   }

#   tags = {
#     Name = "consumer-udp-privatelink-endpoint"
#   }

#   depends_on = [
#     aws_vpc_endpoint_service.producer_udp_privatelink_service
#   ]
# }

resource "aws_vpc_endpoint" "consumer_tcp_privatelink_endpoint" {
  vpc_id                = aws_vpc.consumer_vpc.id
  service_name          = aws_vpc_endpoint_service.producer_tcp_privatelink_service.service_name
  vpc_endpoint_type     = "Interface"
  security_group_ids    = [aws_security_group.consumer_privatelink_sg.id]
  
  subnet_configuration {
    ipv4      = "10.1.2.69"
    subnet_id = aws_subnet.consumer_endpoint_subnet.id
  }

  tags = {
    Name = "consumer-tcp-privatelink-endpoint"
  }

  depends_on = [
    aws_vpc_endpoint_service.producer_tcp_privatelink_service,
    aws_subnet.consumer_endpoint_subnet
  ]

}
