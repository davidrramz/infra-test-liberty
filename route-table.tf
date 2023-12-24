resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = join("-", [local.solution_name, "public-rt"])
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.web-subnet.id
  route_table_id = aws_route_table.public.id
}