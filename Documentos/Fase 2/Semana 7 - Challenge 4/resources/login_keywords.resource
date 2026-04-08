*** Settings ***
Resource    variaveis.resource

*** Variables ***
${END_LOGIN}              /login
${SENHA_INVALIDA}         senha_errada_xyz

*** Keywords ***
# ─── HELPERS PRIVADOS ────────────────────────────────────────────────────────

Criar Body de Login
    [Documentation]    Monta o payload de autenticação.
    [Arguments]    ${email}    ${password}
    ${body}    Create Dictionary    email=${email}    password=${password}
    RETURN    ${body}

# ─── KEYWORDS DE TESTE ───────────────────────────────────────────────────────

Autenticar Usuario E Retornar Token
    [Documentation]    POST /login com credenciais válidas. Retorna o bearer token.
    [Arguments]    ${email}    ${password}=${SENHA_PADRAO}
    ${body}    Criar Body de Login    ${email}    ${password}
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=${END_LOGIN}
    ...    json=${body}
    ...    expected_status=200
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Login realizado com sucesso
    Should Not Be Empty    ${resposta.json()['authorization']}
    RETURN    ${resposta.json()['authorization']}

Autenticar Com Senha Invalida E Validar Rejeicao
    [Documentation]    POST /login com senha errada deve retornar 401 com mensagem de erro.
    [Arguments]    ${email}
    ${body}    Criar Body de Login    ${email}    ${SENHA_INVALIDA}
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=${END_LOGIN}
    ...    json=${body}
    ...    expected_status=401
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Email e/ou senha inválidos
