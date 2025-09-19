# main.tf

# 1. Provider configuration (AWS in this case)
provider "aws" {
  region = "us-east-1"   # Change to your preferred region
}

# 2. Create a VPC (optional but common)
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# 3. Create a subnet
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# 4. Create a security group
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "allow_ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Allow SSH from anywhere (be careful in real use!)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Launch EC2 instance
resource "aws_instance" "my_ec2" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 in us-east-1 (update for your region)
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "MyFirstEC2"
  }
}


