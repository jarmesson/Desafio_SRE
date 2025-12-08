# SECURITY GROUP — ALB PÚBLICA (FRONTEND)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "SG ALB pública"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SECURITY GROUP — EC2 FRONTEND
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "SG para instâncias frontend"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow HTTP from ALB public"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SECURITY GROUP — ALB BACKEND
resource "aws_security_group" "alb_internal_sg" {
  name        = "alb-internal-sg"
  description = "SG para ALB interna (backend)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow HTTP from frontend EC2"
    from_port       = 8080  
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SECURITY GROUP — EC2 BACKEND 
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "SG para instâncias backend"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow backend traffic only from internal ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_internal_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SECURITY GROUP — RDS 
resource "aws_security_group" "db_sg" {
  name        = "rds-sg"
  description = "SG para RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow PostgreSQL only from backend ASG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
