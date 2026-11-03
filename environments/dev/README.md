# Ambiente `dev`

Ambiente de desenvolvimento. Ele **usa** os módulos de [`modules/`](../../modules) e define *quais* recursos existem aqui e *com quais valores*. Tem state próprio no Blob Storage criado pelo [bootstrap](../../bootstrap/readmebootstrap.md).

## O que este ambiente cria

| Recurso | Nome | Origem |
| --- | --- | --- |
| Resource Group | `rg-<workload>-<environment>`, ou seja, `rg-portfolio-dev` | módulo [`resource-group`](../../modules/resource-group) |

## Arquivos

| Arquivo | Função | Versionado |
| --- | --- | --- |
| `backend.tf` | State remoto, com `key = dev/terraform.tfstate` | Sim |
| `versions.tf` | Versões do Terraform e do provider, e configuração do provider | Sim |
| `variables.tf` | Variáveis de entrada | Sim |
| `main.tf` | Chamada dos módulos e tags | Sim |
| `outputs.tf` | Saídas do ambiente | Sim |
| `terraform.tfvars.example` | Modelo de valores (fictícios) | Sim |
| `terraform.tfvars` | Valores reais, como o `subscription_id` | **Não** (ignorado pelo git) |
| `.terraform.lock.hcl` | Versões exatas dos providers | Sim |
| `.terraform/` | Cache local do Terraform | **Não** |

## State

O state deste ambiente fica no mesmo container do bootstrap, em um blob próprio:

```text
Container tfstate
├── bootstrap/terraform.tfstate
└── dev/terraform.tfstate   ← este ambiente
```

O `backend.tf` só define a `key`. O Resource Group, a Storage Account e o container são informados no `init`, para não deixar nomes reais no repositório. A autenticação usa Entra ID, então o seu usuário precisa da role **Storage Blob Data Contributor** na Storage Account.

## Como usar

Dentro de `environments/dev`:

1. Crie o `terraform.tfvars` a partir do exemplo e preencha o `subscription_id`:

   ```powershell
   Copy-Item terraform.tfvars.example terraform.tfvars
   ```

2. Inicialize o backend com os dados do bootstrap:

   ```powershell
   terraform init `
     -backend-config="resource_group_name=<rg-do-bootstrap>" `
     -backend-config="storage_account_name=<storage-account>" `
     -backend-config="container_name=tfstate"
   ```

3. Veja o que será criado e aplique:

   ```powershell
   terraform plan
   terraform apply
   ```

4. Confira no portal o Resource Group `rg-portfolio-dev` e o blob `dev/terraform.tfstate` dentro do container `tfstate`.

## Cuidados

- Nunca versione `terraform.tfvars` nem arquivos de state.
- Não rode `terraform destroy` sem revisar o `plan`.
- Cada ambiente tem seu state. Mudanças aqui não afetam o `prod`.
