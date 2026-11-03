# Azure Terraform Infrastructure

Projeto prático de **Infrastructure as Code (IaC)** para organizar e evoluir infraestrutura na Microsoft Azure com Terraform.

O objetivo é construir uma base clara e reutilizável, com módulos, ambientes isolados e gerenciamento seguro do state remoto. O projeto é desenvolvido por etapas, e cada etapa é documentada.

## Status

| Etapa | Situação |
| --- | --- |
| Bootstrap do backend remoto (Resource Group, Storage Account e container) | Concluída: aplicada no Azure, com o state migrado para o Blob Storage |
| Módulos reutilizáveis (Resource Group e rede) | Planejada |
| Ambientes `dev` e `prod` | Planejada |
| Validações automatizadas com GitHub Actions | Planejada |

## Estrutura

```text
.
├── bootstrap/        # Backend remoto do state (concluído)
├── modules/          # Planejado: componentes reutilizáveis
├── environments/     # Planejado: composição por ambiente (dev/prod)
├── .github/          # Planejado: workflows de CI
├── .gitignore
└── README.md
```

Documentação do bootstrap: [bootstrap/readmebootstrap.md](./bootstrap/readmebootstrap.md).

## Como as partes se relacionam

- **Bootstrap:** cria o Resource Group, a Storage Account e o container privado onde os states ficam guardados. É executado uma vez.
- **Módulos:** descrevem *como* criar uma peça de infraestrutura, com variáveis de entrada e outputs.
- **Ambientes:** escolhem *quais* módulos usar e com *quais valores*. Cada ambiente terá um `backend.tf` apontando para o mesmo container, com uma chave de state própria.

```text
Container tfstate
├── bootstrap/terraform.tfstate   (existe)
├── dev/terraform.tfstate         (planejado)
└── prod/terraform.tfstate        (planejado)
```

Os ambientes `dev` e `prod` já nascem com backend remoto e não precisam de migração. Somente o bootstrap passou por ela, porque cria o próprio armazenamento.

## Segurança e o que vai para o Git

O repositório não deve conter state, credenciais nem valores reais de variáveis. O [.gitignore](./.gitignore) aplica estas regras:

| Versionado | Não versionado |
| --- | --- |
| Arquivos `*.tf` | `*.tfstate` e backups |
| `.terraform.lock.hcl` (versões fixas dos providers) | Diretórios `.terraform/` |
| `*.tfvars.example` (sem valores reais) | `*.tfvars` e `*.tfvars.json` |
| Documentação e workflows de CI | Planos salvos (`*tfplan*`) |
| | Arquivos `backend.hcl`, `.env`, chaves e certificados |

Princípios adotados:

- O state fica no Azure Blob Storage, com acesso por Microsoft Entra ID e papéis RBAC, sem chaves no código.
- O container é privado e tem versionamento e retenção de exclusão.
- Mudanças são revisadas com `terraform plan` antes do `apply`.
- Nenhum `apply` automático em produção.

## Limitações atuais

Este é um projeto prático de portfólio. A configuração atual não é uma landing zone corporativa completa. Antes de uso real, deveriam ser avaliados rede privada ou restrição por IP no armazenamento, desabilitação de Shared Key, monitoramento, estratégia de backup e custos.

## Referências

- [Documentação do Terraform](https://developer.hashicorp.com/terraform/docs)
- [Backend AzureRM](https://developer.hashicorp.com/terraform/language/backend/azurerm)
- [Provider AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
