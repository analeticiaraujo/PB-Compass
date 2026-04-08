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
Cenário 01: Login com credenciais válidas deve retornar token
    [Documentation]    POST /login com e-mail e senha válidos deve retornar 200 e bearer token.
    [Tags]    login    smoke
    ${token}    Autenticar Usuario E Retornar Token    ${EMAIL_LOGIN_TEST}
    Should Not Be Empty    ${token}

Cenário 02: Login com senha inválida deve ser rejeitado
    [Documentation]    POST /login com senha errada deve retornar 401 com mensagem de erro.
    [Tags]    login    negativo
    Autenticar Com Senha Invalida E Validar Rejeicao    ${EMAIL_LOGIN_TEST}
