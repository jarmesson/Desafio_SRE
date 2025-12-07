resource "aws_db_subnet_group" "db_subnet_group" {
  name="db-subnet-group"
  subnet_ids=aws_subnet.private[*].id
}
resource "aws_db_instance" "postgres" {
  allocated_storage=var.db_allocated_storage
  engine="postgres"
  instance_class=var.db_instance_class
  username=var.db_username
  password=var.db_password
  skip_final_snapshot=true
  multi_az=true
  publicly_accessible=false
  vpc_security_group_ids=[aws_security_group.db_sg.id]
  db_subnet_group_name=aws_db_subnet_group.db_subnet_group.name
}
