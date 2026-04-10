# 🤖 Automação de API — ServeRest | Robot Framework

> Projeto de automação de testes para a API REST [ServeRest](https://compassuol.serverest.dev), desenvolvido como parte do **Programa de Bolsas Compass UOL**. Cobre os endpoints `/usuarios`, `/login`, `/produtos` e `/carrinhos` com 33 casos de teste rastreáveis, execução paralela e geração de massa de dados dinâmica.

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Tecnologias e Dependências](#-tecnologias-e-dependências)
- [Arquitetura de Pastas](#-arquitetura-de-pastas)
- [Cobertura de Testes](#-cobertura-de-testes-ct01--ct33)
- [Independência e Isolamento](#-independência-e-isolamento-de-testes)
- [Geração de Massa de Dados](#-geração-de-massa-de-dados-dinâmica)
- [Guia de Execução](#-guia-de-execução)
- [Engenharia de Prompt e Qualidade](#-engenharia-de-prompt-e-qualidade-de-código)

---

## 🎯 Visão Geral

Este projeto implementa uma suíte de testes automatizados para a API ServeRest seguindo princípios de **Clean Code**, **DRY (Don't Repeat Yourself)** e **arquitetura modular por endpoint**. Os testes cobrem cenários funcionais positivos e negativos, validação de contratos de schema e regras de negócio complexas definidas no Swagger da API.

| Métrica | Valor |
|---|---|
| 🧪 Total de Test Cases | **33** |
| ✅ Testes Positivos (smoke/crud) | **13** |
| ❌ Testes Negativos | **18** |
| 📐 Testes de Contrato | **2** |
| 🔗 Endpoints cobertos | **4** (`/usuarios`, `/login`, `/produtos`, `/carrinhos`) |

---

## 🛠️ Tecnologias e Dependências

| Tecnologia | Versão Mínima | Uso no Projeto |
|---|---|---|
| 🤖 `robotframework` | `7.0` | Motor de execução, `IF/ELSE`, `FOR`, `RETURN` nativos |
| 🌐 `robotframework-requests` | `0.9.7` | Keywords HTTP: `GET/POST/PUT/DELETE On Session` |
| 🎭 `robotframework-faker` | `5.0.0` | Geração de massa dinâmica: nomes, e-mails, senhas |
| ⚡ `robotframework-pabot` | `2.18.0` | Execução paralela de suites (`--processes N`) |
| 🐍 `Faker` | `24.0.0` | Engine Python do Faker com locale `pt_BR` |
| 🔗 `requests` | `2.31.0` | Dependência HTTP do robotframework-requests |
| 🔒 `urllib3` | `2.0.0` | Gerenciamento de conexões SSL/TLS |

---

## 📁 Arquitetura de Pastas

O projeto segue um **padrão modular estrito**, onde cada camada tem uma única responsabilidade. Arquivos de teste nunca contêm lógica de requisição; arquivos de keywords nunca contêm dados de ambiente.

```
Semana 7 - Challenge 4/
│
├── 📂 tests/                          # Camada de orquestração — apenas Test Cases e Tags
│   ├── usuarios/
│   │   └── usuarios.robot             # CT01–CT16
│   ├── login/
│   │   └── login_test.robot           # CT17–CT21
│   ├── produtos/
│   │   └── produtos_test.robot        # CT22–CT29
│   └── carrinhos/
│       └── carrinhos_test.robot       # CT30–CT33
│
├── 📂 resources/
│   ├── keywords/                      # Camada de lógica — Keywords por endpoint
│   │   ├── common/
│   │   │   └── common.resource        # ✨ FakerLibrary, sessão HTTP, geradores de massa
│   │   ├── usuarios/
│   │   │   └── usuarios_keywords.resource
│   │   ├── login/
│   │   │   └── login_keywords.resource
│   │   ├── produtos/
│   │   │   └── produtos_keywords.resource
│   │   └── carrinhos/
│   │       └── carrinhos_keywords.resource
│   │
│   └── variables/                     # Camada de dados — variáveis de ambiente
│       └── global/
│           └── global_vars.resource   # BASE_URL, ALIAS, variáveis globais
│
├── 📂 results/                        # Relatórios gerados pelo Robot (gitignored)
├── 📄 requirements.txt                # Dependências do projeto
└── 📄 pabot.resources                 # Configuração de lock para execução paralela
```

### 🔗 Fluxo de Importação

```
tests/*.robot
    └── resources/keywords/<endpoint>/<endpoint>_keywords.resource
            ├── resources/variables/global/global_vars.resource
            └── resources/keywords/common/common.resource
                    └── resources/variables/global/global_vars.resource
```

Cada arquivo `.robot` importa apenas o resource do seu endpoint. O `common.resource` é carregado **transitivamente** — sem duplicação de imports.

---

## 🧪 Cobertura de Testes (CT01 – CT33)

### 👤 `/usuarios` — `usuarios.robot` (CT01–CT16)

| ID | Descrição | Tipo | Tags |
|---|---|---|---|
| CT01 | Cadastrar um novo usuário com sucesso | ✅ Positivo | `smoke` `crud` |
| CT02 | Cadastrar usuário com e-mail já existente | ❌ Negativo | `negativo` |
| CT03 | Buscar usuário pelo ID | ✅ Positivo | `smoke` `crud` |
| CT04 | Atualizar dados do usuário existente | ✅ Positivo | `crud` |
| CT05 | Deletar usuário existente | ✅ Positivo | `crud` |
| CT06 | Confirmar que usuário deletado não existe mais | ✅ Positivo | `crud` |
| CT07 | Rejeitar e-mail com caractere especial inválido | ❌ Negativo | `negativo` `bug` |
| CT08 | Rejeitar nome contendo números | ❌ Negativo | `negativo` `bug` |
| CT09 | Listar todos os usuários cadastrados | ✅ Positivo | `smoke` |
| CT10 | Criar usuário via PUT em ID inexistente (upsert) | ✅ Positivo | `crud` |
| CT11 | Deletar usuário com ID inexistente | ❌ Negativo | `negativo` |
| CT12 | Cadastrar usuário sem campo `nome` | ❌ Negativo | `negativo` `validacao` |
| CT13 | Cadastrar usuário sem campo `password` | ❌ Negativo | `negativo` `validacao` |
| CT14 | Cadastrar usuário sem campo `administrador` | ❌ Negativo | `negativo` `validacao` |
| CT15 | Cadastrar usuário não administrador com sucesso | ✅ Positivo | `smoke` |
| CT16 | Cadastrar usuário sem campo `email` | ❌ Negativo | `negativo` `validacao` |

### 🔐 `/login` — `login_test.robot` (CT17–CT21)

| ID | Descrição | Tipo | Tags |
|---|---|---|---|
| CT17 | Login com credenciais válidas deve retornar token | ✅ Positivo | `smoke` |
| CT18 | Login com e-mail inválido deve ser rejeitado | ❌ Negativo | `negativo` |
| CT19 | Login com senha em branco deve ser rejeitado | ❌ Negativo | `negativo` |
| CT20 | Contrato do token: tipo `str` e prefixo `Bearer` | 📐 Contrato | `contrato` |
| CT21 | Login com senha incorreta deve ser rejeitado | ❌ Negativo | `negativo` |

### 📦 `/produtos` — `produtos_test.robot` (CT22–CT29)

| ID | Descrição | Tipo | Tags |
|---|---|---|---|
| CT22 | Cadastrar produto com token de administrador | ✅ Positivo | `smoke` `crud` |
| CT23 | Cadastrar produto com nome duplicado | ❌ Negativo | `negativo` |
| CT24 | Cadastrar produto com preço negativo | ❌ Negativo | `negativo` |
| CT25 | Cadastrar produto sem campo `descricao` | ❌ Negativo | `negativo` `validacao` |
| CT26 | Cadastrar produto com quantidade zero | ❌ Negativo | `negativo` `validacao` |
| CT27 | Cadastrar produto com quantidade negativa | ❌ Negativo | `negativo` `validacao` |
| CT28 | Cadastrar produto com token inválido | ❌ Negativo | `negativo` `seguranca` |
| CT29 | Validar contrato do schema de GET /produtos | 📐 Contrato | `contrato` |

### 🛒 `/carrinhos` — `carrinhos_test.robot` (CT30–CT33)

| ID | Descrição | Tipo | Tags |
|---|---|---|---|
| CT30 | Cadastrar carrinho com produto válido | ✅ Positivo | `smoke` `crud` |
| CT31 | Segundo carrinho para o mesmo usuário deve ser rejeitado | ❌ Negativo | `negativo` |
| CT32 | Carrinho com produto inexistente deve ser rejeitado | ❌ Negativo | `negativo` |
| CT33 | Listar todos os carrinhos | ✅ Positivo | `smoke` |

---

## 🔒 Independência e Isolamento de Testes

Cada suite é **completamente autossuficiente**. Nenhum teste depende do estado deixado por outro — o que torna a execução paralela segura.

### Padrão de Setup Atômico

```
Suite Setup
    └── Criar Sessão na ServeRest       ← conexão HTTP isolada por processo
    └── Criar E Cadastrar Usuario       ← usuário único via Faker + UUID4
    └── Autenticar Usuario E Retornar Token  ← token fresco por suite
    └── [Cadastrar Produto]             ← apenas nas suites que precisam
```

### Padrão de Teardown em Cascata

```
Suite Teardown
    └── Deletar Carrinho Do Usuario     ← limpa carrinho (se existir)
    └── Limpar Produto Criado           ← limpa produto (se existir)
    └── Limpar Usuario Criado           ← limpa usuário (sempre)
```

Todos os teardowns usam `Run Keyword And Ignore Error` — uma falha na limpeza **nunca bloqueia** a limpeza dos recursos seguintes.

---

## 🎭 Geração de Massa de Dados Dinâmica

A keyword `Gerar Massa de Dados Dinâmica` em `common.resource` usa **UUID4** para garantir unicidade absoluta entre execuções paralelas:

```robot
Gerar Massa de Dados Dinâmica
    ${nome}          First Name                          # Faker pt_BR
    ${sobrenome}     Last Name                           # Faker pt_BR
    ${uuid}          Uuid4                               # 2¹²² combinações
    ${email}         Set Variable    teste.${uuid}@emailtest.com
    ${password}      Password    length=12    digits=True    upper_case=True
    RETURN           # dicionário {nome, email, password}
```

> 💡 **Por que UUID4 e não `Generate Random String`?**
> `Generate Random String` com 6 chars tem ~2 bilhões de combinações — colisão possível em pipelines com muitas execuções paralelas. UUID4 tem **2¹²² combinações**: colisão é matematicamente impossível, garantindo zero conflito de dados entre processos do Pabot.

---

## 🚀 Guia de Execução

### Pré-requisitos

- Python 3.8 ou superior
- pip atualizado

### 1️⃣ Clonar e preparar o ambiente

```bash
# Criar ambiente virtual
python -m venv .venv

# Ativar — Windows
.venv\Scripts\activate

# Ativar — macOS/Linux
source .venv/bin/activate
```

### 2️⃣ Instalar dependências

```bash
pip install -r requirements.txt
```

### 3️⃣ Verificar instalação

```bash
pip show robotframework robotframework-requests robotframework-faker robotframework-pabot
```

### 4️⃣ Executar os testes

```bash
# ── Execução sequencial completa ──────────────────────────────────────────────
robot -d results tests/

# ── Execução paralela (4 processos — um por suite) ────────────────────────────
pabot --processes 4 -d results tests/

# ── Filtrar por tag ───────────────────────────────────────────────────────────
robot -d results --include smoke tests/
robot -d results --include contrato tests/
robot -d results --include negativo tests/

# ── Executar suite específica ─────────────────────────────────────────────────
robot -d results tests/usuarios/usuarios.robot
robot -d results tests/produtos/produtos_test.robot

# ── Executar CT específico pelo ID ────────────────────────────────────────────
robot -d results --include ct29 tests/

# ── Paralelo com merge de relatório ──────────────────────────────────────────
pabot --processes 4 -d results --merge tests/
```

### 5️⃣ Visualizar relatório

Após a execução, abra o arquivo gerado em `results/report.html` no navegador.

---

## 🤖 Engenharia de Prompt e Qualidade de Código

Este projeto foi desenvolvido com o auxílio de **IA Generativa (Amazon Q Developer)** como ferramenta de arquitetura e auditoria contínua. O processo seguiu um ciclo estruturado de **Prompt Engineering**:

| Fase | Técnica Aplicada | Resultado |
|---|---|---|
| 🏗️ Arquitetura | Prompt de Arquiteto de Soluções | Estrutura modular `tests/` + `resources/keywords/` + `resources/variables/` |
| ♻️ Refatoração | Prompt de Code Review com critérios DRY | Eliminação de keywords duplicadas, parametrização de campos obrigatórios |
| 🔍 Auditoria | Prompt de QA Lead com checklist de compliance | Identificação de 7 lacunas de cobertura e 3 riscos de oráculo |
| 🧪 Expansão | Prompt de QA Engineer com mapeamento de CT | 33 casos de teste rastreáveis com IDs únicos |
| 🔒 Segurança | Prompt de DevOps para dependências | `requirements.txt` com versões mínimas e dependências transitivas fixadas |
| 🧹 Limpeza | Prompt de Arquiteto para reorganização física | Remoção de 8 arquivos legados, estrutura final sem duplicatas |

> 📝 Todo o histórico de prompts, outputs e ajustes manuais está documentado em `PROMPT_LOG.md`, garantindo **rastreabilidade total** das decisões de design e **auditoria de alucinações** da IA.

---

## 📊 Distribuição de Cobertura por Tipo

```
Positivos  ████████████████░░░░░░░░░░░░░░  13 / 33  (39%)
Negativos  ████████████████████████░░░░░░  18 / 33  (55%)
Contrato   ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░   2 / 33  ( 6%)
```

---

<div align="center">

Desenvolvido por **Ana Letícia de Araújo** durante o **Programa de Bolsas Compass UOL**

</div>
