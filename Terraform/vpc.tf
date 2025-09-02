resource "aws_vpc" "vpcdemo" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpcdemo"
  }
}

resource "aws_subnet" "pubsubnet" {
  vpc_id     = aws_vpc.vpcdemo.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "publicsubnet"
  }
}

resource "aws_subnet" "prvsubnet" {
  vpc_id     = aws_vpc.vpcdemo.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "privatesubnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpcdemo.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "my_elastic_ip" {
    vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.my_elastic_ip.id
  subnet_id     = aws_subnet.pubsubnet.id

  tags = {
    Name = "NAT gw"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "pub_route_table" {
  vpc_id = aws_vpc.vpcdemo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public route table"
  }
}


resource "aws_route_table_association" "associate_with_subnet" {
  subnet_id      = aws_subnet.pubsubnet.id
  route_table_id = aws_route_table.pub_route_table.id
}

resource "aws_route_table" "priv_route_table" {
  vpc_id = aws_vpc.vpcdemo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private route table"
  }
}


resource "aws_route_table_association" "associate_with_subnet" {
  subnet_id      = aws_subnet.prvsubnet.id
  route_table_id = aws_route_table.priv_route_table.id
}
