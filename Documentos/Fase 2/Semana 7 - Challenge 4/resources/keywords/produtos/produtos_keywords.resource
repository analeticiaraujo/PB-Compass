*** Settings ***
Resource    ../../variables/global/global_vars.resource
Resource    ../common/common.resource

*** Variables ***
${END_PRODUTOS}            /produtos
${ID_PRODUTO_CRIADO}       ${NONE}
${NOME_PRODUTO_PADRAO}     Produto Teste Automatizado
${PRECO_PRODUTO_PADRAO}    ${99}
${DESC_PRODUTO_PADRAO}     Descricao do produto de teste
${QTD_PRODUTO_PADRAO}      ${10}
${PRECO_NEGATIVO}          ${-1}
${QTD_ZERO}                ${0}
${QTD_NEGATIVA}            ${-1}
${TOKEN_INVALIDO}          Bearer token.invalido.xyz
${MSG_PRODUTO_CRIADO}      Cadastro realizado com sucesso
${MSG_PRODUTO_DUPLICADO}   Já existe produto com esse nome
${MSG_PRECO_INVALIDO}      preco deve ser um número positivo
${MSG_DESC_OBRIGATORIA}    descricao é obrigatório
${MSG_QTD_INVALIDA}        quantidade deve ser um número inteiro
${MSG_TOKEN_INVALIDO}      Token de acesso ausente, inválido, expirado ou usuário do token não existe mais

*** Keywords ***
# ─── HELPERS PRIVADOS ────────────────────────────────────────────────────────

Criar Body de Produto
    [Documentation]    Monta o payload padrão de produto.
    [Arguments]    ${nome}=${NOME_PRODUTO_PADRAO}    ${preco}=${PRECO_PRODUTO_PADRAO}    ${descricao}=${DESC_PRODUTO_PADRAO}    ${quantidade}=${QTD_PRODUTO_PADRAO}
    ${body}    Create Dictionary
    ...    nome=${nome}
    ...    preco=${preco}
    ...    descricao=${descricao}
    ...    quantidade=${quantidade}
    RETURN    ${body}

Montar Header Com Token
    [Documentation]    Retorna dicionário de headers com o Bearer token informado.
    [Arguments]    ${token}
    ${headers}    Create Dictionary    Authorization=${token}
    RETURN    ${headers}

Executar POST Produto
    [Documentation]    Executa POST /produtos com token e retorna a resposta.
    [Arguments]    ${body}    ${token}    ${status_esperado}=201
    ${headers}    Montar Header Com Token    ${token}
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=${END_PRODUTOS}
    ...    json=${body}
    ...    headers=${headers}
    ...    expected_status=${status_esperado}
    ...    verify=${False}
    RETURN    ${resposta}

Deletar Produto Por ID
    [Documentation]    Remove um produto pelo ID informado, ignorando erros.
    [Arguments]    ${id}
    Run Keyword And Ignore Error    DELETE On Session    alias=${ALIAS}    url=${END_PRODUTOS}/${id}    verify=${False}

Limpar Produto Criado
    [Documentation]    Teardown: remove ${ID_PRODUTO_CRIADO} se existir e reseta a variável.
    IF    $ID_PRODUTO_CRIADO != $None and $ID_PRODUTO_CRIADO != ''
        Log    Limpando base: Deletando produto ID ${ID_PRODUTO_CRIADO}
        Deletar Produto Por ID    ${ID_PRODUTO_CRIADO}
        Set Suite Variable    ${ID_PRODUTO_CRIADO}    ${NONE}
    END

# ─── KEYWORDS DE TESTE ───────────────────────────────────────────────────────

Listar Produtos E Validar Estrutura Da Resposta
    [Documentation]    GET /produtos deve retornar 200 com campos 'quantidade' e 'produtos'.
    ${resposta}    GET On Session
    ...    alias=${ALIAS}
    ...    url=${END_PRODUTOS}
    ...    expected_status=200
    ...    verify=${False}
    Should Contain    ${resposta.json()}    quantidade
    Should Contain    ${resposta.json()}    produtos
    Should Be True    ${resposta.json()['quantidade']} >= 0

Cadastrar Produto E Validar Criacao
    [Documentation]    POST /produtos com token de admin deve retornar 201 e persistir ID.
    [Arguments]    ${token}
    ${nome}    Gerar Nome De Produto Unico
    ${body}    Criar Body de Produto    nome=${nome}
    ${resposta}    Executar POST Produto    ${body}    ${token}
    Should Be Equal As Strings    ${resposta.json()['message']}    ${MSG_PRODUTO_CRIADO}
    Should Not Be Empty    ${resposta.json()['_id']}
    Set Suite Variable    ${ID_PRODUTO_CRIADO}    ${resposta.json()['_id']}
    RETURN    ${resposta.json()['_id']}

