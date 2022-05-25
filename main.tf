# local values used multiple times

locals {
  common_tags = {
    Name  = "NewVPC"
    Owner = "Me"
  }
}

# vpc creation

resource "aws_vpc" "new_vpc" {
  cidr_block       = var.vpc_block
  instance_tenancy = "default"

  tags = local.common_tags
}

# Internet gateway

resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.new_vpc.id
  tags   = local.common_tags
}

# Route table (don't use vpc default routes ) 

resource "aws_route_table" "my_public_route" {
  vpc_id = aws_vpc.new_vpc.id

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.my_gateway.id
  }

  tags = local.common_tags
}

resource "aws_route_table" "my_private_route" {
  vpc_id = aws_vpc.new_vpc.id

  route {
    cidr_block     = var.cidr_block
    nat_gateway_id = aws_nat_gateway.my_nat.id
  }

  tags = local.common_tags
}

# Subnet creation

resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.new_vpc.id
  cidr_block              = var.public_block
  availability_zone       = var.avail_zone
  map_public_ip_on_launch = true
  tags                    = local.common_tags
  depends_on              = [aws_internet_gateway.my_gateway]
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id                  = aws_vpc.new_vpc.id
  cidr_block              = var.private_block
  availability_zone       = var.avail_zone
  map_public_ip_on_launch = true
  tags                    = local.common_tags
  depends_on              = [aws_nat_gateway.my_nat]
}

# Route table association (route table with subnet)

resource "aws_route_table_association" "my_public_table_association" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_public_route.id
}

resource "aws_route_table_association" "my_pivate_table_association" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_route.id
}

# Nat gateway

resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.my_elastic_nat_ip.id
  subnet_id     = aws_subnet.my_public_subnet.id
  tags          = local.common_tags
  depends_on    = [aws_internet_gateway.my_gateway]
}

# Ec2 creation

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_owner] # Use aws cli to get this
}

resource "aws_instance" "my_public_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.inst_type
  availability_zone      = var.avail_zone
  subnet_id              = aws_subnet.my_public_subnet.id
  key_name               = "my_terraform"
  tags                   = local.common_tags
  vpc_security_group_ids = [aws_security_group.my_public_security_group.id]
}

# Elastic Ip for NAT and public Ec2

resource "aws_eip" "my_elastic_ip" {
  instance   = aws_instance.my_public_instance.id
  tags       = local.common_tags
  vpc        = true
  depends_on = [aws_internet_gateway.my_gateway]
}

resource "aws_eip" "my_elastic_nat_ip" {
  tags       = local.common_tags
  vpc        = true
  depends_on = [aws_internet_gateway.my_gateway]
}
resource "aws_instance" "my_private_instance" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.inst_type
  availability_zone = var.avail_zone
  subnet_id         = aws_subnet.my_private_subnet.id

  key_name               = "my_terraform"
  tags                   = local.common_tags
  vpc_security_group_ids = [aws_security_group.my_public_security_group.id]
  depends_on             = [aws_subnet.my_private_subnet]
}

#Security Group

resource "aws_security_group" "my_public_security_group" {
  name        = "my_vpc"
  description = "Allow http and ssh inbound traffic"
  vpc_id      = aws_vpc.new_vpc.id

  dynamic "ingress" {
    for_each = var.service_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]
    }
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]

  }


  tags = local.common_tags
}



