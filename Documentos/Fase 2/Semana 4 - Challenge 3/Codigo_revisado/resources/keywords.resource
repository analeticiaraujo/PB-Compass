*** Settings ***
Resource    variaveis.resource

*** Keywords ***
# ─── SETUP / TEARDOWN ────────────────────────────────────────────────────────

Criar Sessão na ServeRest
    [Documentation]    Cria a sessão HTTP reutilizável para toda a suite.
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json
    Create Session
    ...    alias=${ALIAS}
    ...    url=${BASE_URL}
    ...    headers=${headers}
    ...    verify=False
    ...    disable_warnings=1

Deleta usuário caso exista
    [Documentation]    Teardown: remove o usuário criado durante o teste, se existir.
    IF    $ID_USUARIO_CRIADO != $None and $ID_USUARIO_CRIADO != ''
        Log    Limpando base: Deletando usuário ID ${ID_USUARIO_CRIADO}
        Run Keyword And Ignore Error    DELETE On Session    alias=${ALIAS}    url=/usuarios/${ID_USUARIO_CRIADO}    verify=${False}
        Set Suite Variable    ${ID_USUARIO_CRIADO}    ${NONE}
    END

# ─── HELPERS PRIVADOS ────────────────────────────────────────────────────────

Gerar Email Aleatório
    [Documentation]    Retorna um e-mail único no formato xxxxxx@emailtest.com.
    ${sufixo}    Generate Random String    length=6    chars=[LETTERS][NUMBERS]
    ${sufixo}    Convert To Lower Case    ${sufixo}
    ${email}    Set Variable    ${sufixo}${DOMINIO_EMAIL}
    RETURN    ${email}

Criar Body de Usuário
    [Documentation]    Monta e retorna o dicionário padrão de payload de usuário.
    [Arguments]    ${nome}=${NOME_PADRAO}    ${email}=${EMAIL_TEST}    ${password}=${SENHA_PADRAO}    ${administrador}=true
    ${body}    Create Dictionary
    ...    nome=${nome}
    ...    email=${email}
    ...    password=${password}
    ...    administrador=${administrador}
    RETURN    ${body}

Registrar e Salvar ID
    [Documentation]    Executa POST /usuarios, valida 201 e persiste o ID na suite.
    [Arguments]    ${body}
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=201
    ...    verify=${False}
    ...    allow_redirects=${False}
    Log    ${resposta.json()}
    Set Suite Variable    ${ID_USUARIO_CRIADO}    ${resposta.json()['_id']}

# ─── KEYWORDS DE TESTE ───────────────────────────────────────────────────────

Criar um novo usuário
    [Documentation]    Gera e persiste o e-mail aleatório que será usado nos cenários seguintes.
    ${email}    Gerar Email Aleatório
    Set Suite Variable    ${EMAIL_TEST}    ${email}

Cadastrar o usuário criado na ServeRest
    ${body}    Criar Body de Usuário
    Registrar e Salvar ID    ${body}

Cadastrar um usuário já existente
    ${body}    Criar Body de Usuário    nome=Fulano Replicado    password=654321
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=400
    ...    verify=${False}
    ...    allow_redirects=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Este email já está sendo usado

Procurar um usuário baseando-se na ID
    ${resposta}    GET On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios/${ID_USUARIO_CRIADO}
    ...    expected_status=200
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['email']}    ${EMAIL_TEST}
    Should Contain    ${resposta.json()}    nome
    Should Contain    ${resposta.json()}    _id

Modificar os dados do usuário
    ${body}    Criar Body de Usuário    nome=Fulano de Tal Atualizado    password=nova_senha_123
    ${resposta}    PUT On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios/${ID_USUARIO_CRIADO}
    ...    json=${body}
    ...    expected_status=200
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Registro alterado com sucesso

Deletar o usuário já existente
    ${resposta}    DELETE On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios/${ID_USUARIO_CRIADO}
    ...    expected_status=200
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Registro excluído com sucesso

Verificar se o DELETE funcionou
    ${resposta}    GET On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios/${ID_USUARIO_CRIADO}
    ...    expected_status=400
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Usuário não encontrado

