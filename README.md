# Azure Terraform Infrastructure

![Terraform CI](https://github.com/renatofacchinibiagi/azure-terraform-infrastructure/actions/workflows/terraform-ci.yml/badge.svg)

Projeto prático de **Infrastructure as Code (IaC)** para organizar e evoluir infraestrutura na Microsoft Azure com Terraform.

O objetivo é construir uma base clara e reutilizável, com módulos, ambientes isolados, state remoto seguro e verificação automática do código. O projeto foi desenvolvido por etapas, e cada etapa está documentada.

## Status

| Etapa | Conteúdo | Situação |
| --- | --- | --- |
| 1 | Bootstrap do backend remoto (Resource Group, Storage Account e container) | Concluída: aplicada no Azure, com o state migrado para o Blob Storage |
| 2 | Módulo `resource-group` + ambiente `dev` | Concluída: aplicada no Azure, com state em `dev/terraform.tfstate` |
| 3 | Ambiente `prod` reaproveitando o mesmo módulo (mostra a reutilização) | Concluída: aplicada no Azure, com state em `prod/terraform.tfstate` |
| 4 | Segundo módulo, `network` (VNet e subnets), usado por dev e prod | Concluída: VNet e subnets aplicadas em dev e prod |
| 5 | GitHub Actions com `fmt` e `validate` em pull requests | Concluída: workflow [Terraform CI](./.github/workflows/terraform-ci.yml) |

## Estrutura

```text
.
├── bootstrap/        # Backend remoto do state
├── modules/          # Componentes reutilizáveis (resource-group e network)
├── environments/     # Composição por ambiente (dev e prod)
├── .github/
│   └── workflows/    # CI com GitHub Actions (fmt e validate)
├── .gitignore
└── README.md
```

Documentação: [bootstrap](./bootstrap/readmebootstrap.md), [módulos](./modules/README.md), [ambiente dev](./environments/dev/README.md), [ambiente prod](./environments/prod/README.md) e [CI](./.github/workflows/README.md).

## Como as partes se relacionam

- **Bootstrap:** cria o Resource Group, a Storage Account e o container privado onde os states ficam guardados. É executado uma vez.
- **Módulos:** descrevem *como* criar uma peça de infraestrutura, com variáveis de entrada e outputs.
- **Ambientes:** escolhem *quais* módulos usar e com *quais valores*. Cada ambiente tem um `backend.tf` apontando para o mesmo container, com uma chave de state própria.

```text
Container tfstate
├── bootstrap/terraform.tfstate   (existe)
├── dev/terraform.tfstate         (existe)
└── prod/terraform.tfstate        (existe)
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
- O CI não usa credenciais nem acessa o Azure, e roda com permissão de leitura.
- Nenhum `apply` automático em produção.

## CI

O workflow [Terraform CI](./.github/workflows/terraform-ci.yml) roda em pull requests e em pushes na `main`. Para `bootstrap`, `environments/dev` e `environments/prod`, executa `terraform fmt -check`, `terraform init -backend=false` e `terraform validate`. Detalhes em [.github/workflows/README.md](./.github/workflows/README.md).

O `plan` e o `apply` continuam manuais, porque dependem de acesso ao Azure.

## Limitações atuais

Este é um projeto prático de portfólio. A configuração atual não é uma landing zone corporativa completa. Antes de uso real, deveriam ser avaliados rede privada ou restrição por IP no armazenamento, desabilitação de Shared Key, monitoramento, estratégia de backup e custos.

## Possíveis evoluções

- `terraform plan` em pull requests e `apply` com aprovação para produção, autenticando no Azure com OIDC (sem senha guardada).
- Linters e verificação de segurança (`tflint`, `trivy` ou `checkov`).
- Subscriptions e states separados por ambiente.
- Módulos versionados por tag.

## Referências

- [Documentação do Terraform](https://developer.hashicorp.com/terraform/docs)
- [Backend AzureRM](https://developer.hashicorp.com/terraform/language/backend/azurerm)
- [Provider AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
