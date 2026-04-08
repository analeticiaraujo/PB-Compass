*** Settings ***
Documentation     Testes do endpoint /produtos — ServeRest
Resource          ../../resources/usuarios_keywords.resource
Resource          ../../resources/login_keywords.resource
Resource          ../../resources/produtos_keywords.resource
Suite Setup       Preparar Suite De Produtos
Suite Teardown    Limpar Suite De Produtos

*** Variables ***
${TOKEN_ADMIN}    ${EMPTY}

*** Keywords ***
Preparar Suite De Produtos
    [Documentation]    Cria sessão, cadastra usuário admin e obtém token para os testes.
    Criar Sessão na ServeRest
    Criar E Cadastrar Usuario
    ${token}    Autenticar Usuario E Retornar Token    ${EMAIL_TEST}
    Set Suite Variable    ${TOKEN_ADMIN}    ${token}

Limpar Suite De Produtos
    [Documentation]    Remove produto e usuário criados durante a suite.
    Limpar Produto Criado
    Limpar Usuario Criado

*** Test Cases ***
Cenário 01: Listar todos os produtos
    [Documentation]    GET /produtos deve retornar 200 com campos 'quantidade' e 'produtos'.
    [Tags]    produtos    smoke
    Listar Produtos E Validar Estrutura Da Resposta

Cenário 02: Cadastrar produto com token de administrador
    [Documentation]    POST /produtos com token válido deve retornar 201 e persistir o ID.
    [Tags]    produtos    smoke    crud
    Cadastrar Produto E Validar Criacao    ${TOKEN_ADMIN}
    Should Not Be Empty    ${ID_PRODUTO_CRIADO}
