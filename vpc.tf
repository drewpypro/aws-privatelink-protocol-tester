provider "aws" {
  region = "us-west-2"
}


# VPCs Definition
resource "aws_vpc" "producer_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "producer-vpc"
  }
}

resource "aws_vpc" "consumer_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "consumer-vpc"
  }
}


# Subnets
resource "aws_subnet" "producer_vm_subnet" {
  vpc_id                  = aws_vpc.producer_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "producer-vm-subnet"
  }
}

# Subnets
resource "aws_subnet" "producer_nlb_subnet" {
  vpc_id                  = aws_vpc.producer_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "producer-nlb-subnet"
  }
}

resource "aws_subnet" "consumer_vm_subnet" {
  vpc_id                  = aws_vpc.consumer_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "consumer-vm-subnet"
  }
}

resource "aws_subnet" "consumer_endpoint_subnet" {
  vpc_id                  = aws_vpc.consumer_vpc.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "consumer-endpoint-subnet"
  }
}


# IGWs Definition
resource "aws_internet_gateway" "producer_igw" {
  vpc_id = aws_vpc.producer_vpc.id
  tags = {
    Name = "producer-igw"
  }
}

resource "aws_internet_gateway" "consumer_igw" {
  vpc_id = aws_vpc.consumer_vpc.id
  tags = {
    Name = "consumer-igw"
  }
}


resource "aws_route_table" "producer_rt_1" {
  vpc_id = aws_vpc.producer_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.producer_igw.id
  }

  tags = {
    Name = "producer-route-table-1"
  }
}

resource "aws_route_table" "consumer_rt_1" {
  vpc_id = aws_vpc.consumer_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.consumer_igw.id
  }

  tags = {
    Name = "consumer-route-table-1"
  }
}


resource "aws_route_table_association" "producer_rta_1" {
  subnet_id      = aws_subnet.producer_vm_subnet.id
  route_table_id = aws_route_table.producer_rt_1.id
}

resource "aws_route_table_association" "producer_rta_2" {
  subnet_id      = aws_subnet.producer_nlb_subnet.id
  route_table_id = aws_route_table.producer_rt_1.id
}

resource "aws_route_table_association" "consumer_rta_1" {
  subnet_id      = aws_subnet.consumer_vm_subnet.id
  route_table_id = aws_route_table.consumer_rt_1.id
}

resource "aws_route_table_association" "consumer_rta_2" {
  subnet_id      = aws_subnet.consumer_endpoint_subnet.id
  route_table_id = aws_route_table.consumer_rt_1.id
}


resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name              = "/aws/vpc/test-flow-logs"
  retention_in_days = 1
}

resource "aws_flow_log" "consumer_vpc_flow_log" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
  vpc_id               = aws_vpc.consumer_vpc.id
  traffic_type         = "ALL"
}

resource "aws_flow_log" "producer_vpc_flow_log" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
  vpc_id               = aws_vpc.producer_vpc.id
  traffic_type         = "ALL"
}
