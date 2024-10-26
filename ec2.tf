resource "aws_instance" "consumer_ec2" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.consumer_vm_subnet.id
  security_groups = [aws_security_group.consumer_ec2_sg.id]

  tags = {
    Name = "consumer-ec2-instance"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
    http_protocol_ipv6          = "disabled"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = templatefile("scripts/consumer_ec2.sh", {
    consumer_script = file("${path.module}/scripts/aws_privatelink_protocol_tester.py")
    public_key      = var.PUBLIC_KEY
  })
}


resource "aws_instance" "producer_ec2" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.producer_vm_subnet.id
  security_groups = [aws_security_group.producer_ec2_sg.id]

  tags = {
    Name = "producer-ec2-instance"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
    http_protocol_ipv6          = "disabled"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = templatefile("scripts/producer_ec2.sh", {
    producer_script = file("${path.module}/scripts/tcp_udp_services.py")
    public_key      = var.PUBLIC_KEY
  })
}

## ELASTIC IP
resource "aws_eip" "consumer_ec2_eip" {
  instance = aws_instance.consumer_ec2.id
  domain   = "vpc"
}

resource "aws_eip" "producer_ec2_eip" {
  instance = aws_instance.producer_ec2.id
  domain   = "vpc"
}


output "consumer_ec2_public_ip" {
  value = aws_eip.consumer_ec2_eip.public_ip
}

output "producer_ec2_public_ip" {
  value = aws_eip.producer_ec2_eip.public_ip
}
