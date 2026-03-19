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
    #Cria novo usuário na ServeRest
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
    Log    ${body}
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

Cadastrar um usuário já existente
    #Recria o mesmo usuário para testar possível BUG
    ${body}  Create Dictionary  
    ...    nome=Fulano Replicado  
    ...    email=${EMAIL_TEST}
    ...    password=654321  
    ...    administrador=true

    ${resposta}  POST On Session  
    ...    alias=ServeRest
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=400
    ...    verify=${False}
    ...    allow_redirects=${False}
    
    Log To Console    \nStatus esperado de erro: ${resposta.status_code}
    Log To Console    Mensagem da API: ${resposta.json()['message']}
    
    Should Be Equal As Strings    ${resposta.json()['message']}    Este email já está sendo usado

Procurar um usuário baseando-se na ID
    #Encontra o usuário criado para posteriormente deletar
    ${resposta}    GET On Session  
    ...    alias=ServeRest
    ...    url=/usuarios/${ID_USUARIO_CRIADO}
    ...    expected_status=200
    ...    verify=${False}
    Log To Console    Nome: ${resposta.json()['nome']}
    Log To Console    Email: ${resposta.json()['email']}
    Log To Console    ID: ${resposta.json()['_id']}

    Should Contain    ${resposta.json()}    nome
    Should Contain    ${resposta.json()}    email
    Should Contain    ${resposta.json()}    _id
    
    Should Be Equal As Strings    ${resposta.json()['email']}    ${EMAIL_TEST}

Modificar os dados do usuário
    #Edita o nome do usuário
    ${body}  Create Dictionary  
    ...    nome=Fulano de Tal Atualizado  
    ...    email=${EMAIL_TEST}  
    ...    password=nova_senha_123  
    ...    administrador=true

    ${resposta}  PUT On Session  
    ...    alias=ServeRest
    ...    url=/usuarios/${ID_USUARIO_CRIADO}
    ...    json=${body}
    ...    expected_status=200
    ...    verify=${False}

    Log To Console    Status da Alteração: ${resposta.status_code}
    Log To Console    Mensagem: ${resposta.json()['message']}

    Should Be Equal As Strings    ${resposta.json()['message']}    Registro alterado com sucesso

Deletar o usuário já existente
    ${resposta}  DELETE On Session
    ...    alias=ServeRest
    ...    url=/usuarios/${ID_USUARIO_CRIADO}
    ...    expected_status=200
    ...    verify=${False}

    Log To Console    Status da Alteração: ${resposta.status_code}
    Log To Console    Mensagem: ${resposta.json()['message']}

    Should Be Equal As Strings    ${resposta.json()['message']}    Registro excluído com sucesso

Verificar se o DELETE funcionou
    ${resposta}    GET On Session  
    ...    alias=ServeRest
    ...    url=/usuarios/${ID_USUARIO_CRIADO}
    ...    expected_status=400
    ...    verify=${False}
    
    Should Be Equal As Strings    ${resposta.json()['message']}    Usuário não encontrado
    Log To Console    Confirmação: O usuário foi deletado do sistema com sucesso!

Adicionar usuário com e-mail inválido
    # Gera e-mail com caractere inválido
    ${palavra_aleatoria}    Generate Random String    length=4    chars=[LETTERS]
    ${palavra_aleatoria}    Convert To Lower Case     ${palavra_aleatoria}
    Set Variable    ${EMAIL_TEST}    ${palavra_aleatoria}$@emailtest.com

    ${body}    Create Dictionary  
    ...    nome=Fulano Errado  
    ...    email=${EMAIL_TEST}
    ...    password=1234  
    ...    administrador=true

    ${resposta}    POST On Session  
    ...    alias=ServeRest
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=any
    ...    verify=${False}
    ...    allow_redirects=${False}

    Log To Console    Status recebido: ${resposta.status_code}

    IF    ${resposta.status_code} == 201
        # Se entrar aqui, a API tem um bug de lógica (aceitou e-mail inválido)
        ${id_criado}    Set Variable    ${resposta.json()['_id']}
        Set Global Variable    ${ID_USUARIO_CRIADO}    ${id_criado}
        Log To Console    ALERTA: Usuário criado indevidamente com ID: ${id_criado}.
        
        # Realiza a limpeza antes de interromper com Fail
        Deleta usuário caso exista

        Verificar se o DELETE funcionou
        
        Fail    BUG: A API aceitou um e-mail com caractere especial inválido ($).

    ELSE IF    ${resposta.status_code} == 400
        Log To Console    Sucesso: A API barrou o cadastro conforme esperado.
        # Valida se a mensagem de erro da API está correta
        Should Be Equal As Strings    ${resposta.json()['email']}    email deve ser um email válido
    
    ELSE
        Fail    A API retornou um status inesperado: ${resposta.status_code}
    END

Adicionar usuário com números no nome
    ${body}    Create Dictionary  
    ...    nome=Fulano 134  
    ...    email=${EMAIL_TEST}
    ...    password=1234  
    ...    administrador=true

    ${resposta}    POST On Session  
    ...    alias=ServeRest
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=any
    ...    verify=${False}

    Log To Console    \nStatus recebido: ${resposta.status_code}
    Log To Console    Resposta: ${resposta.text}

    IF    ${resposta.status_code} == 201
        # Se entrar aqui, a API tem um bug de lógica
        ${id_criado}    Set Variable    ${resposta.json()['_id']}
        Set Global Variable    ${ID_USUARIO_CRIADO}    ${id_criado}
        Log To Console    ALERTA: O sistema aceitou números no nome. ID: ${id_criado}

        Deleta usuário caso exista

        Verificar se o DELETE funcionou
        
        Fail    BUG: A API aceitou o cadastro de um usuário com números no nome (Status 201).
    
    ELSE IF    ${resposta.status_code} == 400
        Log To Console    Sucesso: A API barrou o nome com números conforme esperado.
        Should Contain    ${resposta.text}    nome
    
    ELSE
        Fail    A API retornou um status inesperado: ${resposta.status_code}
    END

Deleta usuário caso exista
    IF    $ID_USUARIO_CRIADO != $None and $ID_USUARIO_CRIADO != ''
        Log To Console    Limpando base: Deletando usuário ID ${ID_USUARIO_CRIADO}
        Run Keyword And Ignore Error    DELETE On Session    alias=ServeRest    url=/usuarios/${ID_USUARIO_CRIADO}  verify=${False}
        Set Global Variable    ${ID_USUARIO_CRIADO}    ${None}
    END