# Terraform State Bootstrap

Este diretório contém o **bootstrap** do repositório: a infraestrutura mínima compartilhada que guarda os states do Terraform no Azure.

> **Status:** concluído. Os recursos foram criados no Azure e o state do bootstrap foi migrado para o backend remoto, na chave `bootstrap/terraform.tfstate`.

## Por que existe um bootstrap?

O backend remoto precisa existir antes que o Terraform possa usá-lo, mas queremos que a criação dele também seja código. O bootstrap resolve essa dependência em duas fases:

1. **Criação:** o Terraform roda com state local e cria o Resource Group, a Storage Account e o container.
2. **Migração:** o state local é copiado para o container que acabou de ser criado.

Depois disso, o backend pode guardar também os states dos ambientes futuros, cada um com sua chave.

## Recursos criados

| Recurso | Finalidade |
| --- | --- |
| Resource Group `rg-tfstate-bootstrap-prod` | Isola os recursos compartilhados de state dos recursos dos ambientes. |
| Storage Account | Hospeda os blobs de state. O nome é único globalmente. |
| Container `tfstate` | Guarda os arquivos de state, com acesso privado. |

A região padrão é `brazilsouth` e a replicação padrão é `ZRS`. Ambas são ajustáveis por variável.

## Proteções configuradas

- **HTTPS obrigatório (`https_traffic_only_enabled`):** a Storage Account só aceita conexões HTTPS, que são criptografadas. Requisições em HTTP puro são recusadas, o que impede que o state trafegue em texto aberto pela rede.
- **TLS 1.2 mínimo (`min_tls_version`):** o TLS é o protocolo que criptografa a conexão HTTPS. Exigir a versão 1.2 recusa clientes que usam versões antigas (TLS 1.0 e 1.1), que têm vulnerabilidades conhecidas.
- **Sem acesso anônimo:** container privado e acesso público a blobs desabilitado.
- **Versionamento de blobs:** permite recuperar versões anteriores do state.
- **Retenção de exclusão por 30 dias** para blobs e containers.
- **Autenticação por Microsoft Entra ID:** `use_azuread_auth = true`, sem chave de acesso no código.
- **Locking do backend AzureRM:** evita atualizações simultâneas do mesmo state.
- **`prevent_destroy`** nos três recursos, contra exclusão acidental pelo Terraform.

Essas medidas não substituem RBAC de menor privilégio, backups e revisão de mudanças. `prevent_destroy` não impede exclusão manual no portal.

### Pontos de endurecimento futuros

- O endpoint da Storage Account é acessível pela rede pública. Restrições por IP ou rede privada podem ser adicionadas quando o local de execução do Terraform estiver definido.
- `default_to_oauth_authentication` favorece OAuth no portal, mas **não desabilita Shared Key**. Antes de desabilitá-la, valide que o provider cria e administra o container usando Entra ID.

## Arquivos

| Arquivo | Responsabilidade | Versionado |
| --- | --- | --- |
| `main.tf` | Resource Group, Storage Account e container. | Sim |
| `variables.tf` | Parâmetros, padrões e validações. | Sim |
| `outputs.tf` | Nomes dos recursos criados. | Sim |
| `versions.tf` | Versões do Terraform e do provider, e bloco do backend remoto. | Sim |
| `terraform.tfvars.example` | Exemplo de valores. | Sim |
| `.terraform.lock.hcl` | Versão fixada do provider. | Sim |
| `terraform.tfvars` | Seus valores reais (subscription e nome da Storage Account). | **Não** |
| `.terraform/` | Cache local e configuração do backend. | **Não** |

## Variáveis

