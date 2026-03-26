# Testes de API ServeRest — Robot Framework (Revisado)

Suíte de testes E2E para a API pública [ServeRest](https://compassuol.serverest.dev), desenvolvida com Robot Framework e RequestsLibrary no padrão **Keyword-Driven**.

Esta pasta contém a versão refatorada do código original localizado em `../resources/` e `../CompassServerest.robot`. Os arquivos originais não foram alterados.

---

## Estrutura

```
Codigo_revisado/
├── resources/
│   ├── variaveis.resource   # Constantes e variáveis globais da suíte
│   └── keywords.resource    # Keywords de setup, helpers e testes
└── serverest_tests.robot    # Casos de teste
```

### Separação de responsabilidades

| Arquivo | Responsabilidade |
|---|---|
| `variaveis.resource` | URL base, alias da sessão, dados padrão de usuário e variáveis de estado |
| `keywords.resource` | Setup/teardown da sessão, helpers reutilizáveis e keywords de cada cenário |
| `serverest_tests.robot` | Declaração dos casos de teste e suas tags |

---

## Pré-requisitos

- Python 3.14.3
- pip

---

## Instalação

```bash
pip install -r requirements.txt
```

> O `requirements.txt` está na pasta pai (`../requirements.txt`).

---

## Como executar

Na raiz da pasta `Codigo_revisado/`, execute:

```bash
# Todos os testes (resultados salvos automaticamente em results/)
robot -d results serverest_tests.robot
```

### Executar por tag

```bash
# Apenas smoke tests
robot -d results --include smoke serverest_tests.robot

# Apenas testes negativos
robot -d results --include negativo serverest_tests.robot

# Apenas testes de bug documentado
robot -d results --include bug serverest_tests.robot

# Apenas validações de campos obrigatórios
robot -d results --include validacao serverest_tests.robot
```

---

## Casos de teste

| Cenário | Tipo | Tags |
|---|---|---|
| 01 — Cadastrar novo usuário com sucesso | Positivo | `smoke` `crud` |
| 02 — Cadastrar usuário com e-mail já existente | Negativo | `negativo` |
| 03 — Buscar usuário por ID | Positivo | `smoke` `crud` |
| 04 — Atualizar dados do usuário | Positivo | `crud` |
| 05 — Deletar usuário | Positivo | `crud` |
| 06 — Validar que usuário excluído não existe mais | Positivo | `crud` |
| 07 — Cadastrar com e-mail inválido | Bug documentado | `negativo` `bug` |
| 08 — Cadastrar com números no nome | Bug documentado | `negativo` `bug` |
| 09 — Listar todos os usuários | Positivo | `smoke` |
| 10 — Criar usuário via PUT em ID inexistente (upsert) | Positivo | `crud` |
| 11 — Deletar usuário com ID inexistente | Negativo | `negativo` |
| 12 — Cadastrar sem campo nome | Negativo | `negativo` `validacao` |
| 13 — Cadastrar sem campo password | Negativo | `negativo` `validacao` |
| 14 — Cadastrar sem campo administrador | Negativo | `negativo` `validacao` |
| 15 — Cadastrar usuário não administrador | Positivo | `smoke` |

---

## Decisões técnicas e diferenças em relação ao código original

### `verify=${False}` em cada requisição
A versão `robotframework-requests==1.0a14` com Python 3.14 não propaga o `verify=False` configurado na `Create Session` para as requisições individuais. Por isso, `verify=${False}` é declarado explicitamente em cada chamada HTTP.

### `allow_redirects=${False}` nos POSTs
Workaround necessário para a versão do Python utilizada. Sem esse parâmetro, requisições POST resultam em erro de redirecionamento.

### Helper `Gerar Email Aleatório`
O bloco de geração de e-mail aleatório (`Generate Random String` + `Convert To Lower Case` + `Set Variable`) estava duplicado em 6 keywords no código original. Foi centralizado em um único helper.

### Helper `Criar Body de Usuário`
O `Create Dictionary` com os 4 campos do usuário se repetia em quase todas as keywords. Centralizado em um helper com argumentos opcionais e valores padrão.

### `Set Suite Variable` no lugar de `Set Global Variable`
Variáveis globais afetam qualquer suíte em execução paralela. `Set Suite Variable` tem o escopo correto para o que o código precisa.

### Testes de bug (Cenários 07 e 08)
Preservam a lógica de `expected_status=any` + bloco `IF/ELSE` porque documentam comportamento de bug real da API — a única situação onde esse padrão é justificado. Se a API retornar 201, o teste falha com mensagem de bug, faz a limpeza do usuário criado indevidamente e encerra.

### Tags nos casos de teste
Permitem execução seletiva por tipo (`smoke`, `crud`, `negativo`, `validacao`, `bug`), essencial para pipelines de CI/CD.
