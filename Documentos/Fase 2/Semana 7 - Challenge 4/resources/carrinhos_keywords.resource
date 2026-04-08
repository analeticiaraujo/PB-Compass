*** Settings ***
Resource    variaveis.resource

*** Variables ***
${END_CARRINHOS}    /carrinhos

*** Keywords ***
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
