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
    default = ["10.0.1.0/24","10.0.2.0/24"] 
    }

variable "private_subnets" { 
    default = ["10.0.11.0/24","10.0.12.0/24"] 
    }

variable "instance_type_frontend" { 
    default = "t3.micro" 
    }

variable "instance_type_backend" { 
    default = "t3.micro" 
    }

variable "desired_capacity_frontend" { 
    default = 2 
    }

variable "desired_capacity_backend" { 
    default = 2 
    }

variable "db_allocated_storage" { 
    default = 20 
    }

variable "db_instance_class" { 
    default = "db.t3.micro" 
    }

variable "db_username" { 
    default = "admin" 
    }

variable "db_password" { 
    sensitive = true 
    }

variable "ssh_public_key_path" { 
    default = "" 
    }
