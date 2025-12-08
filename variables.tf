variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "desafio-sre"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDRs das subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "CIDRs das subnets privadas"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "instance_type_frontend" {
  default     = "t3.micro"
}

variable "instance_type_backend" {
  default     = "t3.micro"
}

variable "desired_capacity_frontend" {
  default = 2
}

variable "frontend_min_size" {
  default = 1
}

variable "frontend_max_size" {
  default = 4
}

variable "desired_capacity_backend" {
  default = 2
}

variable "backend_min_size" {
  default = 1
}

variable "backend_max_size" {
  default = 3
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  description = "Senha do PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  default = 20
}

variable "ssh_public_key_path" {
  default     = ""
}
