*** Settings ***
Documentation     Testes do endpoint /carrinhos — ServeRest
Resource          ../../resources/usuarios_keywords.resource
Resource          ../../resources/login_keywords.resource
Resource          ../../resources/produtos_keywords.resource
Resource          ../../resources/carrinhos_keywords.resource
Suite Setup       Preparar Suite De Carrinhos
Suite Teardown    Limpar Suite De Carrinhos

*** Variables ***
${TOKEN_USUARIO}    ${EMPTY}
${ID_PRODUTO_CT}    ${EMPTY}

*** Keywords ***
Preparar Suite De Carrinhos
    [Documentation]    Cria sessão, cadastra usuário, obtém token e cadastra produto para os testes.
    Criar Sessão na ServeRest
    Criar E Cadastrar Usuario
    ${token}    Autenticar Usuario E Retornar Token    ${EMAIL_TEST}
    Set Suite Variable    ${TOKEN_USUARIO}    ${token}
    ${id_produto}    Cadastrar Produto E Validar Criacao    ${TOKEN_USUARIO}
    Set Suite Variable    ${ID_PRODUTO_CT}    ${id_produto}

Limpar Suite De Carrinhos
    [Documentation]    Conclui compra (remove carrinho), deleta produto e usuário da suite.
    Deletar Carrinho Do Usuario    ${TOKEN_USUARIO}
    Limpar Produto Criado
    Limpar Usuario Criado

*** Test Cases ***
CT09: Cadastrar carrinho com produto válido
    [Documentation]    POST /carrinhos com produto existente deve retornar 201.
    [Tags]    carrinhos    smoke    crud    ct09
    [Teardown]    Deletar Carrinho Do Usuario    ${TOKEN_USUARIO}
    Cadastrar Carrinho E Validar Criacao    ${TOKEN_USUARIO}    ${ID_PRODUTO_CT}

CT10: Cadastrar segundo carrinho para o mesmo usuário deve ser rejeitado
    [Documentation]    POST /carrinhos quando usuário já possui carrinho deve retornar 400.
    [Tags]    carrinhos    negativo    ct10
    [Setup]     Cadastrar Carrinho E Validar Criacao    ${TOKEN_USUARIO}    ${ID_PRODUTO_CT}
    [Teardown]  Deletar Carrinho Do Usuario    ${TOKEN_USUARIO}
    Cadastrar Segundo Carrinho E Validar Rejeicao    ${TOKEN_USUARIO}    ${ID_PRODUTO_CT}

CT11: Cadastrar carrinho com produto inexistente deve ser rejeitado
    [Documentation]    POST /carrinhos com idProduto inválido deve retornar 400.
    [Tags]    carrinhos    negativo    ct11
    Cadastrar Carrinho Com Produto Inexistente E Validar Rejeicao    ${TOKEN_USUARIO}

CT12: Listar todos os carrinhos
    [Documentation]    GET /carrinhos deve retornar 200 com campos 'quantidade' e 'carrinhos'.
    [Tags]    carrinhos    smoke    ct12
    Listar Carrinhos E Validar Estrutura Da Resposta
