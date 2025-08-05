# 🔐 Lambda Token Generator (AWS + Terraform)

Este projeto cria uma arquitetura completa na AWS utilizando **Terraform**, onde:

- Uma função **Lambda em Python** gera um token UUID com validade.
- O token é salvo em uma **tabela DynamoDB** com TTL automático.
- O token gerado é enviado por **e-mail via SNS**.
- Uma **regra EventBridge** agenda a execução automática todos os dias às 18h (UTC).
- As configurações são passadas como **variáveis de ambiente**, tornando o código desacoplado e reutilizável.

---

## 📁 Estrutura do Projeto

```
lambda-token/
│
├── lambda/
│   ├── app.py              # Código da função Lambda
│   └── requirements.txt    # (opcional)
│
├── main.tf                 # Recursos principais: Lambda, DynamoDB, IAM, SNS, EventBridge
├── variables.tf            # Variáveis reutilizáveis (ex: região)
├── outputs.tf              # Saídas úteis do Terraform
└── README.md               # Este arquivo
```

---

## ⚙️ Pré-requisitos

- [AWS CLI configurado](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- [Terraform instalado](https://developer.hashicorp.com/terraform/downloads)
- Permissões IAM adequadas (Lambda, DynamoDB, SNS, EventBridge)

---

## 🚀 Instruções para Deploy

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/seu-usuario/lambda-token-generator.git
   cd lambda-token-generator
   ```

2. **Edite seu e-mail no `main.tf`**:
   ```hcl
   endpoint = "seu-email@example.com"
   ```

3. **Inicialize o Terraform**:
   ```bash
   terraform init
   ```

4. **Aplique a infraestrutura**:
   ```bash
   terraform apply
   ```

5. **⚠️ Confirme o e-mail**:
   - Verifique sua caixa de entrada e **confirme a assinatura SNS** clicando no link.

---

## 🐍 Código Lambda - `lambda/app.py`

A função Lambda:

- Gera um UUID
- Calcula validade de 1 hora
- Salva no DynamoDB
- Publica notificação no SNS


---

## 🌍 Variáveis de Ambiente da Lambda

Passadas automaticamente pelo Terraform:

| Variável         | Descrição                        |
|------------------|----------------------------------|
| `AWS_REGION`     | Região da AWS                    |
| `DDB_TABLE_NAME` | Nome da tabela DynamoDB         |
| `SNS_TOPIC_ARN`  | ARN do tópico SNS para notificar|

---

## 📅 Agendamento com EventBridge

A Lambda é executada automaticamente todos os dias às **18h UTC** (15h horário de Brasília) via:

```hcl
schedule_expression = "cron(0 18 * * ? *)"
```

Você pode alterar isso via a variável `var.schedule_expression`.

---

## 🧪 Testes Manuais

Para invocar manualmente a Lambda:

```bash
aws lambda invoke   --function-name generate_token   --payload '{}'   response.json

cat response.json
```

---

## 🧹 Destruir a Infraestrutura

```bash
terraform destroy
```

---

## 📌 Observações

- **Confirmação de e-mail SNS é obrigatória**, senão os e-mails não são enviados.
- O TTL do token no DynamoDB remove automaticamente o item após expiração.
- Você pode adaptar a lógica do token para JWT, OAuth, etc.

---

## 🧑‍💻 Autor

Antonio Jefferson Moreira Freitas  
[LinkedIn](https://www.linkedin.com/in/jefferson-freitas) | [Portfólio](https://portifolio.jeffersonfreitas.dev)

---

## 📄 Licença

MIT