# Módulos

Um **módulo** é uma "receita" reutilizável de infraestrutura: um conjunto de recursos Terraform com entradas (variáveis) e saídas (outputs). Ele descreve *como* criar algo, mas não decide *onde* nem *com quais valores*. Isso é responsabilidade de cada ambiente em [`environments/`](../environments).

## Módulos disponíveis

| Módulo | O que cria | Situação |
| --- | --- | --- |
| [`resource-group`](./resource-group) | Um Resource Group do Azure | Disponível |
| `network` | VNet e subnets | Planejado (Etapa 4) |

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

## Boas práticas adotadas

- Módulos pequenos, com uma responsabilidade clara.
- Todas as variáveis e outputs têm `description`.
- Sem valores fixos de ambiente dentro do módulo.
- Faixa de versão do provider declarada em `versions.tf`.
