*** Settings ***
Resource    variaveis.resource
Resource    common.resource

*** Variables ***
${NOME_DUPLICADO}            Fulano Replicado
${SENHA_DUPLICADO}           654321
${NOME_ATUALIZADO}           ${EMPTY}
${SENHA_ATUALIZADA}          ${EMPTY}
${NOME_UPSERT}               ${EMPTY}
${ID_UPSERT_FAKE}            id_inexistente_upsert
${ID_DELETE_FAKE}            id_que_nao_existe_xyz
${EMAIL_INVALIDO_PREFIXO}    invalido$$especial
${NOME_COM_NUMERO}           Fulano 134

*** Keywords ***
# ─── SETUP / TEARDOWN ────────────────────────────────────────────────────────

Deletar Usuario Por ID
    [Documentation]    Remove um usuário pelo ID informado, ignorando erros.
    [Arguments]    ${id}
    Run Keyword And Ignore Error    DELETE On Session    alias=${ALIAS}    url=/usuarios/${id}    verify=${False}

Limpar Usuario Criado
    [Documentation]    Teardown: remove ${ID_USUARIO_CRIADO} se existir e reseta a variável.
    IF    $ID_USUARIO_CRIADO != $None and $ID_USUARIO_CRIADO != ''
        Log    Limpando base: Deletando usuário ID ${ID_USUARIO_CRIADO}
        Deletar Usuario Por ID    ${ID_USUARIO_CRIADO}
        Set Suite Variable    ${ID_USUARIO_CRIADO}    ${NONE}
    END

# ─── HELPERS PRIVADOS ────────────────────────────────────────────────────────

Criar Body de Usuario
    [Documentation]    Monta e retorna o dicionário padrão de payload de usuário.
    [Arguments]    ${nome}=${NOME_PADRAO}    ${email}=${EMAIL_TEST}    ${password}=${SENHA_PADRAO}    ${administrador}=true
    ${body}    Create Dictionary
    ...    nome=${nome}
    ...    email=${email}
    ...    password=${password}
    ...    administrador=${administrador}
    RETURN    ${body}

Executar POST Usuario
    [Documentation]    Executa POST /usuarios e retorna a resposta.
    [Arguments]    ${body}    ${status_esperado}=201
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=${status_esperado}
    ...    verify=${False}
    ...    allow_redirects=${False}
    RETURN    ${resposta}

# ─── SETUP DE MASSA ──────────────────────────────────────────────────────────

Criar E Cadastrar Usuario
    [Documentation]    Gera massa dinâmica via Faker, cadastra o usuário e persiste ID e e-mail
    ...                 como variáveis de suite. Seguro para execução paralela.
    ${massa}    Gerar Massa de Dados Dinâmica
    Set Suite Variable    ${EMAIL_TEST}      ${massa}[email]
    Set Suite Variable    ${SENHA_PADRAO}    ${massa}[password]
    ${body}    Criar Body de Usuario
    ...    nome=${massa}[nome]
    ...    email=${massa}[email]
    ...    password=${massa}[password]
    ${resposta}    Executar POST Usuario    ${body}
    Should Be Equal As Strings    ${resposta.json()['message']}    Cadastro realizado com sucesso
    Should Not Be Empty    ${resposta.json()['_id']}
    Set Suite Variable    ${ID_USUARIO_CRIADO}    ${resposta.json()['_id']}

# ─── KEYWORDS DE TESTE ───────────────────────────────────────────────────────

Validar Usuario Cadastrado Com Sucesso
    [Documentation]    Confirma que ${ID_USUARIO_CRIADO} foi populado após o cadastro.
    Should Not Be Empty    ${ID_USUARIO_CRIADO}

Cadastrar Usuario Duplicado E Validar Conflito
    [Documentation]    Tenta cadastrar com o mesmo e-mail e valida mensagem 400.
    ${body}    Criar Body de Usuario    nome=${NOME_DUPLICADO}    password=${SENHA_DUPLICADO}
    ${resposta}    Executar POST Usuario    ${body}    status_esperado=400
    Should Be Equal As Strings    ${resposta.json()['message']}    Este email já está sendo usado

Buscar Usuario Por ID E Validar Dados
    [Documentation]    GET /usuarios/{id} e valida e-mail, nome e _id no corpo da resposta.
    ${resposta}    GET On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios/${ID_USUARIO_CRIADO}
    ...    expected_status=200
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['email']}    ${EMAIL_TEST}
    Should Be Equal As Strings    ${resposta.json()['_id']}      ${ID_USUARIO_CRIADO}
    Should Contain    ${resposta.json()}    nome

Atualizar Dados Do Usuario E Validar Confirmacao
    [Documentation]    PUT /usuarios/{id} com dados Faker novos e valida mensagem de sucesso.
    ${massa}    Gerar Massa de Dados Dinâmica
    Set Suite Variable    ${NOME_ATUALIZADO}    ${massa}[nome]
    Set Suite Variable    ${SENHA_ATUALIZADA}   ${massa}[password]
    ${body}    Criar Body de Usuario    nome=${NOME_ATUALIZADO}    password=${SENHA_ATUALIZADA}
    ${resposta}    PUT On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios/${ID_USUARIO_CRIADO}
    ...    json=${body}
    ...    expected_status=200
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Registro alterado com sucesso

