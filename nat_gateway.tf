# parce que nat necessite une adress ip public permanente 
resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id #ID de l’Elastic IP statique 
  subnet_id     = aws_subnet.public_a.id
  tags          = { Name = "nat-gateway" }
}