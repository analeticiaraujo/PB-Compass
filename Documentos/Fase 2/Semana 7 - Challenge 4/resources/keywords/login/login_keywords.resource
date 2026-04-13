*** Settings ***
Resource    ../../variables/global/global_vars.resource

*** Variables ***
${END_LOGIN}               /login
${SENHA_INVALIDA}          senha_errada_xyz
${SENHA_EM_BRANCO}         ${EMPTY}
${MSG_TOKEN_INVALIDO}      Token de acesso ausente, inválido, expirado ou usuário do token não existe mais
${MSG_LOGIN_SUCESSO}       Login realizado com sucesso
${MSG_LOGIN_INVALIDO}      Email e/ou senha inválidos
${MSG_LOGIN_SENHA_BRANCO}  Email e/ou senha inválidos
${PREFIXO_TOKEN}           Bearer

*** Keywords ***
# ─── HELPERS PRIVADOS ────────────────────────────────────────────────────────

Criar Body de Login
    [Documentation]    Monta o payload de autenticação.
    [Arguments]    ${email}    ${password}
    ${body}    Create Dictionary    email=${email}    password=${password}
    RETURN    ${body}

Executar POST Login
    [Documentation]    Executa POST /login e retorna a resposta.
    [Arguments]    ${email}    ${password}    ${status_esperado}=200
    ${body}    Criar Body de Login    ${email}    ${password}
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=${END_LOGIN}
    ...    json=${body}
    ...    expected_status=${status_esperado}
    ...    verify=${False}
    RETURN    ${resposta}

# ─── KEYWORDS DE TESTE ───────────────────────────────────────────────────────

Autenticar Usuario E Retornar Token
    [Documentation]    POST /login com credenciais válidas. Retorna o bearer token.
    [Arguments]    ${email}    ${password}=${SENHA_PADRAO}
    ${resposta}    Executar POST Login    ${email}    ${password}
    Should Be Equal As Strings    ${resposta.json()['message']}    ${MSG_LOGIN_SUCESSO}
    Should Not Be Empty    ${resposta.json()['authorization']}
    RETURN    ${resposta.json()['authorization']}

Autenticar Com Email Invalido E Validar Rejeicao
    [Documentation]    POST /login com e-mail inválido deve retornar 401.
    [Arguments]    ${email_invalido}=nao_existe@fake.com
    ${resposta}    Executar POST Login    ${email_invalido}    ${SENHA_PADRAO}    status_esperado=401
    Should Be Equal As Strings    ${resposta.json()['message']}    ${MSG_LOGIN_INVALIDO}

Autenticar Com Senha Em Branco E Validar Rejeicao
    [Documentation]    POST /login com senha vazia deve retornar 400.
    [Arguments]    ${email}
    ${resposta}    Executar POST Login    ${email}    ${SENHA_EM_BRANCO}    status_esperado=400
    Should Contain    ${resposta.json()}    password

Autenticar Com Senha Invalida E Validar Rejeicao
    [Documentation]    POST /login com senha incorreta (não vazia) deve retornar 401.
    [Arguments]    ${email}
    ${resposta}    Executar POST Login    ${email}    ${SENHA_INVALIDA}    status_esperado=401
    Should Be Equal As Strings    ${resposta.json()['message']}    ${MSG_LOGIN_INVALIDO}

Validar Contrato Do Token De Autenticacao
    [Documentation]    Valida que o token retornado segue o contrato: campo 'authorization'
    ...                 presente, não vazio e com prefixo Bearer.
    [Arguments]    ${email}    ${password}=${SENHA_PADRAO}
    ${resposta}    Executar POST Login    ${email}    ${password}
    Should Be Equal As Strings    ${resposta.json()['message']}    ${MSG_LOGIN_SUCESSO}
    ${token}    Set Variable    ${resposta.json()['authorization']}
    Should Not Be Empty    ${token}
    ...    msg=CONTRATO QUEBRADO — campo 'authorization' está vazio.
    ${tipo_token}    Evaluate    type($token).__name__
    Should Be Equal As Strings    ${tipo_token}    str
    ...    msg=CONTRATO QUEBRADO — 'authorization' esperado str, recebido ${tipo_token}.
    Should Start With    ${token}    ${PREFIXO_TOKEN}
    ...    msg=CONTRATO QUEBRADO — token não inicia com '${PREFIXO_TOKEN}'. Valor: ${token}
