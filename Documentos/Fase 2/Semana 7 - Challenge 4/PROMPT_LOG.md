<<<<<<< HEAD
# 🤖 Prompt Log - Challenge 03
=======
# Prompt Log - Challenge 03
>>>>>>> eccc812d8e489ebaea0fcc27a5bc7fb45dc37e64

Este documento registra a interação com GenAI para a evolução do plano de testes e automação.

---

## Estrutura de Registro (Exemplo)
> **Objetivo:** [Ex: Gerar cenários negativos para /usuarios]
> **Contexto:** [Ex: Endpoint POST /usuarios, campos nome, email, password, administrador]
> **Prompt Final:** [O texto que você enviou para a IA]
> **Resposta da IA:** [Resumo do que ela entregou]
> **Ajustes Manuais:** [O que você corrigiu ou descartou para evitar alucinação]
> **Critérios de Validação:** [Como você garantiu que o teste é válido]

---

<<<<<<< HEAD
## Log #1: [Título do que você vai fazer primeiro]
*Atue exclusivamente como Arquiteto de Soluções. Preciso da estrutura de pastas para o projeto Serverest em Robot Framework, mas NÃO gere novos casos de teste agora.

O que eu preciso:

Desenho da Árvore de Diretórios: Mostre uma estrutura que separe tests/ de resources/. Dentro de resources/, crie uma distinção clara entre o que é global (ex: autenticação, config) e o que é específico por endpoint.

Mapeamento de Importação: Explique como um arquivo dentro de tests/login/login.robot deve referenciar um arquivo em resources/common/common.resource (mostre o uso correto do ../).

Padrão de Nomes: Sugira nomes para os arquivos que facilitem a busca (ex: usuarios_keywords.resource vs usuarios_test.robot).

O que NÃO fazer:

Não escreva cenários de teste para /carrinhos, /produtos ou qualquer outro.

Apenas forneça o esqueleto e a explicação de onde cada responsabilidade deve morar.*

Output:

Estrutura de Diretórios — Serverest em Robot Framework
1. Árvore de Diretórios
serverest-robot/
├── tests/
│   ├── login/
│   │   └── login_test.robot
│   ├── usuarios/
│   │   └── usuarios_test.robot
│   ├── produtos/
│   │   └── produtos_test.robot
│   └── carrinhos/
│       └── carrinhos_test.robot
│
├── resources/
│   ├── common/
│   │   ├── common.resource          # Imports globais, variáveis de ambiente
│   │   └── auth.resource            # Keywords de autenticação reutilizáveis
│   │
│   └── endpoints/
│       ├── login_keywords.resource
│       ├── usuarios_keywords.resource
│       ├── produtos_keywords.resource
│       └── carrinhos_keywords.resource
│
├── variables/
│   └── env.yaml                     # Baseurl, credenciais, timeouts
│
└── results/                         # Gerado pelo Robot (gitignore)

2. Mapeamento de Importação
De dentro de tests/login/login_test.robot, o caminho relativo sobe dois níveis (../../) para chegar à raiz e então desce até resources/:
*** Settings ***
Resource    ../../resources/common/common.resource
Resource    ../../resources/endpoints/login_keywords.resource
Variables   ../../variables/env.yaml

Regra: cada ../ sobe um nível de diretório. tests/login/ → tests/ → raiz → resources/.

3. Padrão de Nomes
Camada	Sufixo	Exemplo	Responsabilidade
Testes	_test.robot	usuarios_test.robot	Cenários, suites, tags
Keywords de endpoint	_keywords.resource	usuarios_keywords.resource	Keywords específicas do endpoint
Utilitários globais	.resource	common.resource, auth.resource	Setup/Teardown, headers, tokens
Variáveis	.yaml	env.yaml	Dados de ambiente, não lógica
4. Responsabilidade por Camada
common.resource → Library RequestsLibrary, variáveis globais, keywords de setup de sessão

auth.resource → Keyword Obter Token que outros endpoints importam

*_keywords.resource → Keywords atômicas do endpoint (ex: POST Usuário, GET Usuário Por ID)

*_test.robot → Apenas orquestra keywords, define Test Cases e Tags


## Log #2: [Refatorar de acordo com os resultados obtidos]
*Com base na estrutura de arquitetura que definimos, reorganize e refine o meu arquivo atual /usuarios.robot (antigo serverest_test.robot).

Ações obrigatórias:

