# Create custom VPC
resource "aws_vpc" "MTVPC" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "MTVPC"
  }
}

# Create Public Subnet
resource "aws_subnet" "Public-Subnet" {
  vpc_id            = aws_vpc.MTVPC.id
  cidr_block        = var.public_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "Public-Subnet"
  }

}
# Create Private Subnet
resource "aws_subnet" "Private-Subnet" {
  vpc_id            = aws_vpc.MTVPC.id
  cidr_block        = var.private_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = "Private-Subnet"
  }

}
# Create internet Gateway
resource "aws_internet_gateway" "MTIGW" {
  vpc_id = aws_vpc.MTVPC.id

  tags = {
    Name = "MTIGW"
  }
}

# Create Public Route Table 
resource "aws_route_table" "Public_Route_Table" {
  vpc_id = aws_vpc.MTVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MTIGW.id
  }
  tags = {
    Name = "Public_Route_Table"
  }
}

# Create Public Route Table association
resource "aws_route_table_association" "Public" {
  subnet_id      = aws_subnet.Public-Subnet.id
  route_table_id = aws_route_table.Public_Route_Table.id
}

# Create Private Route Table
resource "aws_route_table" "Private_Route_Table" {
  vpc_id = aws_vpc.MTVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.MT-nat.id
  }
  tags = {
    Name = "Private_Route_Table"
  }
}

# Create Private Route Table association
resource "aws_route_table_association" "Private" {
  subnet_id      = aws_subnet.Private-Subnet.id
  route_table_id = aws_route_table.Private_Route_Table.id
}

# Create Elastic IP
resource "aws_eip" "MTVPC-eip" {
  domain = "vpc"
}

# Create NAT gateway
resource "aws_nat_gateway" "MT-nat" {
  allocation_id = aws_eip.MTVPC-eip.id
  subnet_id     = aws_subnet.Public-Subnet.id

  tags = {
    Name = "MT-nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.MTIGW]
}

# Create Public Security Group
resource "aws_security_group" "Public-sg" {
  name        = "Public-sg"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.MTVPC.id

  tags = {
    Name = "Public=sg"
  }
}

# Create security group rule in Public
resource "aws_vpc_security_group_ingress_rule" "allow-HTTP" {
  security_group_id = aws_security_group.Public-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTPS" {
  security_group_id = aws_security_group.Public-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_SSH" {
  security_group_id = aws_security_group.Public-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.Public-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.Public-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Create security group in Private subnet
resource "aws_security_group" "Private-sg" {
  name        = "Private-sg"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.MTVPC.id

  tags = {
    Name = "Private=sg"
  }
}

# Create ingress rule in Private subnet
resource "aws_vpc_security_group_ingress_rule" "allow-MySQL" {
  security_group_id = aws_security_group.Private-sg.id
  cidr_ipv4         = var.public_cidr_block
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_ingress_rule" "allow-SSH" {
  security_group_id = aws_security_group.Private-sg.id
  cidr_ipv4         = var.public_cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic-ipv4" {
  security_group_id = aws_security_group.Private-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic-ipv6" {
  security_group_id = aws_security_group.Private-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Create Network ACL for public subnet
resource "aws_network_acl" "public-nacl" {
  vpc_id = aws_vpc.MTVPC.id

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "public-nacl"
  }
}
# Create Network ACL for public subnet
resource "aws_network_acl" "private-nacl" {
  vpc_id = aws_vpc.MTVPC.id


  egress {
    protocol   = -1
    rule_no    = 200
    action     = "allow"
    cidr_block = var.public_cidr_block
    from_port  = 0
    to_port    = 0

  }
  
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.public_cidr_block
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "private-nacl"
  }
}
# Create public instance 
resource "aws_instance" "webserver" {
  ami                         = var.aws_ami
  instance_type               = var.instance
  key_name                    = "mt-key-pair"
  subnet_id                   = aws_subnet.Public-Subnet.id
  availability_zone           = var.availability_zone
  vpc_security_group_ids      = [aws_security_group.Public-sg.id]
  associate_public_ip_address = "true"
  user_data                   = file("${path.module}/Scripts/install-nginx.sh")
  tags = {
    Name = "webserver"
  }
}
# Create private instance 
resource "aws_instance" "db-server" {
  ami                         = var.aws_ami
  instance_type               = var.instance
  key_name                    = "mt-key-pair" 
  subnet_id                   = aws_subnet.Private-Subnet.id
  availability_zone           = var.availability_zone
  vpc_security_group_ids      = [aws_security_group.Private-sg.id]
  associate_public_ip_address = "false"
  user_data                   = file("${path.module}/Scripts/install-mysql.sh")


  tags = {
    Name = "db-server"
  }
}

# Create key pair
resource "aws_key_pair" "mt-key-pair" {
  key_name   = "mt-key-pair"
  public_key = var.public_key_path
}