# Workflows (GitHub Actions)

## Terraform CI

Arquivo: [terraform-ci.yml](./terraform-ci.yml)

Pipeline de integração contínua que verifica o código Terraform sem acessar o Azure.

### Quando roda

| Gatilho | Objetivo |
| --- | --- |
| `pull_request` | Validar a mudança antes do merge |
| `push` na `main` | Confirmar o resultado após o merge |
| `workflow_dispatch` | Execução manual pela aba Actions |

### O que faz

Um job por diretório raiz do Terraform (`bootstrap`, `environments/dev`, `environments/prod`), em paralelo. Os módulos de `modules/` são validados indiretamente, porque `dev` e `prod` os chamam.

| Passo | Comando | Função |
| --- | --- | --- |
| Formatação | `terraform fmt -check -recursive -diff` | Falha se o código fugir do padrão e mostra a diferença |
| Inicialização | `terraform init -backend=false` | Baixa os providers sem conectar ao state remoto |
| Validação | `terraform validate` | Confere sintaxe, tipos, referências e regras de `validation` |

### Segurança

- **Sem credenciais:** não usa secrets nem login no Azure. Só lê o código.
- **Permissão mínima:** `permissions: contents: read`.
- **Versões fixas:** Terraform `1.9.8` e actions em versão major (`@v4`, `@v3`). O `.terraform.lock.hcl` fixa o provider.
- **`concurrency`:** cancela execuções antigas da mesma branch.

### O que o CI não faz

Não executa `terraform plan` nem `apply`, pois ambos precisam acessar o Azure e o state. Ele não detecta, por exemplo, nome de recurso já em uso, falta de permissão ou quota. Essas verificações continuam sendo feitas manualmente com `plan` antes do `apply`.

### Como reproduzir localmente

Em cada diretório raiz, por exemplo `environments/dev`:

```powershell
terraform fmt -check -recursive -diff
terraform init -backend=false
terraform validate
```

Atenção: o `init -backend=false` altera a configuração local do backend. Para voltar a usar o state remoto, rode o `init` de novo com os `-backend-config` (e `-reconfigure`).
