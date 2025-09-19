# main.tf

# -----------------------------------------------------------
# 1. Provider
# -----------------------------------------------------------
provider "aws" {
  region = "us-east-1"   # Change to your region
}

# -----------------------------------------------------------
# 2. VPC
# -----------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

# -----------------------------------------------------------
# 3. Internet Gateway (for internet access)
# -----------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MyInternetGateway"
  }
}

# -----------------------------------------------------------
# 4. Public Subnet
# -----------------------------------------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "PublicSubnet"
  }
}

# -----------------------------------------------------------
# 5. Route Table
# -----------------------------------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "PublicRouteTable"
  }
}

# -----------------------------------------------------------
# 6. Route for Internet
# -----------------------------------------------------------
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# -----------------------------------------------------------
# 7. Subnet Association (connect subnet with route table)
# -----------------------------------------------------------
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# -----------------------------------------------------------
# 8. Security Group
# -----------------------------------------------------------
resource "aws_security_group" "allow_ssh_http" {
  vpc_id = aws_vpc.main.id
  name   = "allow-ssh-http"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
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

# -----------------------------------------------------------
# 9. EC2 Instance
# -----------------------------------------------------------
resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "MyWebServer"
  }
}
