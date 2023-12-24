resource "aws_subnet" "web-subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.web_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = join("-", [local.solution_name, "web"])
  }
}