Deletar Usuario Existente E Validar Confirmacao
    [Documentation]    DELETE /usuarios/{id} e valida mensagem de exclusão no corpo.
    ${resposta}    DELETE On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios/${ID_USUARIO_CRIADO}
    ...    expected_status=200
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Registro excluído com sucesso
    Set Suite Variable    ${ID_USUARIO_CRIADO}    ${NONE}

Confirmar Que Usuario Deletado Retorna Nao Encontrado
    [Documentation]    GET no ID deletado deve retornar 400 com mensagem 'Usuário não encontrado'.
    ${resposta}    GET On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios/${ID_USUARIO_CRIADO}
    ...    expected_status=400
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Usuário não encontrado

Validar Rejeicao De Email Invalido
    [Documentation]    BUG TEST — API deveria rejeitar e-mails com caracteres especiais.
    ${email_invalido}    Set Variable    ${EMAIL_INVALIDO_PREFIXO}${DOMINIO_EMAIL}
    ${body}    Criar Body de Usuario    nome=Fulano Errado    email=${email_invalido}
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=any
    ...    verify=${False}
    ...    allow_redirects=${False}
    IF    ${resposta.status_code} == 201
        ${id_criado}    Set Variable    ${resposta.json()['_id']}
        Deletar Usuario Por ID    ${id_criado}
        Fail    BUG: A API aceitou e-mail com caractere especial inválido ($$). ID criado: ${id_criado}
    ELSE IF    ${resposta.status_code} == 400
        Should Be Equal As Strings    ${resposta.json()['email']}    email deve ser um email válido
    ELSE
        Fail    Status inesperado: ${resposta.status_code}
    END

Validar Rejeicao De Nome Com Numeros
    [Documentation]    BUG TEST — API deveria rejeitar nomes contendo dígitos numéricos.
    ${massa}    Gerar Massa de Dados Dinâmica
    ${body}    Criar Body de Usuario    nome=${NOME_COM_NUMERO}    email=${massa}[email]
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    json=${body}
    ...    expected_status=any
    ...    verify=${False}
    ...    allow_redirects=${False}
    IF    ${resposta.status_code} == 201
        ${id_criado}    Set Variable    ${resposta.json()['_id']}
        Deletar Usuario Por ID    ${id_criado}
        Fail    BUG: A API aceitou cadastro com números no nome (Status 201). ID: ${id_criado}
    ELSE IF    ${resposta.status_code} == 400
        Should Contain    ${resposta.text}    nome
    ELSE
        Fail    Status inesperado: ${resposta.status_code}
    END

Listar Usuarios E Validar Estrutura Da Resposta
    [Documentation]    GET /usuarios e valida campos 'quantidade' e 'usuarios' no corpo.
    ${resposta}    GET On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios
    ...    expected_status=200
    ...    verify=${False}
    Should Contain    ${resposta.json()}    quantidade
    Should Contain    ${resposta.json()}    usuarios
    Should Be True    ${resposta.json()['quantidade']} >= 1

Criar Usuario Via Upsert E Validar Criacao
    [Documentation]    PUT em ID inexistente deve criar o usuário (upsert) com status 201.
    ${massa}    Gerar Massa de Dados Dinâmica
    Set Suite Variable    ${NOME_UPSERT}    ${massa}[nome]
    ${body}    Criar Body de Usuario    nome=${NOME_UPSERT}    email=${massa}[email]
    ${resposta}    PUT On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios/${ID_UPSERT_FAKE}
    ...    json=${body}
    ...    expected_status=201
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Cadastro realizado com sucesso
    Should Not Be Empty    ${resposta.json()['_id']}
    RETURN    ${resposta.json()['_id']}

Deletar Usuario Com ID Inexistente E Validar Mensagem
    [Documentation]    DELETE em ID inexistente deve retornar 200 com 'Nenhum registro excluído'.
    ${resposta}    DELETE On Session
    ...    alias=${ALIAS}
    ...    url=/usuarios/${ID_DELETE_FAKE}
    ...    expected_status=200
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Nenhum registro excluído

Cadastrar Usuario Com Campo Ausente E Validar Erro
    [Documentation]    POST sem um campo obrigatório e valida a mensagem de erro específica do campo.
    [Arguments]    ${campo_omitido}    ${mensagem_esperada}
    ${massa}    Gerar Massa de Dados Dinâmica
    ${body}    Criar Body de Usuario    email=${massa}[email]
    Remove From Dictionary    ${body}    ${campo_omitido}
    ${resposta}    Executar POST Usuario    ${body}    status_esperado=400
    Should Be Equal As Strings    ${resposta.json()['${campo_omitido}']}    ${mensagem_esperada}

Cadastrar Usuario Nao Administrador E Validar Criacao
    [Documentation]    POST com administrador=false deve retornar 201 com mensagem de sucesso.
    ${massa}    Gerar Massa de Dados Dinâmica
    ${body}    Criar Body de Usuario
    ...    nome=${massa}[nome]
    ...    email=${massa}[email]
    ...    password=${massa}[password]
    ...    administrador=false
    ${resposta}    Executar POST Usuario    ${body}
    Should Be Equal As Strings    ${resposta.json()['message']}    Cadastro realizado com sucesso
    Should Not Be Empty    ${resposta.json()['_id']}
    RETURN    ${resposta.json()['_id']}