Separação de Responsabilidades: Extraia todas as Keywords de ação do arquivo .robot e mova-as para um novo arquivo chamado Documentos/Fase 2/Semana 7 - Challenge 4/resources/usuarios_keywords.resource.

Camada de Teste: Deixe no arquivo ../../tests/usuarios/usuarios.robot apenas as seções Settings e Test Cases.

Correção de Imports: No arquivo de teste, configure o Resource apontando corretamente para ../../resources/usuarios_keywords.resource.

Limpeza: Remova variáveis 'hardcoded' e substitua-as por argumentos nas Keywords ou variáveis no topo do arquivo de resource.

NÃO crie testes para outros endpoints agora. Foque apenas em deixar o fluxo de /usuarios impecável e seguindo a nova pasta.

Saída esperada: Mostre o conteúdo final de tests/usuarios/usuarios.robot e de resources/usuarios_keywords.resource separadamente.*


Output:
Com base na estrutura de arquitetura que definimos, reorganize e refine o meu arquivo atual /usuarios.robot (antigo serverest_test.robot).

Ações obrigatórias:

Separação de Responsabilidades: Extraia todas as Keywords de ação do arquivo .robot e mova-as para um novo arquivo chamado Documentos/Fase 2/Semana 7 - Challenge 4/resources/usuarios_keywords.resource.

Camada de Teste: Deixe no arquivo ../../tests/usuarios/usuarios.robot apenas as seções Settings e Test Cases.

Correção de Imports: No arquivo de teste, configure o Resource apontando corretamente para ../../resources/usuarios_keywords.resource.

Limpeza: Remova variáveis 'hardcoded' e substitua-as por argumentos nas Keywords ou variáveis no topo do arquivo de resource.

NÃO crie testes para outros endpoints agora. Foque apenas em deixar o fluxo de /usuarios impecável e seguindo a nova pasta.

Saída esperada: Mostre o conteúdo final de tests/usuarios/usuarios.robot e de resources/usuarios_keywords.resource separadamente.
Semana 7 - Challenge 4/
├── tests/
│   └── usuarios/
│       └── usuarios.robot          ← apenas Settings + Test Cases
├── resources/
│   ├── variaveis.resource          ← intocado
│   ├── keywords.resource           ← intocado (legado)
│   └── usuarios_keywords.resource  ← novo, todas as keywords
└── serverest_tests.robot           ← legado, pode ser removido depois

Decisões tomadas:

usuarios.robot tem zero lógica — só orquestra keywords pelo nome

usuarios_keywords.resource importa variaveis.resource diretamente (caminho relativo simples, pois estão na mesma pasta resources/)

O import em usuarios.robot usa ../../resources/usuarios_keywords.resource — sobe de usuarios/ → tests/ → raiz do challenge, depois desce para resources/

Nenhuma string hardcoded nas keywords de teste: nomes como Fulano Replicado que são dados de teste ficaram nas keywords de ação (correto), e dados de configuração como BASE_URL e SENHA_PADRAO continuam centralizados em variaveis.resource

keywords.resource original foi preservado para não quebrar nada enquanto a migração não for validada


## Log #3: [Analisar qualidade do código já escrito]
*Atue como um Engenheiro de QA Sênior e Arquiteto de Automação. Analise os arquivos Robot Framework abaixo (usuarios.robot e usuarios_keywords.resource) e realize um Code Review focado em qualidade e manutenibilidade.

Critérios de Auditoria:

Padrões Robot: Estou usando as seções (Settings, Variables, Test Cases, Keywords) de forma correta e organizada?

Abstração: As Keywords no arquivo .resource são reutilizáveis ou estão presas a um único cenário?

Tratamento de Dados: Existe algum valor fixo (hardcoded) que deveria ser uma variável ou argumento?

Asserções (Oráculos): Meus 'Should Be Equal' e validações de JSON estão verificando apenas o Status Code ou também o conteúdo da resposta?

Documentação: O código está legível? Os nomes das Keywords descrevem claramente a ação?

Tratamento de Erros: Os testes negativos estão validando a mensagem de erro correta retornada pela API Serverest?

Saída esperada:

Uma nota de 0 a 10 para a 'Saúde do Código'.

Uma lista de 'Pontos de Melhoria' priorizada (do mais crítico para o estético).

Sugestão de código para corrigir o ponto mais crítico encontrado.*

Output:

## Log #4: [Remover dependencias de testes]
**

Output:

## Log #5: [Remover dependencias de testes]
**

Output:

## Log #6: [Remover dependencias de testes]
**

Output:

## Log #7: [Remover dependencias de testes]
**

Output: