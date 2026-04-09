*** Settings ***
Resource    ../../variables/global/global_vars.resource
Resource    ../common/common.resource

*** Variables ***
${END_CARRINHOS}           /carrinhos
${ID_CARRINHO_CRIADO}      ${NONE}
${ID_PRODUTO_FAKE}         produto_id_inexistente_xyz
${MSG_CARRINHO_CRIADO}     Cadastro realizado com sucesso
${MSG_CARRINHO_DUPLICADO}  Não é permitido ter mais de 1 carrinho
${MSG_PRODUTO_INEXISTENTE} Produto não encontrado

*** Keywords ***
# ─── HELPERS PRIVADOS ────────────────────────────────────────────────────────

Criar Body de Carrinho
    [Documentation]    Monta o payload de carrinho com lista de produtos.
    [Arguments]    ${id_produto}    ${quantidade}=${1}
    ${item}    Create Dictionary    idProduto=${id_produto}    quantidade=${quantidade}
    ${lista}    Create List    ${item}
    ${body}    Create Dictionary    produtos=${lista}
    RETURN    ${body}

Executar POST Carrinho
    [Documentation]    Executa POST /carrinhos com token e retorna a resposta.
    [Arguments]    ${body}    ${token}    ${status_esperado}=201
    ${headers}    Create Dictionary    Authorization=${token}
    ${resposta}    POST On Session
    ...    alias=${ALIAS}
    ...    url=${END_CARRINHOS}
    ...    json=${body}
    ...    headers=${headers}
    ...    expected_status=${status_esperado}
    ...    verify=${False}
    RETURN    ${resposta}

Deletar Carrinho Do Usuario
    [Documentation]    DELETE /carrinhos/concluir-compra — remove o carrinho do usuário autenticado.
    [Arguments]    ${token}
    ${headers}    Create Dictionary    Authorization=${token}
    Run Keyword And Ignore Error
    ...    DELETE On Session
    ...    alias=${ALIAS}
    ...    url=${END_CARRINHOS}/concluir-compra
    ...    headers=${headers}
    ...    verify=${False}
    Set Suite Variable    ${ID_CARRINHO_CRIADO}    ${NONE}

# ─── KEYWORDS DE TESTE ───────────────────────────────────────────────────────

Listar Carrinhos E Validar Estrutura Da Resposta
    [Documentation]    GET /carrinhos deve retornar 200 com campos 'quantidade' e 'carrinhos'.
    ${resposta}    GET On Session
    ...    alias=${ALIAS}
    ...    url=${END_CARRINHOS}
    ...    expected_status=200
    ...    verify=${False}
    Should Contain    ${resposta.json()}    quantidade
    Should Contain    ${resposta.json()}    carrinhos
    Should Be True    ${resposta.json()['quantidade']} >= 0

Cadastrar Carrinho E Validar Criacao
    [Documentation]    POST /carrinhos com produto válido deve retornar 201.
    [Arguments]    ${token}    ${id_produto}
    ${body}    Criar Body de Carrinho    ${id_produto}
    ${resposta}    Executar POST Carrinho    ${body}    ${token}
    Should Be Equal As Strings    ${resposta.json()['message']}    ${MSG_CARRINHO_CRIADO}
    Should Not Be Empty    ${resposta.json()['_id']}
    Set Suite Variable    ${ID_CARRINHO_CRIADO}    ${resposta.json()['_id']}
    RETURN    ${resposta.json()['_id']}

Cadastrar Segundo Carrinho E Validar Rejeicao
    [Documentation]    POST /carrinhos quando usuário já tem carrinho deve retornar 400.
    [Arguments]    ${token}    ${id_produto}
    ${body}    Criar Body de Carrinho    ${id_produto}
    ${resposta}    Executar POST Carrinho    ${body}    ${token}    status_esperado=400
    Should Be Equal As Strings    ${resposta.json()['message']}    ${MSG_CARRINHO_DUPLICADO}

Cadastrar Carrinho Com Produto Inexistente E Validar Rejeicao
    [Documentation]    POST /carrinhos com idProduto inexistente deve retornar 400.
    [Arguments]    ${token}
    ${body}    Criar Body de Carrinho    ${ID_PRODUTO_FAKE}
    ${resposta}    Executar POST Carrinho    ${body}    ${token}    status_esperado=400
    Should Be Equal As Strings    ${resposta.json()['message']}    ${MSG_PRODUTO_INEXISTENTE}
