*** Settings ***
Resource    variaveis.resource

*** Variables ***
${END_PRODUTOS}           /produtos
${ID_PRODUTO_CRIADO}      ${NONE}
${NOME_PRODUTO_PADRAO}    Produto Teste Automatizado
${PRECO_PRODUTO_PADRAO}   ${99}
${DESC_PRODUTO_PADRAO}    Descricao do produto de teste
${QTD_PRODUTO_PADRAO}     ${10}

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

Deletar Produto Por ID
    [Documentation]    Remove um produto pelo ID informado, ignorando erros.
    [Arguments]    ${id}
    Run Keyword And Ignore Error    DELETE On Session    alias=${ALIAS}    url=${END_PRODUTOS}/${id}    verify=${False}

Limpar Produto Criado
    [Documentation]    Teardown global: remove ${ID_PRODUTO_CRIADO} se existir e reseta a variável.
    IF    $ID_PRODUTO_CRIADO != $None and $ID_PRODUTO_CRIADO != ''
        Log    Limpando base: Deletando produto ID ${ID_PRODUTO_CRIADO}
        Deletar Produto Por ID    ${ID_PRODUTO_CRIADO}
        Set Suite Variable    ${ID_PRODUTO_CRIADO}    ${NONE}
    END

# ─── KEYWORDS DE TESTE ───────────────────────────────────────────────────────

Cadastrar Produto E Validar Criacao
    [Documentation]    POST /produtos com token de admin. Persiste ${ID_PRODUTO_CRIADO} na suite.
    [Arguments]    ${token}
    ${body}       Criar Body de Produto
    ${headers}    Montar Header Com Token    ${token}
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=${END_PRODUTOS}
    ...    json=${body}
    ...    headers=${headers}
    ...    expected_status=201
    ...    verify=${False}
    Should Be Equal As Strings    ${resposta.json()['message']}    Cadastro realizado com sucesso
    Should Not Be Empty    ${resposta.json()['_id']}
    Set Suite Variable    ${ID_PRODUTO_CRIADO}    ${resposta.json()['_id']}
    RETURN    ${resposta.json()['_id']}

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
