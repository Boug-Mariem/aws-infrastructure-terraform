resource "aws_db_instance" "mysql" {
  identifier             = "mydb"
  engine                 = "mysql"  #moteur
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}