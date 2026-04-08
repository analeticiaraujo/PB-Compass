*** Settings ***
Library    RequestsLibrary
Library    String
Library    Collections
Library    FakerLibrary    locale=pt_BR

*** Keywords ***
# ─── SESSÃO HTTP ─────────────────────────────────────────────────────────────

Criar Sessão na ServeRest
    [Documentation]    Cria a sessão HTTP reutilizável para toda a suite.
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json
    Create Session
    ...    alias=${ALIAS}
    ...    url=${BASE_URL}
    ...    headers=${headers}
    ...    verify=False
    ...    disable_warnings=1

# ─── GERAÇÃO DE MASSA ────────────────────────────────────────────────────────

Gerar Massa de Dados Dinâmica
    [Documentation]    Usa FakerLibrary para gerar nome, e-mail e senha únicos por execução.
    ...                 Retorna um dicionário com as chaves: nome, email, password.
    ...                 Seguro para execução paralela — cada chamada gera valores distintos.
    ${nome}       First Name
    ${sobrenome}  Last Name
    ${nome_completo}    Set Variable    ${nome} ${sobrenome}
    ${uuid}       Uuid4
    ${email}      Set Variable    teste.${uuid}@emailtest.com
    ${password}   Password    length=12    special_chars=False    digits=True    upper_case=True
    ${massa}    Create Dictionary
    ...    nome=${nome_completo}
    ...    email=${email}
    ...    password=${password}
    Log    Massa gerada — nome: ${nome_completo} | email: ${email}
    RETURN    ${massa}

Gerar Nome De Produto Unico
    [Documentation]    Usa FakerLibrary para gerar nome de produto único por execução.
    ${palavra}    Word
    ${uuid}       Uuid4
    ${nome}    Set Variable    Produto ${palavra} ${uuid}
    RETURN    ${nome}
