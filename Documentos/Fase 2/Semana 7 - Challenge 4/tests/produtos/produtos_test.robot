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
CT22: Cadastrar produto com token de administrador
    [Documentation]    POST /produtos com token válido deve retornar 201 e persistir o ID.
    [Tags]    produtos    smoke    crud    ct22
    [Teardown]    Limpar Produto Criado
    Cadastrar Produto E Validar Criacao    ${TOKEN_ADMIN}
    Should Not Be Empty    ${ID_PRODUTO_CRIADO}

CT23: Cadastrar produto com nome duplicado deve ser rejeitado
    [Documentation]    POST /produtos com nome já existente deve retornar 400.
    [Tags]    produtos    negativo    ct23
    [Setup]     Cadastrar Produto E Validar Criacao    ${TOKEN_ADMIN}
    [Teardown]  Limpar Produto Criado
    ${nome_do_produto}    Set Variable    ${NOME_PRODUTO_PADRAO}
    Cadastrar Produto Com Nome Duplicado E Validar Conflito    ${TOKEN_ADMIN}    ${nome_do_produto}

CT24: Cadastrar produto com preço negativo deve ser rejeitado
    [Documentation]    POST /produtos com preco negativo deve retornar 400.
    [Tags]    produtos    negativo    ct24
    Cadastrar Produto Com Preco Negativo E Validar Rejeicao    ${TOKEN_ADMIN}

CT25: Cadastrar produto sem descrição deve ser rejeitado
    [Documentation]    POST /produtos sem campo 'descricao' deve retornar 400.
    [Tags]    produtos    negativo    validacao    ct25
    Cadastrar Produto Sem Descricao E Validar Rejeicao    ${TOKEN_ADMIN}

CT26: Cadastrar produto com quantidade zero deve ser rejeitado
    [Documentation]    POST /produtos com quantidade=0 deve retornar 400 — estoque não pode ser zero.
    [Tags]    produtos    negativo    validacao    ct26
    Cadastrar Produto Com Quantidade Zero E Validar Rejeicao    ${TOKEN_ADMIN}

CT27: Cadastrar produto com quantidade negativa deve ser rejeitado
    [Documentation]    POST /produtos com quantidade negativa deve retornar 400 — estoque não pode ser negativo.
    [Tags]    produtos    negativo    validacao    ct27
    Cadastrar Produto Com Quantidade Negativa E Validar Rejeicao    ${TOKEN_ADMIN}

CT28: Cadastrar produto com token inválido deve ser rejeitado
    [Documentation]    POST /produtos com token inválido deve retornar 401 com mensagem de acesso negado.
    [Tags]    produtos    negativo    seguranca    ct28
    Cadastrar Produto Com Token Invalido E Validar Rejeicao

CT29: Validar contrato do schema de GET /produtos
    [Documentation]    Percorre todos os itens retornados por GET /produtos e valida os tipos
    ...                 de cada campo: nome (str), preco (int/float), descricao (str), quantidade (int).
    ...                 Falha com mensagem descritiva se qualquer campo quebrar o contrato.
    [Tags]    produtos    contrato    ct29
    Validar Contrato Da Lista De Produtos