Adicionar usuário com e-mail inválido
    # BUG TEST: A API deveria rejeitar e-mails com caracteres especiais inválidos
    ${email_invalido}    Set Variable    invalido$$especial${DOMINIO_EMAIL}
    ${body}    Criar Body de Usuário    nome=Fulano Errado    email=${email_invalido}
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=any
    ...    verify=${False}
    ...    allow_redirects=${False}
    IF    ${resposta.status_code} == 201
        ${id_criado}    Set Variable    ${resposta.json()['_id']}
        Set Suite Variable    ${ID_USUARIO_CRIADO}    ${id_criado}
        Deleta usuário caso exista
        Fail    BUG: A API aceitou e-mail com caractere especial inválido ($$). ID criado: ${id_criado}
    ELSE IF    ${resposta.status_code} == 400
        Should Be Equal As Strings    ${resposta.json()['email']}    email deve ser um email válido
    ELSE
        Fail    Status inesperado: ${resposta.status_code}
    END

Adicionar usuário com números no nome
    # BUG TEST: A API deveria rejeitar nomes contendo dígitos numéricos
    ${email}    Gerar Email Aleatório
    ${body}    Criar Body de Usuário    nome=Fulano 134    email=${email}
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=any
    ...    verify=${False}
    ...    allow_redirects=${False}
    IF    ${resposta.status_code} == 201
        ${id_criado}    Set Variable    ${resposta.json()['_id']}
        Set Suite Variable    ${ID_USUARIO_CRIADO}    ${id_criado}
        Deleta usuário caso exista
        Fail    BUG: A API aceitou cadastro com números no nome (Status 201). ID: ${id_criado}
    ELSE IF    ${resposta.status_code} == 400
        Should Contain    ${resposta.text}    nome
    ELSE
        Fail    Status inesperado: ${resposta.status_code}
    END

Listar todos os usuários
    ${resposta}    GET On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    expected_status=200
    ...    verify=${False}
    Should Contain    ${resposta.json()}    quantidade
    Should Contain    ${resposta.json()}    usuarios
    Should Be True    ${resposta.json()['quantidade']} >= 0

Criar usuário via PUT (upsert)
    ${email}    Gerar Email Aleatório
    ${body}    Criar Body de Usuário    nome=Fulano Upsert    email=${email}
    ${resposta}    PUT On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios/id_inexistente_upsert
    ...    json=${body}
    ...    expected_status=201
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Cadastro realizado com sucesso
    ${id_upsert}    Set Variable    ${resposta.json()['_id']}
    Run Keyword And Ignore Error    DELETE On Session    alias=${ALIAS}    url=/usuarios/${id_upsert}    verify=${False}

Deletar usuário com ID inexistente
    ${resposta}    DELETE On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios/id_que_nao_existe_xyz
    ...    expected_status=200
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Nenhum registro excluído

Cadastrar usuário sem campo nome
    ${email}    Gerar Email Aleatório
    ${body}    Create Dictionary    email=${email}    password=${SENHA_PADRAO}    administrador=true
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=400
    ...    verify=${False}
    ...    allow_redirects=${False}
    Should Be Equal As Strings    ${resposta.json()['nome']}    nome é obrigatório

Cadastrar usuário sem campo password
    ${email}    Gerar Email Aleatório
    ${body}    Create Dictionary    nome=Fulano Sem Senha    email=${email}    administrador=true
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=400
    ...    verify=${False}
    ...    allow_redirects=${False}
    Should Be Equal As Strings    ${resposta.json()['password']}    password é obrigatório

Cadastrar usuário sem campo administrador
    ${email}    Gerar Email Aleatório
    ${body}    Create Dictionary    nome=Fulano Sem Admin    email=${email}    password=${SENHA_PADRAO}
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=400
    ...    verify=${False}
    ...    allow_redirects=${False}
    Should Be Equal As Strings    ${resposta.json()['administrador']}    administrador é obrigatório

Cadastrar usuário não administrador
    ${email}    Gerar Email Aleatório
    ${body}    Criar Body de Usuário    nome=Fulano Nao Admin    email=${email}    administrador=false
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=201
    ...    verify=${False}
    ...    allow_redirects=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Cadastro realizado com sucesso
    ${id_nao_admin}    Set Variable    ${resposta.json()['_id']}
    Run Keyword And Ignore Error    DELETE On Session    alias=${ALIAS}    url=/usuarios/${id_nao_admin}    verify=${False}
