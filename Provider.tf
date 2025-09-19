provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "VPC_NAME" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = {
    name = "My_vpc"
  }
}


resource "aws_internet_gateway" "Gatway" {
  vpc_id = aws_vpc.VPC_NAME.id

  tags = {
    name="Phblic_gate_way"
  }
}


resource "aws_subnet" "publicn_subnet" {
    vpc_id = aws_vpc.VPC_NAME
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = "true"

    tags = {
      name="Public_subnet"
    }
}

resource "aws_route_table" "route_table_name" {
  vpc_id = aws_vpc.VPC_NAME.id

  tags = {
    name ="route_table"
  }
}

resource "aws_route" "route_name" {
  route_table_id = aws_route_table.route_table_name.id
  destination_cidr_block="0.0.0.0/0"
  gateway_id = aws_internet_gateway.Gatway.id
}

resource "aws_route_table_association" "assication_name" {
  route_table_id = aws_route_table.route_table_name.id
  subnet_id = aws_subnet.publicn_subnet.id
}


resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.VPC_NAME.id
  name = "security_name"

  ingress  {
        from_port = 22
        to_port =22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

  }

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AllowSSH-HTTP"
  }
}


resource "aws_instance" "instance_name" {
  ami = ""
  instance_type = "t2mirco"
  availability_zone = "us-east-1a"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.publicn_subnet.id

  
}