Cadastrar Produto Com Nome Duplicado E Validar Conflito
    [Documentation]    POST com nome já existente deve retornar 400 com mensagem de conflito.
    [Arguments]    ${token}    ${nome_duplicado}
    ${body}    Criar Body de Produto    nome=${nome_duplicado}
    ${resposta}    Executar POST Produto    ${body}    ${token}    status_esperado=400
    Should Be Equal As Strings    ${resposta.json()['message']}    ${MSG_PRODUTO_DUPLICADO}

Cadastrar Produto Com Preco Negativo E Validar Rejeicao
    [Documentation]    POST com preço negativo deve retornar 400 com mensagem de validação.
    [Arguments]    ${token}
    ${body}    Criar Body de Produto    preco=${PRECO_NEGATIVO}
    ${resposta}    Executar POST Produto    ${body}    ${token}    status_esperado=400
    Should Be Equal As Strings    ${resposta.json()['preco']}    ${MSG_PRECO_INVALIDO}

Cadastrar Produto Sem Descricao E Validar Rejeicao
    [Documentation]    POST sem campo 'descricao' deve retornar 400 com mensagem de campo obrigatório.
    [Arguments]    ${token}
    ${nome}    Gerar Nome De Produto Unico
    ${body}    Criar Body de Produto    nome=${nome}
    Remove From Dictionary    ${body}    descricao
    ${resposta}    Executar POST Produto    ${body}    ${token}    status_esperado=400
    Should Be Equal As Strings    ${resposta.json()['descricao']}    ${MSG_DESC_OBRIGATORIA}

Cadastrar Produto Com Quantidade Zero E Validar Rejeicao
    [Documentation]    POST /produtos com quantidade=0 deve retornar 400.
    [Arguments]    ${token}
    ${nome}    Gerar Nome De Produto Unico
    ${body}    Criar Body de Produto    nome=${nome}    quantidade=${QTD_ZERO}
    ${resposta}    Executar POST Produto    ${body}    ${token}    status_esperado=400
    Should Be Equal As Strings    ${resposta.json()['quantidade']}    ${MSG_QTD_INVALIDA}

Cadastrar Produto Com Quantidade Negativa E Validar Rejeicao
    [Documentation]    POST /produtos com quantidade negativa deve retornar 400.
    [Arguments]    ${token}
    ${nome}    Gerar Nome De Produto Unico
    ${body}    Criar Body de Produto    nome=${nome}    quantidade=${QTD_NEGATIVA}
    ${resposta}    Executar POST Produto    ${body}    ${token}    status_esperado=400
    Should Be Equal As Strings    ${resposta.json()['quantidade']}    ${MSG_QTD_INVALIDA}

Cadastrar Produto Com Token Invalido E Validar Rejeicao
    [Documentation]    POST /produtos com token inválido deve retornar 401.
    ${nome}    Gerar Nome De Produto Unico
    ${body}    Criar Body de Produto    nome=${nome}
    ${resposta}    Executar POST Produto    ${body}    ${TOKEN_INVALIDO}    status_esperado=401
    Should Be Equal As Strings    ${resposta.json()['message']}    ${MSG_TOKEN_INVALIDO}

Validar Contrato Da Lista De Produtos
    [Documentation]    Percorre cada item de GET /produtos e valida os tipos de cada campo.
    ...                 Falha com mensagem descritiva se qualquer campo quebrar o contrato.
    ${resposta}    GET On Session
    ...    alias=${ALIAS}
    ...    url=${END_PRODUTOS}
    ...    expected_status=200
    ...    verify=${False}
    ${lista}    Set Variable    ${resposta.json()['produtos']}
    ${total}    Get Length    ${lista}
    Should Be True    ${total} > 0
    ...    msg=Contrato não pode ser validado: a lista de produtos está vazia.
    FOR    ${produto}    IN    @{lista}
        ${tipo_nome}    Evaluate    type($produto['nome']).__name__
        Should Be Equal As Strings    ${tipo_nome}    str
        ...    msg=CONTRATO QUEBRADO — campo 'nome' esperado str, recebido ${tipo_nome}. Produto: ${produto}
        ${preco_valido}    Evaluate    isinstance($produto['preco'], (int, float))
        Should Be True    ${preco_valido}
        ...    msg=CONTRATO QUEBRADO — campo 'preco' esperado int/float. Produto: ${produto}
        ${tipo_desc}    Evaluate    type($produto['descricao']).__name__
        Should Be Equal As Strings    ${tipo_desc}    str
        ...    msg=CONTRATO QUEBRADO — campo 'descricao' esperado str, recebido ${tipo_desc}. Produto: ${produto}
        ${tipo_qtd}    Evaluate    type($produto['quantidade']).__name__
        Should Be Equal As Strings    ${tipo_qtd}    int
        ...    msg=CONTRATO QUEBRADO — campo 'quantidade' esperado int, recebido ${tipo_qtd}. Produto: ${produto}
    END
