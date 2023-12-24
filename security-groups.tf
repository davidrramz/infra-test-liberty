resource "aws_security_group" "web-sg" {
  name        = join("-", [local.solution_name, "web", "sg"])
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh from VPC"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    description = "Docker client communication"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
  }

  ingress {
    description = "This port is used for communication between the nodes of a Docker Swarm"
    cidr_blocks = [var.vpc_cidr]
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
  }

  ingress {
    description = "For container ingress networking"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
  }

  ingress {
    description = "For container network discovery"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
  }

  ingress {
    description = "For container network discovery"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
  }

  ingress {
    description = "Allow external web traffic"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = join("-", [local.solution_name, "web", "sg"])
  }
}