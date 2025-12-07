# Desafio SRE

Este projeto provisiona uma infraestrutura completa na AWS. No desafio foram implementadas as seguintes configurações:

- VPC com subnets públicas e privadas  
- NAT Gateway, Internet Gateway e tabelas de rota  
- ALB (Application Load Balancer)  
- Auto Scaling Group com EC2 rodando Nginx  
- RDS PostgreSQL Multi-AZ  
- Security Groups 

---

## 📄 O que cada arquivo `.tf` faz

### **vpc.tf**
Responsável pela rede:
- Cria a VPC  
- Subnets públicas e privadas  
- Internet Gateway  
- NAT Gateway  
- Route Tables e associações  

---

### **alb.tf**
Responsável pela camada de aplicação:
- Launch Template (instância EC2 com Nginx com *user_data*)  
- Auto Scaling Group  
- Application Load Balancer  
- Target Group + Listener  
- Auto Scaling baseadas na quantidade de requisições 
- Alarme CloudWatch  

---

### **rds.tf**
Responsável pelo banco de dados:
- Subnet Group do RDS (subnets privadas)  
- Instância RDS PostgreSQL Multi-AZ  
 
---

### **security_groups.tf**
Responsável pela segurança:
- SG do ALB (entrada HTTP pública)  
- SG da aplicação (recebe apenas do ALB)  
- SG do RDS (aceita somente da aplicação)  

---

### **variables.tf**
Centraliza variáveis:
- Region  
- CIDRs  
- Lista de subnets  
- Tipos de instância    

---

### **outputs.tf**
Exibe informações após o deploy:
- DNS do ALB  
- Endpoint do RDS  
- Nome do Auto Scaling Group  

---

## Como executar

1. Inicializar:
```bash
terraform init
```

2. Validar:
```bash
terraform validate
```

3. Ver o plan:
```bash
terraform plan -var 'db_password=CHANGEME' -out=tfplan
```

4. Aplicar:
```bash
terraform apply -auto-approve
```

## Acessar o ambiente

1. Após o `terraform apply`, pegue o output `alb_dns`:
```bash
terraform output alb_dns
```

2. Abra no navegador:
```
http://<alb_dns>
```


