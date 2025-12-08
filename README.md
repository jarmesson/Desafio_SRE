# Desafio SRE

Este projeto provisiona uma infraestrutura completa na AWS. No desafio foram implementadas as seguintes configurações:

- EC2
- VPC com subnets públicas e privadas  
- NAT Gateway, Internet Gateway e tabelas de rota  
- ALB (Application Load Balancer) público para o frontend  
- ALB interno para o backend  
- Auto Scaling Group com EC2 rodando Nginx (Frontend)
- Auto Scaling Group com EC2 rodando Python HTTP Server na porta 8080 (Backend)
- RDS PostgreSQL Multi-AZ  
- Security Groups controlando comunicação entre camadas  

---


## Função de cada arquivo `.tf`

### **vpc.tf**
Responsável pela rede:
- Cria a VPC  
- Subnets públicas e privadas  
- Internet Gateway  
- NAT Gateway  
- Route Tables e associações  

---

### **frontend_asg.tf**
Responsável pela camada de aplicação (Frontend):
- Launch Template (EC2 com Nginx instalado via *user_data*)  
- Auto Scaling Group do frontend (subnets públicas)  
- Application Load Balancer público  
- Target Group e Listener na porta 80  
- Auto Scaling baseado em RequestCount  
- Alarmes CloudWatch para Auto Scaling  
- Página HTML gerada via script de inicialização  

---

### **backend_asg.tf**
Responsável pela camada backend:
- Launch Template rodando servidor Python com python3 -m http.server 8080  
- ALB interno para comunicação interna  
- Target Group na porta 8080 com health check configurado  
- Listener direcionando tráfego para o backend  
- Auto Scaling Group em subnets privadas  
- Políticas de Auto Scaling configuradas com alarmes de alta e baixa requisição  
- Backend só recebe tráfego do ALB interno para isolamento de rede  

---

### **rds.tf**
Responsável pelo banco de dados:
- Subnet Group do RDS   
- Instância RDS PostgreSQL Multi-AZ  
- Acesso permitido apenas ao Security Group do backend  
- Banco não é acessível publicamente  
- Senha do banco salva no AWS Secrets Manager para maior segurança

---

### **security_groups.tf**
Responsável pela segurança:
- SG do ALB público   
- SG do frontend: recebe tráfego do ALB público  
- SG do ALB interno: recebe somente tráfego vindo do frontend  
- SG do backend: recebe somente tráfego do ALB interno (porta 8080)  
- SG do RDS: permite tráfego apenas do backend (porta 5432)  

---

### **variables.tf**
Centraliza variáveis:
- Region  
- CIDRs  
- Subnets públicas e privadas  
- Tipos de instância  
- Parâmetros de Auto Scaling  
- Credenciais do RDS  

---

### **outputs.tf**
Exibe informações após o deploy:
- DNS do ALB público  
- DNS do ALB interno (backend)  
- Endpoint do RDS  

---

### **provider.tf**
Responsável por:
- Configurar o provedor AWS  
- Definir a região  
- Utilização do provider hashicorp/aws  

---

### **versions.tf**
Responsável por:
- Travar as versões mínimas do Terraform e do provider AWS  
- Garantir compatibilidade e reprodutibilidade  

---

## Fluxograma

Usuário → ALB (frontend) → Frontend
 → ALB (backend) → Backend 
 → RDS

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


