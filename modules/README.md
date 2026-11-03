# Módulos

Um **módulo** é uma "receita" reutilizável de infraestrutura: um conjunto de recursos Terraform com entradas (variáveis) e saídas (outputs). Ele descreve *como* criar algo, mas não decide *onde* nem *com quais valores*. Isso é responsabilidade de cada ambiente em [`environments/`](../environments).

## Módulos disponíveis

| Módulo | O que cria | Situação |
| --- | --- | --- |
| [`resource-group`](./resource-group) | Um Resource Group do Azure | Disponível |
| [`network`](./network) | Uma VNet e suas subnets | Disponível |

## Estrutura padrão de um módulo

```text
modules/<nome>/
├── main.tf        # recursos
├── variables.tf   # entradas
├── outputs.tf     # saídas
└── versions.tf    # versões do Terraform e do provider
```

Um módulo **não** declara `provider` nem `backend`. Quem configura isso é o ambiente que chama o módulo.

## Módulo `resource-group`

**Entradas**

| Variável | Tipo | Obrigatória | Descrição |
| --- | --- | --- | --- |
| `name` | `string` | Sim | Nome do Resource Group |
| `location` | `string` | Sim | Região do Azure |
| `tags` | `map(string)` | Não (padrão `{}`) | Tags aplicadas ao recurso |

**Saídas**

| Output | Descrição |
| --- | --- |
| `name` | Nome do Resource Group |
| `id` | ID do Resource Group |
| `location` | Região do Resource Group |

**Exemplo de uso**

```hcl
module "resource_group" {
  source = "../../modules/resource-group"

  name     = "rg-portfolio-dev"
  location = "brazilsouth"
  tags     = { environment = "dev" }
}
```

## Módulo `network`

Cria uma Virtual Network e todas as subnets informadas, com `for_each`. Para adicionar uma subnet, basta incluí-la no mapa `subnets` do ambiente, sem alterar o módulo.

**Entradas**

| Variável | Tipo | Obrigatória | Descrição |
| --- | --- | --- | --- |
| `name` | `string` | Sim | Nome da VNet |
| `location` | `string` | Sim | Região do Azure |
| `resource_group_name` | `string` | Sim | Resource Group onde a VNet será criada |
| `address_space` | `list(string)` | Sim | Faixas CIDR da VNet (validadas) |
| `subnets` | `map(object({ address_prefixes = list(string) }))` | Não (padrão `{}`) | Subnets, indexadas pelo nome (CIDRs validados) |
| `tags` | `map(string)` | Não (padrão `{}`) | Tags aplicadas à VNet |

**Saídas**

| Output | Descrição |
| --- | --- |
| `vnet_id` | ID da VNet |
| `vnet_name` | Nome da VNet |
| `subnet_ids` | Mapa com o ID de cada subnet, indexado pelo nome |

**Exemplo de uso**

```hcl
module "network" {
  source = "../../modules/network"

  name                = "vnet-portfolio-dev"
  location            = "brazilsouth"
  resource_group_name = module.resource_group.name
  address_space       = ["10.10.0.0/16"]
  subnets = {
    "snet-app" = { address_prefixes = ["10.10.1.0/24"] }
  }
}
```

## Boas práticas adotadas

- Módulos pequenos, com uma responsabilidade clara.
- Todas as variáveis e outputs têm `description`.
- Sem valores fixos de ambiente dentro do módulo.
- Faixa de versão do provider declarada em `versions.tf`.
