*** Settings ***
Library  RequestsLibrary
Library  String

*** Variables ***
${body}
${headers}
${resposta}
${EMAIL_TEST}
${ID_USUARIO_CRIADO}


*** Keywords ***
Criar um novo usuário
    ${palavra_aleatoria}    Generate Random String    length=4    chars=[LETTERS]
    ${palavra_aleatoria}    Convert To Lower Case    ${palavra_aleatoria}
    Set Global Variable    ${EMAIL_TEST}    ${palavra_aleatoria}@emailtest.com
    Log    ${EMAIL_TEST}

Criar Sessão na ServeRest
    ${headers}  Create Dictionary  accept=application/json  Content-Type=application/json
    Create Session  
    ...    alias=ServeRest  
    ...    url=https://compassuol.serverest.dev  
    ...    headers=${headers}
    ...    verify=False
    ...    disable_warnings=1

Cadastrar o usuário criado na ServeRest
    ${body}  Create Dictionary  
    ...    nome=Fulano da Silva  
    ...    email=${EMAIL_TEST}  
    ...    password=1234  
    ...    administrador=true
    #Fazer o POST On Session
    ${resposta}  POST On Session  
    ...    alias=ServeRest
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=any
    ...    verify=${False}
    ...    allow_redirects=${False}
    Log  ${body}
    Log    ${resposta.text}
    Log To Console    \nStatus retornado: ${resposta.status_code}
    Log To Console    Resposta do servidor: ${resposta.text}

    # Só tenta pegar o ID se o status for o esperado
    IF    ${resposta.status_code} == 201
        ${id_criado}    Set Variable    ${resposta.json()['_id']}
        Log To Console    ID do novo usuário: ${id_criado}
        Set Global Variable    ${ID_USUARIO_CRIADO}    ${id_criado}
    ELSE
        Fail    A API não retornou 201. Retornou ${resposta.status_code}. Verifique o log!
    END

Pegar o ID gerado pelo sistema para usar depois
    IF    ${resposta.status_code} == 201
    ${id_criado}    Set Variable    ${resposta.json()['_id']}
    Set Global Variable    ${ID_USUARIO_CRIADO}    ${id_criado}
    END