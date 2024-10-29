###  TEST SECURITY GROUPS

resource "aws_security_group" "consumer_ec2_sg" {
  name        = "consumer-ec2-sg"
  description = "Allow traffic to/from ec2"
  vpc_id      = aws_vpc.consumer_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.SOURCE_SSH_NET]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "consumer-ec2-sg"
  }
}

resource "aws_security_group" "producer_ec2_sg" {
  name        = "producer-ec2-sg"
  description = "Allow traffic to/from ec2"
  vpc_id      = aws_vpc.producer_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.SOURCE_SSH_NET]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [aws_vpc.producer_vpc.cidr_block]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.producer_vpc.cidr_block]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.producer_vpc.cidr_block]
  }

  ingress {
    from_port   = 8080
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.producer_vpc.cidr_block]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "producer-ec2-sg"
  }
}


resource "aws_security_group" "producer_nlb_sg" {
  name        = "producer-nlb-sg"
  description = "Allow traffic to/from nlb"
  vpc_id      = aws_vpc.producer_vpc.id

  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "udp"
    cidr_blocks = [
      aws_vpc.producer_vpc.cidr_block,
      aws_vpc.consumer_vpc.cidr_block
    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      aws_vpc.producer_vpc.cidr_block,
      aws_vpc.consumer_vpc.cidr_block
    ]
  }

  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "tcp"
    cidr_blocks = [
      aws_vpc.producer_vpc.cidr_block,
      aws_vpc.consumer_vpc.cidr_block
    ]
  }

  ingress {
    from_port = 8080
    to_port   = 8082
    protocol  = "tcp"
    cidr_blocks = [
      aws_vpc.producer_vpc.cidr_block,
      aws_vpc.consumer_vpc.cidr_block
    ]
  }

  egress {
    from_port = 8080
    to_port   = 8082
    protocol  = "tcp"
    cidr_blocks = [
      aws_vpc.producer_vpc.cidr_block,
      aws_vpc.consumer_vpc.cidr_block
    ]
  }

  egress {
    from_port = 53
    to_port   = 53
    protocol  = "udp"
    cidr_blocks = [
      aws_vpc.producer_vpc.cidr_block,
      aws_vpc.consumer_vpc.cidr_block
    ]
  }

  egress {
    from_port = 53
    to_port   = 53
    protocol  = "tcp"
    cidr_blocks = [
      aws_vpc.producer_vpc.cidr_block,
      aws_vpc.consumer_vpc.cidr_block
    ]
  }

  egress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      aws_vpc.producer_vpc.cidr_block,
      aws_vpc.consumer_vpc.cidr_block
    ]
  }

  tags = {
    Name = "producer-nlb-sg"
  }

}



resource "aws_security_group" "consumer_privatelink_sg" {
  name        = "consumer-privatelink-sg"
  description = "Allow traffic to/from privatelink endpoint"
  vpc_id      = aws_vpc.consumer_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.consumer_vpc.cidr_block]
  }

  tags = {
    Name = "consumer-privatelink-sg"
  }
}


# No Default Allow on default sg
resource "aws_default_security_group" "consumer_sg_default" {
  vpc_id = aws_vpc.consumer_vpc.id
}

resource "aws_default_security_group" "producer_sg_default" {
  vpc_id = aws_vpc.producer_vpc.id
}