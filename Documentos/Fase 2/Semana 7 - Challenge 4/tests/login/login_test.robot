*** Settings ***
Documentation     Testes de autenticação do endpoint /login — ServeRest
Resource          ../../resources/usuarios_keywords.resource
Resource          ../../resources/login_keywords.resource
Suite Setup       Preparar Suite De Login
Suite Teardown    Limpar Usuario Criado

*** Variables ***
${EMAIL_LOGIN_TEST}    ${EMPTY}

*** Keywords ***
Preparar Suite De Login
    [Documentation]    Cria sessão e cadastra um usuário admin para os testes de login.
    Criar Sessão na ServeRest
    Criar E Cadastrar Usuario
    Set Suite Variable    ${EMAIL_LOGIN_TEST}    ${EMAIL_TEST}

*** Test Cases ***
CT17: Login com credenciais válidas deve retornar token
    [Documentation]    POST /login com e-mail e senha válidos deve retornar 200 e bearer token.
    [Tags]    login    smoke    ct17
    ${token}    Autenticar Usuario E Retornar Token    ${EMAIL_LOGIN_TEST}
    Should Not Be Empty    ${token}

CT18: Login com e-mail inválido deve ser rejeitado
    [Documentation]    POST /login com e-mail inexistente deve retornar 401.
    [Tags]    login    negativo    ct18
    Autenticar Com Email Invalido E Validar Rejeicao

CT19: Login com senha em branco deve ser rejeitado
    [Documentation]    POST /login com senha vazia deve retornar 400 com erro no campo password.
    [Tags]    login    negativo    ct19
    Autenticar Com Senha Em Branco E Validar Rejeicao    ${EMAIL_LOGIN_TEST}

CT20: Contrato do token de autenticação deve ser válido
    [Documentation]    Token retornado deve ser string não vazia com prefixo Bearer.
    [Tags]    login    contrato    ct20
    Validar Contrato Do Token De Autenticacao    ${EMAIL_LOGIN_TEST}

CT21: Login com senha incorreta deve ser rejeitado
    [Documentation]    POST /login com senha errada (não vazia) deve retornar 401.
    [Tags]    login    negativo    ct21
    Autenticar Com Senha Invalida E Validar Rejeicao    ${EMAIL_LOGIN_TEST}
