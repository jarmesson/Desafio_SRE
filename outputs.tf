output "alb_dns" {
  description = "DNS do ALB público (frontend)"
  value       = aws_lb.alb.dns_name
}

output "internal_alb_dns" {
  description = "DNS do ALB interno (backend)"
  value       = aws_lb.backend_alb.dns_name
}

output "db_endpoint" {
  description = "Endpoint do banco PostgreSQL (RDS)"
  value       = aws_db_instance.postgres.address
}