| Variável | Obrigatória | Padrão | Observação |
| --- | --- | --- | --- |
| `subscription_id` | Sim | n/a | Subscription onde os recursos serão criados. |
| `location` | Não | `brazilsouth` | Região dos recursos. |
| `resource_group_name` | Não | `rg-tfstate-bootstrap-prod` | Resource Group dedicado ao backend. |
| `storage_account_name` | Sim | n/a | Único globalmente, de 3 a 24 caracteres, só minúsculas e números. |
| `container_name` | Não | `tfstate` | Container privado dos states. |
| `account_replication_type` | Não | `ZRS` | LRS, ZRS, GRS, RAGRS, GZRS ou RAGZRS. |

## Pré-requisitos

- Terraform `>= 1.5.0`.
- Azure CLI autenticado (`az login`) e uma subscription selecionada.
- Permissão para criar o Resource Group e a Storage Account.
- Papel **Storage Blob Data Contributor** na Storage Account, para ler e gravar o state via Entra ID.

Não coloque chaves, tokens ou segredos no código.

## Passo a passo (primeira execução)

Os comandos são em PowerShell, a partir da raiz do repositório.

### 1. Variáveis locais

```powershell
Copy-Item bootstrap\terraform.tfvars.example bootstrap\terraform.tfvars
```

Edite `bootstrap\terraform.tfvars` com o ID da subscription e um nome único de Storage Account. Esse arquivo é ignorado pelo Git.

### 2. Autenticar

```powershell
az login
az account set --subscription "<subscription-id>"
```

### 3. Criar os recursos com state local

No `versions.tf`, deixe o bloco `backend "azurerm"` **comentado** nesta fase, porque o armazenamento ainda não existe. Depois:

```powershell
Set-Location bootstrap
terraform init
terraform validate
terraform plan
terraform apply
```

O `plan` deve indicar 3 recursos a criar. O `apply` pede confirmação (`yes`) e pode gerar custos no Azure.

### 4. Dar acesso ao state

No Portal: Storage Account, **Access control (IAM)**, **Add role assignment**, papel **Storage Blob Data Contributor**, e selecione sua conta. Aguarde alguns minutos pela propagação.

### 5. Migrar o state para o Azure

Descomente o bloco `backend "azurerm"` no `versions.tf` e rode, na pasta `bootstrap`:

```powershell
terraform init -migrate-state `
  -backend-config="resource_group_name=rg-tfstate-bootstrap-prod" `
  -backend-config="storage_account_name=<nome-da-storage-account>" `
  -backend-config="container_name=tfstate"
```

Quando o Terraform perguntar se deve copiar o state existente para o novo backend, responda `yes`. O comando conecta o Terraform ao container e copia o state local para o blob `bootstrap/terraform.tfstate`. Os recursos no Azure não são alterados.

### 6. Conferir e limpar

```powershell
terraform state list
terraform plan
```

`state list` deve mostrar os 3 recursos e `plan` deve indicar `No changes`. Depois, apague os arquivos locais `terraform.tfstate` e `terraform.tfstate.backup`. Não apague `.terraform/` nem `.terraform.lock.hcl`.

> Atenção: depois que o bloco `backend` estiver ativo, comandos como `plan` e `state list` exigem o `init` com a configuração do backend. Por isso, execute-os somente após a migração.

## Uso nos próximos ambientes

Cada ambiente terá um `backend.tf` com o mesmo Resource Group, Storage Account e container, mas com chave própria:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-bootstrap-prod"
    storage_account_name = "<nome-da-storage-account>"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
    use_azuread_auth     = true
  }
}
```

Em `prod`, muda apenas a chave (`prod/terraform.tfstate`). Esses ambientes não precisam de migração.

## Cuidados operacionais

- Trate o state como informação sensível e limite quem pode lê-lo.
- Revise o `plan` antes de qualquer `apply`.
- Não destrua o bootstrap enquanto outros states dependerem dele.
- Versionamento e retenção ajudam na recuperação, mas não são um plano completo de backup.

## Referências

- [Backend AzureRM](https://developer.hashicorp.com/terraform/language/backend/azurerm)
- [Provider AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [azurerm_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- [azurerm_storage_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container)
