*** Settings ***
Documentation     Testes de contrato do schema de GET /produtos — ServeRest
Resource          ../../resources/usuarios_keywords.resource
Resource          ../../resources/login_keywords.resource
Resource          ../../resources/produtos_keywords.resource
Suite Setup       Preparar Suite De Contrato
Suite Teardown    Limpar Usuario Criado

*** Variables ***
${TOKEN_CONTRATO}    ${EMPTY}

*** Keywords ***
Preparar Suite De Contrato
    [Documentation]    Cria sessão e obtém token de admin para o teste de contrato.
    Criar Sessão na ServeRest
    Criar E Cadastrar Usuario
    ${token}    Autenticar Usuario E Retornar Token    ${EMAIL_TEST}
    Set Suite Variable    ${TOKEN_CONTRATO}    ${token}

*** Test Cases ***
CT04: Validar contrato do schema de GET /produtos
    [Documentation]    Percorre todos os itens retornados por GET /produtos e valida os tipos
    ...                 de cada campo: nome (str), preco (int/float), descricao (str), quantidade (int).
    ...                 Falha com mensagem descritiva se qualquer campo quebrar o contrato.
    [Tags]    produtos    contrato    ct04
    Validar Contrato Da Lista De Produtos
